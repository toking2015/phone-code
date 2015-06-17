#include "fight.h"
#include "user_dc.h"
#include "user_imp.h"
#include "formation_imp.h"
#include "resource/r_monsterext.h"
#include "fight_imp.h"
#include "fight_dc.h"
#include "monster_imp.h"
#include "local.h"
#include "luamgr.h"
#include "misc.h"
#include "pro.h"
#include "singlearena_imp.h"
#include "totem_imp.h"
#include "singlearena_dc.h"
#include "singlearena_event.h"
#include "fightrecord_imp.h"
#include "fightrecord_dc.h"

SFight* CFightSingleArenaMonster::AddFightToPlayer( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeSingleArenaPlayer;
    psfight->box_randomseed = (uint32)rand_r( thread_rand_seed() );
    psfight->fight_randomseed = (uint32)rand_r( thread_rand_seed() );

    user::SetFightId( puser, psfight->fight_id );

    psfight->ack_id = puser->guid;
    AddSoldier( psfight, puser->guid, kFightLeft );

    SUser *ptarget_user = theUserDC.find( target_id );
    if ( NULL == ptarget_user )
    {
        theFightDC.del(psfight->fight_id);
        return NULL;
    }
    psfight->def_id = target_id;
    AddSoldier( psfight, target_id, kFightRight );
    //user::SetFightId( ptarget_user, psfight->fight_id );

    //初始化seqno_map
    psfight->seqno_map[puser->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

SFight* CFightSingleArenaMonster::AddFightToMonster( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeSingleArenaMonster;
    psfight->box_randomseed = (uint32)rand_r( thread_rand_seed() );
    psfight->fight_randomseed = (uint32)rand_r( thread_rand_seed() );

    user::SetFightId( puser, psfight->fight_id );

    psfight->ack_id = puser->guid;
    AddSoldier( psfight, puser->guid, kFightLeft );
    psfight->def_id = target_id;

    //初始化seqno_map
    psfight->seqno_map[puser->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

//因为有分pvp与pve,所以pvp直接用父类的，pve就有这个函数
void CFightSingleArenaMonster::SetFightInfo( SFight *psfight )
{
    uint32 guid = 0;
    for ( std::vector< SSoldier >::iterator iter = psfight->soldier_list.begin();
        iter != psfight->soldier_list.end();
        ++iter )
    {
        SSoldier &soldier = *iter;
        SUser *puser = theUserDC.find( soldier.role_id );
        if ( NULL == puser )
            return;

        SFightPlayerInfo play_info;
        play_info.guid = ++guid;
        play_info.player_guid = puser->guid;
        play_info.camp = iter->camp;
        play_info.attr = kAttrPlayer;
        play_info.isAutoFight = 1;

        std::vector<SUserFormation> formation_list;
        uint32   formationtype = kFormationTypeSingleArenaAct;

        if ( psfight->ack_id != puser->guid )
            formationtype = kFormationTypeSingleArenaDef;

        formation::GetFormation( puser, formationtype, formation_list );


        if ( formation_list.empty() )
            continue;

        for ( std::vector<SUserFormation>::iterator iter = formation_list.begin();
            iter != formation_list.end();
            ++iter )
        {
            SUserFormation &formation = *iter;
            SFightSoldier fight_soldier;
            fight_soldier.guid = ++guid;
            fight::SetSoldier( puser, formation, fight_soldier );
            play_info.soldier_list.push_back( fight_soldier );
        }

        //添加图腾BUFF
        totem::AddTotemBuff( soldier.role_id, play_info, kTotemPacketNormal );
        psfight->fight_info_list.push_back( play_info );
    }

    if( psfight->def_id < MAX_CREATE_OPPONENT )
    {
        //怪物属性
        std::vector<SUserFormation> formation_list;
        theSingleArenaDC.find_formation( psfight->ack_id, psfight->def_id, formation_list );

        SFightPlayerInfo play_info;
        play_info.guid = ++guid;
        play_info.camp = kFightRight;
        play_info.attr = kAttrMonster;
        play_info.isAutoFight = 1;
        for ( std::vector< SUserFormation >::iterator iter = formation_list.begin();
            iter != formation_list.end();
            ++iter )
        {
            SUserFormation &formation = *iter;
            SFightSoldier fight_soldier;
            fight_soldier.guid = ++guid;
            fight_soldier.fight_index = iter->formation_index;
            if ( formation.attr == kAttrSoldier )
                fight::SetMonsterSoldier( formation.guid, fight_soldier, formation_list );
            else if( formation.attr == kAttrTotem )
                fight::SetTotem( formation.guid, fight_soldier );
            play_info.soldier_list.push_back( fight_soldier );
        }
        //添加图腾BUFF
        totem::AddTotemBuff( 0, play_info, kTotemPacketNormal );
        psfight->fight_info_list.push_back( play_info );
    }
}

void CFightSingleArenaMonster::ExtraProc( SFight *psfight, std::vector<S3UInt32>& coins )
{
    //保存战斗协议
    SUser *puser = theUserDC.find( psfight->ack_id );
    if ( puser )
    {
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


        if( singlearena::CheckRank( puser, psfight->def_id, 1 ) )
            return;

        singlearena::SetCD( puser );
        singlearena::SetTimes( puser );

        singlearena::ResetRefresh( puser );

        if ( 0 != psfight->fight_record.fight_id )
        {
            uint32 record_id = fightrecord::Save( psfight );
            singlearena::AddLog( psfight->ack_id, record_id, psfight->def_id, psfight->win_camp );
        }

        singlearena::SendBattleReward( psfight->ack_id, psfight->def_id, psfight->win_camp );
        singlearena::UpdateRank( psfight->ack_id, psfight->def_id, psfight->win_camp );

        singlearena::Refresh( puser );

        event::dispatch( SEventSingleArenaBattle( puser, kPathSingleArena, psfight->ack_id, psfight->win_camp) );
    }


}

