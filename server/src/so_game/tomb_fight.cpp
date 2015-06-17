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
#include "tomb_imp.h"
#include "coin_imp.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "pro.h"
#include "server.h"
#include "proto/constant.h"

SFight* CFightTomb::AddFightToPlayer( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeTomb;
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
    //psfight->seqno_map[ptarget_user->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

SFight* CFightTomb::AddFightToMonster( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeTomb;
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


void CFightTomb::SetFightInfo( SFight *psfight )
{
    SUser *puser = theUserDC.find( psfight->ack_id );
    if ( NULL == puser )
        return;

    uint32 guid = 0;
    uint32 user_level = 0;
    for ( std::vector< SSoldier >::iterator iter = psfight->soldier_list.begin();
        iter != psfight->soldier_list.end();
        ++iter )
    {
        SSoldier &soldier = *iter;
        SUser *ptarget_user = theUserDC.find( soldier.role_id );
        if ( NULL == ptarget_user )
            return;
        if ( ptarget_user->data.simple.team_level > user_level )
            user_level = ptarget_user->data.simple.team_level;

        SFightPlayerInfo play_info;
        play_info.guid = ++guid;
        play_info.player_guid = ptarget_user->guid;
        play_info.camp = iter->camp;
        play_info.attr = kAttrPlayer;

        if ( kFightLeft == play_info.camp )
            play_info.totem_value = puser->data.tomb_info.totem_value_self;
        else if ( kFightRight == play_info.camp )
            play_info.totem_value = puser->data.tomb_info.totem_value_target;

        uint32 formation_type = kFormationTypeTomb;
        if ( play_info.camp == kFightRight )
        {
            play_info.isAutoFight = 1;
            formation_type = kFormationTypeTombTarget;
        }

        std::vector<SUserFormation> formation_list;
        formation::GetFormation( puser, formation_type, formation_list );
        if ( formation_list.empty() )
        {
            formation::GetFormation( ptarget_user, kFormationTypeYesterday, formation_list );
            if ( formation_list.empty() )
                formation::GetFormation( ptarget_user, kFormationTypeCommon, formation_list );
        }
        if ( formation_list.empty() )
            continue;

        for ( std::vector<SUserFormation>::iterator iter = formation_list.begin();
            iter != formation_list.end();
            ++iter )
        {
            SUserFormation &formation = *iter;
            SFightSoldier fight_soldier;
            fight_soldier.guid = ++guid;
            tomb::SetSoldier( ptarget_user, formation, fight_soldier );
            play_info.soldier_list.push_back( fight_soldier );
        }

        //添加图腾BUFF
        if ( kFightLeft == play_info.camp )
            totem::AddTotemBuff( soldier.role_id, play_info, kTotemPacketNormal);
        else if ( kFightRight == play_info.camp )
            totem::AddTotemBuff( soldier.role_id, play_info, kTotemPacketYesterday );
        //重新设置血量
        for( std::vector<SFightSoldier>::iterator jter = play_info.soldier_list.begin();
            jter != play_info.soldier_list.end(); )
        {
            SUserSoldier soldier;
            if ( kFightLeft == play_info.camp )
            {
                if ( soldier::GetSoldier(puser, jter->soldier_guid, soldier, kSoldierTypeTombSelf) && jter->attr != kAttrTotem )
                {
                    if ( soldier.hp == 0 )
                    {
                        jter = play_info.soldier_list.erase(jter);
                        continue;
                    }
                    jter->hp = soldier.hp;
                    jter->rage = soldier.mp;
                }
            }
            else if ( kFightRight == play_info.camp )
            {
                fightextable::GetFightExtAble( ptarget_user, jter->soldier_guid, kAttrSoldierYesterday, jter->fight_ext_able);
                if ( soldier::GetSoldier(puser, jter->soldier_guid, soldier, kSoldierTypeTombTarget) && jter->attr != kAttrTotem )
                {
                    if ( soldier.hp == 0 )
                    {
                        jter = play_info.soldier_list.erase(jter);
                        continue;
                    }
                    jter->hp = soldier.hp;
                    jter->rage = soldier.mp;
                }
            }

            ++jter;
        }

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
        play_info.totem_value = puser->data.tomb_info.totem_value_target;

        tomb::SetMonster(puser, iter->role_id, user_level, play_info, guid );

        //添加图腾BUFF
        totem::AddTotemBuff(iter->role_id, play_info, kTotemPacketYesterday );

        //重新设置血量
        for( std::vector<SFightSoldier>::iterator jter = play_info.soldier_list.begin();
            jter != play_info.soldier_list.end(); )
        {
            SUserSoldier soldier;
            if ( soldier::GetSoldier(puser, jter->soldier_guid, soldier, kSoldierTypeTombTarget) && jter->attr != kAttrTotem )
            {
                if ( soldier.hp == 0 )
                {
                    jter = play_info.soldier_list.erase(jter);
                    continue;
                }
                jter->hp = soldier.hp;
                jter->rage = soldier.mp;
            }
            ++jter;
        }

        psfight->fight_info_list.push_back( play_info );
    }
}

void CFightTomb::ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins )
{
    SUser *puser = theUserDC.find( psfight->ack_id );
    if ( NULL == puser )
        return;

    //如果是撤退
    if ( 0 != psfight->is_quit || 0 != psfight->is_roundout )
        return;

    //更新血量 图腾值
    for(std::vector<SFightPlayerSimple>::iterator iter = psfight->soldierEndList.begin();
        iter != psfight->soldierEndList.end();
        ++iter )
    {
        if ( iter->camp == kFightLeft )
        {
            fight::UpdateSoldierHpRage(puser, kSoldierTypeTombSelf, *iter );
            soldier::ReplyList(puser,kSoldierTypeTombSelf);
            puser->data.tomb_info.totem_value_self = iter->totem_value;
        }
        else if ( iter->camp == kFightRight )
        {
            if (psfight->win_camp == kFightLeft)
            {
                puser->data.soldier_map[kSoldierTypeTombTarget].clear();
                puser->data.tomb_info.totem_value_target = iter->totem_value;
                soldier::ReplyList(puser,kSoldierTypeTombTarget);
            }
            else
            {
                fight::UpdateSoldierHpRage(puser, kSoldierTypeTombTarget, *iter );
                soldier::ReplyList(puser,kSoldierTypeTombTarget);
                puser->data.tomb_info.totem_value_target = iter->totem_value;
            }
        }
    }

    if ( psfight->win_camp == kFightLeft )
    {
        //如果是怪物关那么怪物+1
        if ( 0 == (puser->data.tomb_info.win_count + 1)%5 && 0 != psfight->def_id )
        {
            bool is_find = false;
            for(std::vector<SUserKillInfo>::iterator iter = puser->data.tomb_info.history_kill_count.begin();
                iter != puser->data.tomb_info.history_kill_count.end();
                ++iter )
            {
                if ( psfight->def_id == iter->monster_id )
                {
                    iter->count++;
                    is_find = true;
                }
            }
            if ( !is_find )
            {
                SUserKillInfo info;
                info.monster_id = psfight->def_id;
                info.count = 1;
                puser->data.tomb_info.history_kill_count.push_back(info);
            }
        }
        tomb::AddWinCount(puser);
    }
}


