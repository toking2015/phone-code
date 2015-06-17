#include "misc.h"
#include "local.h"
#include "server.h"
#include "fight.h"
#include "proto/fight.h"
#include "fight_dc.h"
#include "fight_imp.h"
#include "user_dc.h"
#include "user_imp.h"
#include "back_imp.h"
#include "common.h"
#include "luaseq.h"
#include "pro.h"
#include "jsonconfig.h"
#include "timer.h"
#include "singlearena_imp.h"
#include "formation_imp.h"
#include "proto/friend.h"


MSG_FUNC( PQCommonFightApply )
{
    QU_ON( puser, msg.role_id );

    /*
    if( 0 !=  user::GetFightId( puser ) )
    {
        HandleErrCode(puser, kErrFightInFight, 0);
        return;
    }
    */

    CFight *pcfight = fight::Interface( kFightTypeCommon );
    if ( NULL == pcfight )
        return;

    SFight * psfight = NULL;
    if ( msg.attr == kAttrPlayer )
    {
        psfight = pcfight->AddFightToPlayer( puser, msg.target_id );
    }
    else
        psfight = pcfight->AddFightToMonster( puser, msg.target_id );
    if ( NULL == psfight )
        return;

    fight::ReplyFightInfo( psfight );
}

MSG_FUNC( PQCommonFightClientEnd )
{
    QU_ON( puser, msg.role_id );

    //检查fight_id
    if ( msg.fight_id != user::GetFightId(puser) )
        return;

    SFight *psfight = theFightDC.find( msg.fight_id );
    if ( NULL == psfight )
        return;
    //副本的战斗不走这个
    if ( psfight->fight_type == kFightTypeCopy )
        return;

    CFight *pcfight = fight::Interface( psfight->fight_type );
    if ( NULL == pcfight )
        return;

    if ( !pcfight->NeedCheck( psfight ) )
        return;
    else
    {
        msg.fight_info_game = *psfight;
    }

    //设置保存最后的信息
    psfight->soldierEndList = msg.fight_info_list;

    //设置战斗LOG保存
    fight::RecordSave( psfight, msg.order_list );

    local::write(local::fight, msg);
}

MSG_FUNC( PRCommonFightClientEnd )
{
    QU_OFF( user, msg.role_id );

    SFight *psfight = theFightDC.find( msg.fight_id );
    if ( NULL == psfight )
        return;
    //副本的战斗不走这个
    if ( psfight->fight_type == kFightTypeCopy )
        return;

    CFight *pcfight = fight::Interface( psfight->fight_type );
    if ( NULL == pcfight )
        return;

    psfight->win_camp = msg.win_camp;
    psfight->is_roundout = msg.is_roundout;
    psfight->fightEndInfo = msg.fightEndInfo;
    pcfight->OnFightClientEnd( psfight, msg.coins_list );

    fight::ReplyToAll( psfight->fight_id, msg );

    //删除战斗 没有验证通过的战斗 暂时不删除
    theFightDC.del(psfight->fight_id);
}

MSG_FUNC( PRCommonFightServerEnd )
{
    QU_OFF( user, msg.role_id );

    SFight *psfight = theFightDC.find( msg.fight_id );
    if ( NULL == psfight )
        return;

    CFight *pcfight = fight::Interface( psfight->fight_type );
    if ( NULL == pcfight )
        return;

    //设置战斗LOG保存
    fight::RecordSave( psfight, msg.order_list );

    psfight->win_camp = msg.win_camp;
    psfight->is_roundout = msg.is_roundout;
    psfight->fightEndInfo = msg.fightEndInfo;
    pcfight->OnFightClientEnd( psfight, msg.coins_list );

    fight::ReplyToAll( psfight->fight_id, msg );

    theFightDC.del(psfight->fight_id);
}


MSG_FUNC( PQPlayerFightQuit )
{
    QU_ON( puser, msg.role_id );

    SFight *psfight = theFightDC.find( msg.fight_id );
    if ( NULL == psfight )
        return;

    if( user::GetFightId(puser) != msg.fight_id )
        return;

    CFight *pcfight = fight::Interface( psfight->fight_type );
    if ( NULL == pcfight )
        return;

    psfight->is_quit = 1;
    psfight->win_camp = kFightRight;
    std::vector<S3UInt32> coin_list;
    pcfight->OnFightClientEnd( psfight, coin_list );

    theFightDC.del(psfight->fight_id);
}

MSG_FUNC(PQPlayerFightApply)
{
    QU_ON( user, msg.role_id );

    QU_OFF( ptarget_user, msg.target_id );

    CFight *pcfight = fight::Interface( kFightTypeCommonPlayer );
    if ( NULL == pcfight )
        return;

    SFight *psfight = pcfight->AddFightToPlayer( user, msg.target_id );
    if ( NULL == psfight )
        return;

    //Lua初始化
    fight::InitFightLua( psfight );
    //添加Delay
    Json::Value json;
    json["fight_id"] = psfight->fight_id;
    json["seqno"] = psfight->seqno;
    psfight->loop_id = theSysTimeMgr.AddCall( "fight_delay_skill", CJson::Write(json), kFightDelayTime );

    fight::ReplyFightInfo( psfight );
}

MSG_FUNC(PQPlayerFightAck)
{
    QU_ON( user, msg.role_id );

    SFight *psfight = theFightDC.find( msg.fight_id );
    if ( NULL == psfight )
        return;

    fight::TotemSkill( msg.fight_id, msg.fight_order.guid );
}

MSG_FUNC(PQPlayerFightSyn)
{
    QU_ON( user, msg.role_id );

    SFight *psfight = theFightDC.find( msg.fight_id );
    if ( NULL == psfight )
        return;

    if ( theFightDC.set_seqno( msg.fight_id, msg.role_id, msg.seqno ) )
    {
        fight::RoundSkill( msg.fight_id );
    }
}

MSG_FUNC(PQFightFirstShow)
{
    QU_ON( user, msg.role_id );

    CFight *pcfight = fight::Interface( kFightTypeFirstShow );
    if ( NULL == pcfight )
        return;

    SFight * psfight = pcfight->AddFightToMonster( user, 0);
    if ( NULL == psfight )
        return;

    fight::ReplyFightInfo( psfight );
}

MSG_FUNC( PQFightSingleArenaApply )
{
    QU_ON( puser, msg.role_id );

    if( msg.attr == kAttrPlayer )
    {
        QU_OFF( ptarget_user, msg.target_id );
    }

    if( !singlearena::CheckCD( puser ) )
    {
        HandleErrCode(puser, kErrSingleArenaCD, 0);
        return;
    }

    if( !singlearena::CheckTimes( puser ) )
    {
        HandleErrCode(puser, kErrSingleArenaTimes, 0);
        return;
    }

    if( singlearena::CheckRank( puser, msg.target_id, 0 ) )
        return;

    CFight *pcfight = fight::Interface( kFightTypeSingleArenaMonster );
    if ( NULL == pcfight )
        return;

    SFight * psfight = NULL;
    if ( msg.attr == kAttrPlayer )
    {
        psfight = pcfight->AddFightToPlayer( puser, msg.target_id );
    }
    else
        psfight = pcfight->AddFightToMonster( puser, msg.target_id );
    if ( NULL == psfight )
        return;

    fight::ReplyFightInfoToFightSvr( psfight );
}

MSG_FUNC( PQFriendFightApply )
{
    QU_ON( puser, msg.role_id );

    QU_OFF( ptarget_user, msg.friend_id );

    std::vector<SUserFormation> formation_list;
    formation::GetFormation( puser, kFormationTypeSingleArenaAct, formation_list );
    if( formation_list.empty() )
    {
        HandleErrCode(puser, kErrFriendFightNoOpenSinglearenaOne, 0);
        return;
    }

    formation_list.clear();

    formation::GetFormation( ptarget_user, kFormationTypeSingleArenaDef, formation_list );
    if( formation_list.empty() )
    {
        HandleErrCode(puser, kErrFriendFightNoOpenSinglearenaTwo, 0);
        return;
    }

    CFight *pcfight = fight::Interface( kFightTypeFriend );
    if ( NULL == pcfight )
        return;

    SFight * psfight = pcfight->AddFightToPlayer( puser, msg.friend_id );

    if ( NULL == psfight )
        return;

    fight::ReplyFightInfo( psfight );
}

MSG_FUNC( PQFightErrorLog )
{
    if ( msg.data.size <= 0 || msg.data.data.length() <= 0 )
        return;

    std::string out;
    out.resize( msg.data.size );

    uLongf dst_size = out.size();

    if ( Z_OK != uncompress( (Bytef*)&out[0], &dst_size, (Bytef*)&msg.data.data[0], msg.data.data.length() ) )
        return;

    back::write( "fight_failure.txt", "%s ---- \n%s\n\n", time2str( server::local_time() ).c_str(), out.c_str() );
    back::write( "fight_failure.txt", "" );
}

MSG_FUNC( PQCommonFightAuto )
{
    QU_ON( puser, msg.role_id );

    if( !singlearena::CheckCD( puser ) )
    {
        HandleErrCode(puser, kErrSingleArenaCD, 0);
        return;
    }

    if( !singlearena::CheckTimes( puser ) )
    {
        HandleErrCode(puser, kErrSingleArenaTimes, 0);
        return;
    }


    CFight *pcfight = fight::Interface( kFightTypeCommonAuto );
    if ( NULL == pcfight )
        return;

    SFight * psfight = pcfight->AddFightToMonster( puser, msg.target_id );
    if ( NULL == psfight )
        return;

    fight::ReplyFightInfoToFightSvr( psfight );
}

