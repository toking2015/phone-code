#include "server.h"

#include "sql.h"
#include "misc.h"
#include "local.h"

#include "proto/constant.h"
#include "singlearena_imp.h"

namespace singlearena
{

    uint32 SaveData( uint8 set_type, SSingleArenaOpponent& data)
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
        {
            LOG_ERROR("sql is null");
            return 1;
        }

        switch ( set_type )
        {
        case kSingleArenaObjectDel:
            {
                sql->execute( "delete from singlearena where target_id = %u", data.target_id );
            }
            break;
        case kSingleArenaObjectAdd:
            {
                sql->execute( "insert into singlearena values( %u, '%s', %u, %u, %u, %hu )",
                    data.target_id, sql->escape( data.name.c_str() ).c_str(), data.team_level, data.rank, data.fight_value, data.avatar );
            }
            break;
        }

        return 0;
    }

    uint32 LoadData()
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
            return 1;

        PRSingleArenaRankLoad rep;

        SSingleArenaOpponent data;

        sql->query( "select target_id, name, team_level, rank, fight_value, avatar from singlearena");
        for ( sql->first(); !sql->empty(); sql->next() )
        {
            int32 i = 0;

            //加载元素
            data.target_id         = sql->getInteger(i++);
            data.name              = sql->getString(i++);
            data.team_level        = sql->getInteger(i++);
            data.rank              = sql->getInteger(i++);
            data.fight_value       = sql->getInteger(i++);
            data.avatar            = sql->getInteger(i++);

            data.formation_list.clear();


            rep.list.push_back( data );

            //发送数据
            if ( rep.list.size() >= 512 )
            {
                local::write( local::game, rep );

                rep.list.clear();
            }
        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );

        return 0;
    }

    uint32 SaveLog( uint32 target_id, std::vector< SSingleArenaLog >& list )
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
        {
            LOG_ERROR("sql is null");
            return 1;
        }

        sql->execute( "delete from singlearena_log where target_id = %u", target_id );

        wd::CStream bstr;

        for ( std::vector< SSingleArenaLog >::iterator iter = list.begin(); iter != list.end(); ++iter )
        {

            SSingleArenaLog& log = *iter;

            sql->execute("insert into singlearena_log values( %u, %u, %u, %u, %u, %u, '%s', %hu, '%s', %hu, %u, %u, %i )",
                target_id, log.fight_id , log.ack_id, log.def_id, log.ack_level, log.def_level,
                sql->escape( log.ack_name.c_str() ).c_str(), log.ack_avatar, sql->escape( log.def_name.c_str() ).c_str(), log.def_avatar, log.win_flag, log.log_time, log.rank_num );
        }

        return 0;
    }

    uint32 LoadLog()
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
            return 1;

        PRSingleArenaLogLoad rep;

        SSingleArenaLog log;

        sql->query( "select target_id, fight_id, ack_id, def_id, ack_level, def_level, ack_name, ack_avatar, def_name, def_avatar, win_flag, log_time, rank_num from singlearena_log");
        for ( sql->first(); !sql->empty(); sql->next() )
        {
            int32 i = 0;

            //加log
            log.target_id       = sql->getInteger(i++);
            log.fight_id        = sql->getInteger(i++);
            log.ack_id          = sql->getInteger(i++);
            log.def_id          = sql->getInteger(i++);
            log.ack_level       = sql->getInteger(i++);
            log.def_level       = sql->getInteger(i++);
            log.ack_name        = sql->getString(i++);
            log.ack_avatar      = sql->getInteger(i++);
            log.def_name        = sql->getString(i++);
            log.def_avatar      = sql->getInteger(i++);
            log.win_flag        = sql->getInteger(i++);
            log.log_time        = sql->getInteger(i++);
            log.rank_num        = sql->getInteger(i++);

            rep.list.push_back( log );

            //发送数据
            if ( rep.list.size() >= 512 )
            {
                local::write( local::game, rep );

                rep.list.clear();
            }
        }

        //发送剩余数据
        if ( !rep.list.empty() )
        {
            local::write( local::game, rep );

            rep.list.clear();
        }

        //发送空数据以示结束
        local::write( local::game, rep );

        return 0;
    }

}// namespace singlearena

