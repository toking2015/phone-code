#include "fight.h"
#include "user_dc.h"
#include "user_imp.h"
#include "formation_imp.h"
#include "resource/r_monsterext.h"
#include "resource/r_trialext.h"
#include "fight_imp.h"
#include "fight_dc.h"
#include "monster_imp.h"
#include "local.h"
#include "luamgr.h"
#include "misc.h"
#include "trial_imp.h"
#include "coin_imp.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "pro.h"
#include "server.h"

SFight* CFightTrial::AddFightToMonster( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = trial::GetFightType(puser->ext.trial_id);
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

void CFightTrial::SetFightInfo( SFight *psfight )
{
    uint32 guid = 0;
    uint32 user_level = 0;
    for ( std::vector< SSoldier >::iterator iter = psfight->soldier_list.begin();
        iter != psfight->soldier_list.end();
        ++iter )
    {
        SSoldier &soldier = *iter;
        SUser *puser = theUserDC.find( soldier.role_id );
        if ( NULL == puser )
            return;
        if ( puser->data.simple.team_level > user_level )
            user_level = puser->data.simple.team_level;

        SFightPlayerInfo play_info;
        play_info.guid = ++guid;
        play_info.player_guid = puser->guid;
        play_info.camp = iter->camp;
        play_info.attr = kAttrPlayer;

        std::vector<SUserFormation> formation_list;
        formation::GetFormation( puser, trial::GetFormationType(puser->ext.trial_id), formation_list );
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
            uint32 equip_type = 0;
            if ( soldier::GetSoldierOccu( puser, formation.guid, equip_type ) )
                trial::AddTrialBuff( puser->ext.trial_id, equip_type, fight_soldier.odd_list);

            play_info.soldier_list.push_back( fight_soldier );
        }

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

        trial::SetMonster(iter->role_id, user_level, play_info, guid );
        //添加图腾BUFF
        totem::AddTotemBuff( iter->role_id, play_info, kTotemPacketNormal );
        psfight->fight_info_list.push_back( play_info );
    }

}

void CFightTrialSurvival::ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins )
{
    SUser *puser = theUserDC.find( psfight->ack_id );
    if ( NULL == puser )
        return;

    SFightEndInfo &info = psfight->fightEndInfo[kFightLeft];

    CTrialData::SData *pdata = theTrialExt.Find( puser->ext.trial_id );
    if ( NULL == pdata )
        return;
    //扣除体力
    /*
    S3UInt32 take_coin;
    take_coin.cate = kCoinStrength;
    take_coin.val = pdata->strength_cost;

    uint32 ret = coin::check_take( puser, take_coin );
    if ( 0 != ret )
    {
        HandleErrCode(puser, kErrCoinLack, ret);
        return;
    }
    */
    //是否超过次数
    if ( puser->data.trial_map[puser->ext.trial_id].try_count >= pdata->try_count )
        return;

    /*
    coin::take( puser, take_coin, kPathTrialSurvival);
    //增加经验
    S3UInt32 give_coin;
    give_coin.cate = kCoinTeamXp;
    give_coin.val = pdata->strength_cost;
    coin::give( puser, give_coin, kPathTrialSurvival);
    coins.push_back(give_coin);
    */
    if ( 0 == server::get_local_sub_day( puser->ext.trial_time ) )
    {
        //添加次数
        trial::AddTry( puser, puser->ext.trial_id );
        //添加Val
        trial::AddVal( puser, puser->ext.trial_id, info.recover + info.hurt );
    }
}

void CFightTrialStrength::ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins )
{
    SUser *puser = theUserDC.find( psfight->ack_id );
    if ( NULL == puser )
        return;

    SFightEndInfo &info = psfight->fightEndInfo[kFightLeft];

    CTrialData::SData *pdata = theTrialExt.Find( puser->ext.trial_id );
    if ( NULL == pdata )
        return;
    //扣除体力
    /*
    S3UInt32 take_coin;
    take_coin.cate = kCoinStrength;
    take_coin.val = pdata->strength_cost;

    uint32 ret = coin::check_take( puser, take_coin );
    if ( 0 != ret )
    {
        HandleErrCode(puser, kErrCoinLack, ret);
        return;
    }
    */
    //是否超过次数
    if ( puser->data.trial_map[puser->ext.trial_id].try_count >= pdata->try_count )
        return;

    /*
    coin::take( puser, take_coin, kPathTrialStrength);
    //增加经验
    S3UInt32 give_coin;
    give_coin.cate = kCoinTeamXp;
    give_coin.val = pdata->strength_cost;
    coin::give( puser, give_coin, kPathTrialStrength);
    coins.push_back(give_coin);
    */

    if ( 0 == server::get_local_sub_day( puser->ext.trial_time ) )
    {
        //添加次数
        trial::AddTry( puser, puser->ext.trial_id );
        //添加Val
        trial::AddVal( puser, puser->ext.trial_id, info.recover + info.hurt );
    }
}

void CFightTrialAgile::ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins )
{
    SUser *puser = theUserDC.find( psfight->ack_id );
    if ( NULL == puser )
        return;

    SFightEndInfo &info = psfight->fightEndInfo[kFightLeft];

    CTrialData::SData *pdata = theTrialExt.Find( puser->ext.trial_id );
    if ( NULL == pdata )
        return;
    //扣除体力
    /*
    S3UInt32 take_coin;
    take_coin.cate = kCoinStrength;
    take_coin.val = pdata->strength_cost;

    uint32 ret = coin::check_take( puser, take_coin );
    if ( 0 != ret )
    {
        HandleErrCode(puser, kErrCoinLack, ret);
        return;
    }
    */
    //是否超过次数
    if ( puser->data.trial_map[puser->ext.trial_id].try_count >= pdata->try_count )
        return;

    /*
    coin::take( puser, take_coin, kPathTrialAgile);
    //增加经验
    S3UInt32 give_coin;
    give_coin.cate = kCoinTeamXp;
    give_coin.val = pdata->strength_cost;
    coin::give( puser, give_coin, kPathTrialAgile);
    coins.push_back(give_coin);
    */

    if ( 0 == server::get_local_sub_day( puser->ext.trial_time ) )
    {
        //添加次数
        trial::AddTry( puser, puser->ext.trial_id );
        //添加Val
        trial::AddVal( puser, puser->ext.trial_id, info.recover + info.hurt );
    }
}

void CFightTrialIntelligence::ExtraProc( SFight *psfight, std::vector<S3UInt32> &coins )
{
    SUser *puser = theUserDC.find( psfight->ack_id );
    if ( NULL == puser )
        return;

    SFightEndInfo &info = psfight->fightEndInfo[kFightLeft];

    CTrialData::SData *pdata = theTrialExt.Find( puser->ext.trial_id );
    if ( NULL == pdata )
        return;
    //不再扣除体力
    /*
    S3UInt32 take_coin;
    take_coin.cate = kCoinStrength;
    take_coin.val = pdata->strength_cost;

    uint32 ret = coin::check_take( puser, take_coin );
    if ( 0 != ret )
    {
        HandleErrCode(puser, kErrCoinLack, ret);
        return;
    }
    */
    //是否超过次数
    if ( puser->data.trial_map[puser->ext.trial_id].try_count >= pdata->try_count )
        return;

    //coin::take( puser, take_coin, kPathTrialAgile);
    //增加经验
    //S3UInt32 give_coin;
    //give_coin.cate = kCoinTeamXp;
    //give_coin.val = pdata->strength_cost;
    //coin::give( puser, give_coin, kPathTrialAgile);
    //coins.push_back(give_coin);

    if ( 0 == server::get_local_sub_day( puser->ext.trial_time ) )
    {
        //添加次数
        trial::AddTry( puser, puser->ext.trial_id );
        //添加Val
        trial::AddVal( puser, puser->ext.trial_id, info.recover + info.hurt );
    }
}

