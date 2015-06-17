#include "fight.h"
#include "user_dc.h"
#include "user_imp.h"
#include "coin_imp.h"
#include "formation_imp.h"
#include "resource/r_monsterext.h"
#include "fight_imp.h"
#include "fight_dc.h"
#include "monster_imp.h"
#include "totem_imp.h"
#include "local.h"
#include "luamgr.h"
#include "misc.h"
#include "fight_event.h"

//CFight
CFight::CFight()
{
}

CFight::~CFight()
{
}

void CFight::AddSoldier( SFight *psfight, uint32 role_id, uint32 camp )
{
    if ( NULL == psfight )
        return;
    SSoldier soldier;
    soldier.role_id = role_id;
    soldier.camp = camp;
    psfight->soldier_list.push_back( soldier );
}

void CFight::AddMonster( SFight *psfight, uint32 monster_id, uint32 camp )
{
    if ( NULL == psfight )
        return;
    CMonsterData::SData *pmonster = theMonsterExt.Find( monster_id );
    if ( NULL == pmonster )
        return;

    SSoldier soldier;
    soldier.role_id = monster_id;
    soldier.camp = camp;
    psfight->monster_list.push_back( soldier );
}

void CFight::ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins )
{
    if ( NULL == psfight )
        return;

}

void CFight::AddBuff( SFight *psfight, uint32 guid, std::vector<SFightOdd> &odd_list )
{
    if ( NULL == psfight )
        return;

}

bool CFight::ExtraDo( SFight *psfight )
{
    if ( NULL == psfight )
        return false;
    return false;
}


SFight* CFight::AddFightToPlayer( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeCommon;
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
    user::SetFightId( ptarget_user, psfight->fight_id );

    //初始化seqno_map
    psfight->seqno_map[puser->guid] = 0;
    psfight->seqno_map[ptarget_user->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

SFight* CFight::AddFightToMonster( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeCommon;
    psfight->box_randomseed = (uint32)rand_r( thread_rand_seed() );
    psfight->fight_randomseed = (uint32)rand_r( thread_rand_seed() );

    user::SetFightId( puser, psfight->fight_id );

    psfight->ack_id = puser->guid;
    AddSoldier( psfight, puser->guid, kFightLeft );

    CMonsterData::SData *pmonster = theMonsterExt.Find( target_id );
    if ( NULL == pmonster )
    {
        theFightDC.del(psfight->fight_id);
        return NULL;
    }

    psfight->def_id = target_id;
    for( std::vector<uint32>::iterator jter = pmonster->fight_monster.begin();
        jter != pmonster->fight_monster.end();
        ++jter )
    {
        AddMonster( psfight, *jter, kFightRight );
    }
    
    psfight->help_monster = pmonster->help_monster;

    //初始化seqno_map
    psfight->seqno_map[puser->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

void CFight::SetFightInfo( SFight *psfight )
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

        std::vector<SUserFormation> formation_list;
        formation::GetFormation( puser, kFormationTypeCommon, formation_list );
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
        fight::SetMonster( psfight->help_monster, play_info, guid );

        //添加图腾BUFF
        totem::AddTotemBuff( soldier.role_id, play_info, kTotemPacketNormal );
        psfight->fight_info_list.push_back( play_info );
    }

    //怪物属性
    for ( std::vector< SSoldier >::iterator iter = psfight->monster_list.begin();
        iter != psfight->monster_list.end();
        ++iter )
    {
        SFightPlayerInfo play_info;
        play_info.guid = ++guid;
        play_info.camp = iter->camp;
        play_info.attr = kAttrMonster;
        play_info.isAutoFight = 1;

        fight::SetMonster(iter->role_id, play_info, guid );
        //添加图腾BUFF
        totem::AddTotemBuff(iter->role_id, play_info, kTotemPacketNormal );
        psfight->fight_info_list.push_back( play_info );
    }
}

void CFight::OnFightClientEnd(SFight *psfight, std::vector<S3UInt32>& coins )
{
    if ( psfight->win_camp == kFightLeft && !psfight->monster_list.empty() )
    {
        SUser *puser = theUserDC.find( psfight->ack_id );
        if ( NULL == puser )
            return;

        for( std::vector<SSoldier>::iterator jter = psfight->monster_list.begin();
            jter != psfight->monster_list.end();
            ++jter )
        {
            if ( kFightLeft == jter->camp )
                continue;
            event::dispatch( SEventFightKillMonster( puser, kPathFightNormal, jter->role_id ) );
        }

        std::vector<S3UInt32> coin_list = monster::GetMonsterDrop(puser, psfight->def_id);
        coins.insert( coins.begin(), coin_list.begin(), coin_list.end() );

        coin::give( puser, coin_list, kPathDrop );
    }
    //根据不同战斗TYPE 额外处理
    ExtraProc(psfight, coins);
    
    //战斗结束处理这个一般都在最后
    SUser *puser = theUserDC.find( psfight->ack_id );
    if ( NULL == puser )
        return;
    user::DelFightId(puser);
}

bool CFight::NeedCheck( SFight *psfight )
{
    return true;
}
