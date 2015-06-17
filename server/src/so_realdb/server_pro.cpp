#include "pro.h"
#include "server.h"
#include "proto/server.h"
#include "proto/friend.h"

MSG_FUNC( PQServerNotify )
{
    server::data_map()[ msg.key ] = msg.value;

    wd::CSql* sql = sql::get( "master" );
    if ( sql == NULL )
        return;

    ExecuteSql( "delete from server_info where `key` = '%s'", sql->escape( msg.key.c_str() ).c_str() );
    ExecuteSql( "insert into server_info values( '%s', '%s' )",
        sql->escape( msg.key.c_str() ).c_str(),
        sql->escape( msg.value.c_str() ).c_str() );
}

MSG_FUNC( PQServerInfoList )
{
    wd::CSql* sql = sql::get( "master" );
    if ( sql == NULL )
        return;

    PRServerInfoList rep;

    QuerySql( "select `key`, `value` from server_info" );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        rep.key_value[ sql->getString(0) ] = sql->getString(1);
    }

    local::write( key, rep );
}

MSG_FUNC( PQServerNameList )
{
    PRServerNameList rep;

    //遍历所有游戏数据库
    for ( std::list< int32 >::iterator iter = server::id_list().begin();
        iter != server::id_list().end();
        ++iter )
    {
        wd::CSql* sql = sql::get( *iter );
        if ( sql == NULL )
            continue;

        QuerySql( "select guid, name from usersimple" );
        {
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                rep.user_name_id[ sql->getString(1) ] = sql->getInteger(0);

                if ( rep.user_name_id.size() > 1024 )
                {
                    local::write( key, rep );

                    rep.user_name_id.clear();
                }
            }
        }

        QuerySql( "select guid, name from guildsimple" );
        {
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                rep.guild_name_id[ sql->getString(1) ] = sql->getInteger(0);

                if ( rep.guild_name_id.size() > 1024 )
                {
                    local::write( key, rep );

                    rep.guild_name_id.clear();
                }
            }
        }
    }

    local::write( key, rep );
}

MSG_FUNC( PQServerFriendList )
{
    PRServerFriendList rep;

    SFriendData data;

    //遍历所有游戏数据库
    for ( std::list< int32 >::iterator iter = server::id_list().begin();
        iter != server::id_list().end();
        ++iter )
    {
        wd::CSql* sql = sql::get( *iter );
        if ( sql == NULL )
            continue;

        QuerySql( "select guid, avatar, team_level, name from usersimple where team_level >= %u", msg.level );
        {
            for ( sql->first(); !sql->empty(); sql->next() )
            {
                uint32 i=0;
                data.target_id          = sql->getInteger(i++);
                data.target_avatar      = sql->getInteger(i++);
                data.target_level       = sql->getInteger(i++);
                data.target_name        = sql->getString(i++);
                rep.user_id_friend[ data.target_id ] = data;

                if ( rep.user_id_friend.size() > 521 )
                {
                    local::write( key, rep );

                    rep.user_id_friend.clear();
                }
            }
        }
    }

    local::write( key, rep );
}

