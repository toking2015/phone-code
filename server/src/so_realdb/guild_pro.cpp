#include "pro.h"
#include "proto/guild.h"
#include "local.h"
#include "server.h"

MSG_FUNC( PQGuildSimpleList )
{
    PRGuildSimpleList rep;

    //遍历所有游戏数据库
    for ( std::list< int32 >::iterator iter = server::id_list().begin();
        iter != server::id_list().end();
        ++iter )
    {
        wd::CSql* sql = sql::get( *iter );
        if ( sql == NULL )
            continue;

        SGuildSimple data;

        sql->query("select guid, name, level from guildsimple");
        for ( sql->first(); !sql->empty(); sql->next() )
        {
            int32 i = 0;
            data.guid = sql->getInteger(i++);
            data.name = sql->getString(i++);
            data.level = sql->getInteger(i++);

            rep.list.push_back( data );

            if ( rep.list.size() >= 1024 )
            {
                local::write( key, rep );

                rep.list.clear();
            }
        }
    }

    local::write( key, rep );

    if ( !rep.list.empty() )
    {
        rep.list.clear();

        //发空数组协议代表数据已完整发送结束
        local::write( key, rep );
    }
}

MSG_FUNC( PQGuildCreate )
{
    wd::CSql* sql = sql::get( "master" );
    if ( sql == NULL )
        return;

    if ( !sql->execute( "start transaction" ) && sql->lastErrorCode() != 0 )
    {
        LOG_ERROR( "sql start transaction error[%d][%s]", sql->lastErrorCode(), sql->lastErrorMsg() );
        return;
    }

    uint32 now = time(NULL);
    do {
        if ( !sql->execute( "insert into guildsimple values( 0, '%s' )", sql->escape(msg.name.c_str()).c_str() ) && sql->lastErrorCode() != 0 )
            break;

        uint32 guid = (uint32)sql->insertId();
        if ( guid == 0 )
            break;

        if ( !sql->execute( "insert into guildinfo values( %u, %u, %u )", guid, msg.role_id, now ) && sql->lastErrorCode() != 0 )
            break;

        sql->query("select guid from guildmember where role_id = %u", msg.role_id);
        if (!sql->empty())
        {
            if (!sql->execute("update guildmember set guid = %u, job = %u, join_time = %u where role_id = %u", guid, kGuildJobMaster, now, msg.role_id)
                && sql->lastErrorCode() != 0)
            {
                break;
            }
        }
        else
        {
            if ( !sql->execute( "insert into guildmember values( %u, %u, %u )", guid, msg.role_id, kGuildJobMaster )
                && sql->lastErrorCode() != 0 )
            {
                break;
            }
        }

        if ( !sql->execute( "commit" ) && sql->lastErrorCode() != 0 )
            break;

        PRGuildCreate rep;
        bccopy( rep, msg );

        rep.guild_id = guid;
        rep.name = msg.name;
        rep.create_time = now;

        local::write( key, rep );

        return;

    } while (0);

    LOG_ERROR( "sql execute error[%d][%s]", sql->lastErrorCode(), sql->lastErrorMsg() );
    sql->execute( "roolback" );
}

