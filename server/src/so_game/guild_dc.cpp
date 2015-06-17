#include "guild_dc.h"
#include "raw.h"
#include "db.h"
#include "server.h"
#include "proto/system.h"
#include "proto/guild.h"

SGuildSimple* CGuildDC::find_simple( uint32 id )
{
    std::map< uint32, SGuildSimple >::iterator iter = db().simple_map.find( id );
    if ( iter == db().simple_map.end() )
        return NULL;

    SGuildSimple* simple = &(iter->second);

    return simple;
}

SGuild* CGuildDC::find( uint32 id )
{
    std::map< uint32, SGuild >::iterator iter = db().guild_map.find( id );
    if ( iter == db().guild_map.end() )
        return NULL;

    SGuild* guild = &(iter->second);
    guild->ext.meet_time = (uint32)server::local_time();

    return guild;
}

SGuild* CGuildDC::create( uint32 id, SGuildData& data )
{
    SGuild& guild = db().guild_map[ id ];
    guild.guid = id;
    guild.data = data;

    return &guild;
}

void CGuildDC::save_once(uint32 count)
{
    std::map< uint32, SGuild >::iterator iter = db().guild_map.begin();

    //容错重置索引
    if ( db().save_index >= (int32)db().guild_map.size() )
        db().save_index = 0;

    //取到指定索引位置
    for ( int32 idx = 0;
        idx < db().save_index && iter != db().guild_map.end();
        ++iter, ++idx )
    {
        //do nothing
    }

    uint32 sum = 0;
    uint32 time_now = (uint32)server::local_time();
    for ( db().save_index += 1;
        iter != db().guild_map.end();
        ++iter, ++db().save_index )
    {
        SGuild& guild = iter->second;

        //忽略上次保存时间大于访问时间的用户
        if ( guild.ext.save_time >= guild.ext.meet_time )
            continue;

        //忽略上次保存时间在10分钟内的用户
        if ( guild.ext.save_time + 6/*00*/ > time_now )
            continue;

        //保存用户数据
        save( guild );

        if (++sum >= count)
            break;
    }
}

void CGuildDC::query_save( uint32 id )
{
    SGuild* guild = find( id );
    if ( guild == NULL )
        return;

    save( *guild );
}

void CGuildDC::save( SGuild& guild )
{
    guild.ext.save_time = (uint32)server::local_time();

    std::string data = raw::get_save_string( guild.guid, guild.data, guild.ext.check );
    if ( data.empty() )
        return;

    theDB.post_save( CDB::db::guild, guild.guid, data );
}

void CGuildDC::query_load( uint32 id, bool create )
{
    theDB.post_load( CDB::db::guild, id, create );
}

void CGuildDC::release( uint32 id )
{
    std::map< uint32, SGuild >::iterator iter = db().guild_map.find( id );
    if ( iter == db().guild_map.end() )
        return;

    SGuild& guild = iter->second;

    //如果访问时间大于保存时间, 尝试保存公会数据
    if ( guild.ext.meet_time > guild.ext.save_time )
        save( guild );

    //移除用户数据
    db().guild_map.erase( iter );
}

void CGuildDC::release_timeout_guild( uint32 seconds )
{
    uint32 time_now = (uint32)server::local_time();

    std::list< uint32 > timeout_list;
    for ( std::map< uint32, SGuild >::iterator iter = db().guild_map.begin();
        iter != db().guild_map.end();
        ++iter )
    {
        SGuild& guild = iter->second;

        //10分钟超时判断
        if ( time_now > guild.ext.meet_time + seconds )
            timeout_list.push_back( iter->first );
    }

    //释放超时用户数据
    for ( std::list< uint32 >::iterator iter = timeout_list.begin();
        iter != timeout_list.end();
        ++iter )
    {
        release( *iter );
    }
}

void CGuildDC::release_timeout_defer( uint32 seconds )
{
    uint32 time_now = (uint32)server::local_time();

    std::list< uint32 > release_id_list;
    for ( std::map< uint32, std::list< SDefer > >::iterator i = defer_map.begin();
        i != defer_map.end();
        ++i )
    {
        std::list< SDefer >& list = i->second;
        for ( std::list< SDefer >::iterator j = list.begin(); j != list.end(); )
        {
            if ( time_now > j->time + seconds )
            {
                delete j->stream;
                list.erase( j++ );
                continue;
            }

            ++j;
        }

        if ( list.empty() )
            release_id_list.push_back( i->first );
    }

    for ( std::list< uint32 >::iterator iter = release_id_list.begin();
        iter != release_id_list.end();
        ++iter )
    {
        defer_map.erase( *iter );
    }
}

std::string CGuildDC::find_name( uint32 id )
{
    std::map< uint32, std::string >::iterator iter = db().guild_id_name.find( id );
    if ( iter != db().guild_id_name.end() )
        return iter->second;

    return std::string();
}
uint32 CGuildDC::find_id( std::string name )
{
    std::map< std::string, uint32 >::iterator iter = db().guild_name_id.find( name );
    if ( iter != db().guild_name_id.end() )
        return iter->second;

    return 0;
}

uint32 CGuildDC::query_list( uint32 index, uint32 count, std::vector< uint32 >& list )
{
    return dc::cat_elements( db().order_member_count, index, count, list );
}

std::vector< uint32 > CGuildDC::create_base_id_array(void)
{
    std::vector< uint32 > array;

    for ( std::map< uint32, SGuild >::iterator iter = db().guild_map.begin();
        iter != db().guild_map.end();
        ++iter )
    {
        array.push_back( iter->first );
    }

    return array;
}
void CGuildDC::sort(void)
{
    if ( db().order_member_count.empty() )
        db().order_member_count = create_base_id_array();

    std::sort( db().order_member_count.begin(), db().order_member_count.end(), guild_compare_member_count );
}

void CGuildDC::defer_msg( uint32 id, int32 sock, int32 key, wd::CStream* stream )
{
    defer_map[ id ].push_back( SDefer( sock, key, stream ) );
}

void CGuildDC::dispatch_defer( uint32 id )
{
    std::map< uint32, std::list< SDefer > >::iterator iter = defer_map.find( id );
    if ( iter == defer_map.end() )
        return;

    for ( std::list< SDefer >::reverse_iterator rit = iter->second.rbegin();
        rit != iter->second.rend();
        ++rit )
    {
        wd::CStream& stream = *rit->stream;
        theMsg.Send( rit->sock, rit->key, &stream[0], stream.length() );

        delete rit->stream;
    }

    defer_map.erase( iter );
}

bool CGuildDC::guild_compare_member_count( uint32 l_id, uint32 r_id )
{
    SGuild* l = theGuildDC.find( l_id );
    SGuild* r = theGuildDC.find( r_id );

    if ( l->data.member_list.size() > r->data.member_list.size() )
        return true;
    if ( l->data.member_list.size() < r->data.member_list.size() )
        return false;

    return l_id < r_id;
}

