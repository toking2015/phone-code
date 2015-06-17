#include "misc.h"
#include "local.h"
#include "proto/fight.h"
#include "proto/system.h"
#include "fight_imp.h"
#include "fightlog_dc.h"
#include "common.h"
#include "gamelua.h"
#include "luaseq.h"

MSG_FUNC( PQCommonFightClientEnd )
{
    SFight *psfight = &msg.fight_info_game;

    //LOG_DEBUG("check_result:first");
    lua::clearlog();
    fight::InitFightLua( psfight->fight_id, psfight->fight_randomseed, psfight->fight_type, psfight->fight_info_list );
    uint32 check_result = fight::CheckFightLua( psfight, msg.order_list, msg.fight_info_list );
    bool check = false;
    if( 0 != check_result || check )
    {
        lua::printlog();
        LOG_ERROR("check_err_no:%d",check_result);
    }

    PRCommonFightClientEnd rep;
    rep.fight_id = msg.fight_id;
    rep.check_result = check_result;
    rep.win_camp = msg.win_camp;
    rep.is_roundout = msg.is_roundout;
    rep.fightEndInfo = msg.fightEndInfo;
    bccopy(rep, msg );
    local::write(local::game, rep);

    //删除
    fight::DelFight( psfight->fight_id );
}

MSG_FUNC( PRCommonFightInfo )
{
    lua::clearlog();
    fight::FightLua( msg.fight_id, msg.fight_randomseed, msg.fight_type, msg.fight_info_list );

    PRCommonFightServerEnd rep;
    rep.fight_id = msg.fight_id;
    rep.fight_type = msg.fight_type;
    rep.fight_randomseed = msg.fight_randomseed;
    rep.fight_info_list = msg.fight_info_list;
    rep.order_list = fight::GetOrderLua( msg.fight_id );
    rep.win_camp = fight::GetWinCamp( msg.fight_id );
    rep.is_roundout = fight::GetRoundOut( msg.fight_id );
    rep.fightEndInfo = fight::GetFightEndInfo( msg.fight_id );
    bccopy(rep, msg);
    local::write(local::game, rep);

    lua::printlog();
    //删除
    fight::DelFight( msg.fight_id );
}

MSG_FUNC(PQFightRecordID)
{
    theFightRecordDC.ReplyId();
}

MSG_FUNC(PQFightRecordSave)
{
    theFightRecordDC.Set(msg.fight_record);
}

MSG_FUNC(PQFightRecordGet)
{
    PRFightRecordGet rep;
    uint32 ret = theFightRecordDC.Get( msg.guid, rep.fight_record );
    if ( 0 != ret )
    {
        PRSystemErrCode     rep;
        bccopy(rep, msg);
        rep.err_no          = ret;
        local::write(local::game, rep);
    }
    else
    {
        bccopy( rep, msg );
        local::write(local::game, rep);
    }
}
