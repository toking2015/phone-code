#include "db.h"
#include "mysql.h"
#include "misc.h"

CDB::CDB()
{
    thread_status = 0;
}

void CDB::bind( CDB::db::type type, FCallLoad load, FCallSave save )
{
    call_map[ type ] = std::make_pair( load, save );
}

bool CDB::do_load_event(void)
{
    if ( load_list_map.empty() )
        return false;

    std::map< int32, std::list< std::pair< uint32, bool > > > copy_list_map;
    std::map< int32, std::map< uint32, uint32 > > save_flag_map;
    {
        wd::CGuard< wd::CMutex > safe( &mutex );

        //在保存列表中的用户暂延加载处理
        for ( std::map< int32, std::list< std::pair< uint32, std::string > > >::iterator i = save_list_map.begin();
            i != save_list_map.end();
            ++i )
        {
            std::list< std::pair< uint32, std::string > >& save_list = i->second;
            std::map< uint32, uint32 >& save_flag = save_flag_map[ i->first ];

            //保存请求标志
            for ( std::list< std::pair< uint32, std::string > >::iterator j = save_list.begin();
                j != save_list.end();
                ++j )
            {
                save_flag[ j->first ]++;
            }
        }

        //移除重复的加载请求
        std::list< int32 > remove_list;
        for ( std::map< int32, std::list< std::pair< uint32, bool > > >::iterator i = load_list_map.begin();
            i != load_list_map.end();
            ++i )
        {
            std::list< std::pair< uint32, bool > >& copy_list = copy_list_map[ i->first ];
            std::list< std::pair< uint32, bool > >& load_list = i->second;
            std::map< uint32, uint32 >& save_flag = save_flag_map[ i->first ];

            for ( std::list< std::pair< uint32, bool > >::iterator j = load_list.begin();
                j != load_list.end(); )
            {
                //只加载不存在保存标志数据
                if ( !save_flag[ j->first ] )
                {
                    copy_list.push_back( *j );

                    load_list.erase( j++ );
                    continue;
                }

                ++j;
            }

            if ( copy_list.empty() )
                copy_list_map.erase( i->first );

            if ( load_list.empty() )
                remove_list.push_back( i->first );
        }

        //移除空元素
        for ( std::list< int32 >::iterator iter = remove_list.begin();
            iter != remove_list.end();
            ++iter )
        {
            load_list_map.erase( *iter );
        }
    }

    if ( copy_list_map.empty() )
        return false;

    //加锁调用加载用户数据
    {
        wd::CGuard< wd::CMutex > safe( &reload_mutex );

        for ( std::map< int32, std::list< std::pair< uint32, bool > > >::iterator i = copy_list_map.begin();
            i != copy_list_map.end();
            ++i )
        {
            std::list< std::pair< uint32, bool > >& copy_list = i->second;
            FCallLoad load = call_map[ i->first ].first;

            for ( std::list< std::pair< uint32, bool > >::iterator j = copy_list.begin();
                j != copy_list.end();
                ++j )
            {
                load( j->first, j->second );
            }
        }
    }

    return true;
}

bool CDB::do_save_event(void)
{
    if ( save_list_map.empty() )
        return false;

    std::map< int32, std::list< std::pair< uint32, std::string > > > copy_list_map;
    {
        wd::CGuard< wd::CMutex > safe( &mutex );

        std::swap( copy_list_map, save_list_map );
    }

    //加锁调用保存用户数据
    {
        wd::CGuard< wd::CMutex > safe( &reload_mutex );

        for ( std::map< int32, std::list< std::pair< uint32, std::string > > >::iterator i = copy_list_map.begin();
            i != copy_list_map.end();
            ++i )
        {
            std::list< std::pair< uint32, std::string > >& copy_list = i->second;
            FCallSave save = call_map[ i->first ].second;

            for ( std::list< std::pair< uint32, std::string > >::iterator j = copy_list.begin();
                j != copy_list.end();
                ++j )
            {
                save( j->first, j->second );
            }
        }
    }

    return true;
}

void CDB::post_load( CDB::db::type type, uint32 id, bool create )
{
    wd::CGuard< wd::CMutex > safe( &mutex );

    std::list< std::pair< uint32, bool > >& load_list = load_list_map[ type ];
    for ( std::list< std::pair< uint32, bool > >::iterator iter = load_list.begin();
        iter != load_list.end();
        ++iter )
    {
        if ( iter->first == id && iter->second == create )
            return;
    }

    load_list.push_back( std::make_pair( id, create ) );
}

void CDB::post_save( CDB::db::type type, uint32 id, std::string& sql_string )
{
    wd::CGuard< wd::CMutex > safe( &mutex );

    save_list_map[ type ].push_back( std::make_pair( id, sql_string ) );
}

uint32 CDB::Run(void)
{
    thread_status = 0;

    mysql_thread_init();

    while ( state_not( thread_status, EStop ) )
    {
        if ( do_load_event() )
            continue;

        if ( do_save_event() )
            continue;

        wd::thread_sleep(100);
    }

    mysql_thread_end();

    return 0;
}

void CDB::EndThread(void)
{
    state_add( thread_status, EStop );

    wd::thread_wait_exit( GetHandle() );
}

