#include "server.h"

#include "sql.h"
#include "misc.h"
#include "local.h"

#include "proto/constant.h"
#include "copy_imp.h"

namespace copy
{
    uint32 SaveLog( uint32 copy_id, std::vector< SCopyFightLog >& list )
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
        {
            LOG_ERROR("sql is null");
            return 1;
        }

        sql->execute( "delete from copy_fightlog where copy_id = %u", copy_id );

        wd::CStream bstr;

        for ( std::vector< SCopyFightLog >::iterator iter = list.begin(); iter != list.end(); ++iter )
        {

            SCopyFightLog& log = *iter;

            sql->execute("insert into copy_fightlog values( %u, %u, %u, %u, '%s', %hu, %u, %u, %u )",
                copy_id, log.fight_id , log.ack_id, log.ack_level,
                sql->escape( log.ack_name.c_str() ).c_str(), log.ack_avatar, log.log_time, log.star, log.fight_value);
        }

        return 0;
    }

    uint32 LoadLog()
    {
        wd::CSql* sql = sql::get( "master" );
        if ( sql == NULL )
            return 1;

        PRCopyFightLogLoad rep;

        SCopyFightLog log;

        sql->query( "select copy_id, fight_id, ack_id, ack_level, ack_name, ack_avatar, log_time, star, fight_value from copy_fightlog");
        for ( sql->first(); !sql->empty(); sql->next() )
        {
            int32 i = 0;

            //加log
            log.copy_id       = sql->getInteger(i++);
            log.fight_id        = sql->getInteger(i++);
            log.ack_id          = sql->getInteger(i++);
            log.ack_level       = sql->getInteger(i++);
            log.ack_name        = sql->getString(i++);
            log.ack_avatar      = sql->getInteger(i++);
            log.log_time        = sql->getInteger(i++);
            log.star            = sql->getInteger(i++);
            log.fight_value     = sql->getInteger(i++);

            rep.list.push_back( log );
        }

        //发送空数据以示结束
        local::write( local::game, rep );

        return 0;
    }

}// namespace copy

