#include "user_dc.h"
#include "user_event.h"
#include "raw.h"
#include "db.h"
#include "server.h"
#include "proto/system.h"
#include "proto/user.h"
#include "settings.h"
#include "common.h"
#include "back_imp.h"
#include "settings.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <fstream>

SUser* CUserDC::find( uint32 id )
{
    std::map< uint32, SUser >::iterator iter = db().user_map.find( id );
    if ( iter == db().user_map.end() )
        return NULL;

    SUser* user = &(iter->second);
    user->ext.meet_time = (uint32)server::local_time();

    event::dispatch( SEventUserMeet( user, kPathUserMeet ) );

    return user;
}

SUser* CUserDC::create( uint32 id, SUserData& data )
{
    SUser& user = db().user_map[ id ];
    user.guid = id;
    user.data = data;

    return &user;
}

void CUserDC::save_once( uint32 count )
{
    count = std::max( count, (uint32)5 );
    count = std::min( count, (uint32)100 );

    std::map< uint32, SUser >::iterator iter = db().user_map.begin();

    //容错重置索引
    if ( db().save_index >= (int32)db().user_map.size() )
        db().save_index = 0;

    //取到指定索引位置
    for ( int32 idx = 0;
        idx < db().save_index;
        ++idx )
    {
        if ( iter == db().user_map.end() )
            break;

        ++iter;
    }

    uint32 sum = 0;

    uint32 time_now = (uint32)server::local_time();
    for ( db().save_index += 1;
        iter != db().user_map.end();
        ++iter, ++db().save_index )
    {
        SUser& user = iter->second;

        //忽略上次保存时间大于访问时间的用户
        if ( user.ext.save_time > user.ext.meet_time )
            continue;

        //忽略上次保存时间在3分钟内的用户
        if ( user.ext.save_time + 600 > time_now )
            continue;

        bool saved = save( user );

        event::dispatch( SEventUserSave( &user, strprintf( "%u/%u", db().save_index, db().user_map.size() ), saved ) );

        //保存用户数据
        if ( saved )
        {
            if ( ++sum >= count )
                break;
        }
    }
}

void CUserDC::each_save( uint32 seconds )
{
    uint32 time_now = (uint32)server::local_time();

    for ( std::map< uint32, SUser >::iterator iter = db().user_map.begin();
        iter != db().user_map.end();
        ++iter )
    {
        SUser& user = iter->second;

        //忽略上次保存时间大于访问时间的用户
        if ( user.ext.save_time > user.ext.meet_time )
            continue;

        //忽略上次保存时间不在范围内的用户
        if ( user.ext.save_time + seconds > time_now )
            continue;

        bool saved = save( user );

        event::dispatch( SEventUserSave( &user, "each", saved ) );
    }
}

bool CUserDC::save( SUser& user )
{
    user.ext.save_time = (uint32)server::local_time();

    std::string data = raw::get_save_string( user.guid, user.data, user.ext.check );
    if ( data.empty() )
        return false;

    theDB.post_save( CDB::db::user, user.guid, data );
    return true;
}

void CUserDC::save_file( uint32 rid, SUserData& data )
{
    std::string user_dir = settings::json()[ "user_dir" ].asString();
    std::string file_name = strprintf( "%s/%u", user_dir.c_str(), rid );

    wd::CStream stream;
    stream << data;

    umask(0);
    mkdir( user_dir.c_str(), 0666 );

    std::fstream out( file_name.c_str(), std::ios_base::out | std::ios_base::binary );
    if ( out.is_open() )
    {
        out.write( (char*)&stream[0], stream.length() );
        out.close();
    }
}

bool CUserDC::load_file( uint32 rid, SUserData& data )
{
    std::string user_dir = settings::json()[ "user_dir" ].asString();
    std::string file_name = strprintf( "%s/%u", user_dir.c_str(), rid );

    std::fstream in( file_name.c_str(), std::ios_base::in | std::ios_base::binary );
    if ( !in.is_open() )
        return false;

    in.seekg( 0, std::ios_base::end );
    uint32 size = (uint32)in.tellg();
    in.seekg( 0, std::ios_base::beg );

    if ( size <= 0 )
    {
        in.close();
        return false;
    }

    wd::CStream stream;
    stream.resize( size );
    {
        in.read( (char*)&stream[0], size );
    }
    stream.position(0);

    stream >> data;

    in.close();

    return true;
}

void CUserDC::query_load( uint32 id, bool create )
{
    theDB.post_load( CDB::db::user, id, create );
}

void CUserDC::release( uint32 id )
{
    //移除延迟协议堆
    std::map< uint32, std::list< SDefer > >::iterator i = defer_map.find( id );
    if ( i != defer_map.end() )
    {
        for ( std::list< SDefer >::iterator j = i->second.begin();
            j != i->second.end();
            ++j )
        {
            delete j->stream;
        }

        defer_map.erase(i);
    }

    //移除用户数据
    std::map< uint32, SUser >::iterator iter = db().user_map.find( id );
    if ( iter != db().user_map.end() )
    {
        SUser& user = iter->second;

        /*
        //如果访问时间大于保存时间, 尝试保存用户数据
        if ( user.ext.meet_time > user.ext.save_time )
            save( user );
        */
        bool saved = save( user );
        event::dispatch( SEventUserSave( &user, "release", saved ) );

        //移除用户数据
        db().user_map.erase( iter );
    }
}

void CUserDC::release_timeout_user( uint32 seconds )
{
    uint32 time_now = (uint32)server::local_time();

    std::list< uint32 > timeout_list;
    for ( std::map< uint32, SUser >::iterator iter = db().user_map.begin();
        iter != db().user_map.end();
        ++iter )
    {
        SUser& user = iter->second;

        //10分钟超时判断
        if ( time_now > user.ext.meet_time + seconds )
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

void CUserDC::release_timeout_defer( uint32 seconds )
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

std::string CUserDC::find_name( uint32 id )
{
    std::map< uint32, std::string >::iterator iter = db().user_id_name.find( id );
    if ( iter != db().user_id_name.end() )
        return iter->second;

    return std::string();
}
uint32 CUserDC::find_id( std::string name )
{
    std::map< std::string, uint32 >::iterator iter = db().user_name_id.find( name );
    if ( iter != db().user_name_id.end() )
        return iter->second;

    return 0;
}

void CUserDC::quit_force( uint32 id, uint32 err_no )
{
    //移除延迟协议堆
    std::map< uint32, std::list< SDefer > >::iterator i = defer_map.find( id );
    if ( i != defer_map.end() )
    {
        for ( std::list< SDefer >::iterator j = i->second.begin();
            j != i->second.end();
            ++j )
        {
            delete j->stream;
        }

        defer_map.erase(i);
    }

    //移除用户数据
    std::map< uint32, SUser >::iterator iter = db().user_map.find( id );
    if ( iter != db().user_map.end() )
    {
        //移除用户数据
        db().user_map.erase( iter );

        //移除延迟协议堆
        defer_map.erase( id );
    }

    //发送错误消息
    PRSystemErrCode msg;
    msg.role_id = id;

    msg.err_no = err_no;

    local::write( local::access, msg );
}

void CUserDC::defer_msg( uint32 id, int32 sock, int32 key, wd::CStream* stream )
{
    defer_map[ id ].push_back( SDefer( sock, key, stream ) );
}

void CUserDC::dispatch_defer( uint32 id )
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

uint32 CUserDC::Recommend()
{
    uint32  size = db().user_map.size();
    if( size == 0 )
        return 0;

    uint32 index = TRand( (uint32)0, size - 1 );

    for( std::map< uint32, SUser >::iterator iter = db().user_map.begin();
        iter != db().user_map.end();
        ++iter )
    {
        if( index == 0 )
        {
            return iter->second.guid;
        }
        --index;
    }
    return 0;
}

