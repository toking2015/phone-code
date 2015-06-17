#include "pro.h"
#include "proto/present.h"
#include "settings.h"

MSG_FUNC( PQPresentGlobalTake )
{
    PRPresentGlobalTake rep;
    bccopy( rep, msg );

    rep.err_code = 0;
    rep.reward_id = 0;

    do
    {
        wd::CSql* sql = sql::get( "center" );
        if ( sql == NULL )
        {
            rep.err_code = kErrPresentSqlInvaild;
            break;
        }

        //请求中心数据
        QuerySql( "select rid, reward_id, `reward_group`, platform from present_code "
            "where code = '%s' and ( platform = '' or platform = '%s' ) limit 1",
            sql->escape( msg.code.c_str() ).c_str(),
            msg.platform.c_str() )

        if ( sql->empty() )
        {
            rep.err_code = kErrPresentNoExist;
            break;
        }

        //获取相应礼包数据
        uint32 target_id    = sql->getInteger(0);
        uint32 reward_id    = sql->getInteger(1);
        uint32 reward_group = sql->getInteger(2);
        std::string platform = sql->getString(3);

        if ( target_id != 0 )
        {
            rep.err_code = kErrPresentTaken;
            break;
        }

        std::string group = settings::json()["group"].asString();

        //检查同类型礼包领取
        if ( reward_group == 0 )
        {
            QuerySql( "select count(*) from present_code "
                "where platform = '%s' and rid = %u and `group` = '%s' and reward_id = %u limit 1",
                msg.platform.c_str(), msg.role_id, group.c_str(), reward_id );

            if ( !sql->empty() && sql->getInteger(0) > 0 )
            {
                rep.err_code = kErrPresentSame;
                break;
            }
        }
        else
        {
            QuerySql( "select count(*) from present_code "
                "where platform = '%s' and rid = %u and `group` = '%s' and ( reward_id = %u or `reward_group` = %u ) limit 1",
                msg.platform.c_str(), msg.role_id, group.c_str(), reward_id, reward_group );

            if ( !sql->empty() && sql->getInteger(0) > 0 )
            {
                rep.err_code = kErrPresentSame;
                break;
            }
        }

        //礼包绑定
        ExecuteSql( "update present_code set rid = %u, `group` = '%s', platform = '%s', `time` = unix_timestamp( now() ) "
            "where platform = '%s' and code = '%s'",
            msg.role_id, group.c_str(), msg.platform.c_str(), platform.c_str(), sql->escape( msg.code.c_str() ).c_str() );

        rep.reward_id = reward_id;
    }
    while(0);

    local::write( local::game, rep );
}

