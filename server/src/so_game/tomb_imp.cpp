#include "tomb_imp.h"
#include "local.h"
#include "proto/constant.h"
#include "proto/fight.h"
#include "misc.h"
#include "fight.h"
#include "pro.h"
#include "server.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "fight_imp.h"
#include "formation_imp.h"
#include "resource/r_monsterext.h"
#include "resource/r_totemextext.h"
#include "resource/r_totemext.h"
#include "resource/r_monsterfightconfext.h"
#include "resource/r_rewardext.h"
#include "resource/r_tombext.h"
#include "resource/r_tombmonsterlvext.h"
#include "resource/r_tombrewardbaseext.h"
#include "resource/r_tombrewardext.h"
#include "resource/r_oddext.h"
#include "resource/r_soldierext.h"
#include "resource/r_levelext.h"
#include "resource/r_globalext.h"
#include "coin_imp.h"
#include "user_imp.h"
#include "singlearena_imp.h"
#include "rank_imp.h"
#include "tomb_event.h"

namespace tomb
{

struct TombCmp
{
    uint32 attr;
    uint32 target_id;
    TombCmp(uint32 _a, uint32 _t) : attr(_a), target_id(_t) { }
    bool operator()(STombTarget &target)
    {
        return (target.attr == attr && target.target_id == target_id);
    }
};

uint32 GetSoldierType( uint32 id )
{
    switch(id)
    {
    case kFormationTypeTombTarget:
        return kSoldierTypeYesterday;
    case kFormationTypeTomb:
    case kFormationTypeCommon:
        return kSoldierTypeCommon;
    }
    return 0;
}

void Fight(SUser *puser, uint32 player_index, uint32 player_guid, std::vector<SUserFormation> &list)
{
    uint32 open_time = server::get<uint32>("open_time");
    if( 0 == server::get_local_sub_day( open_time ) )
    {
        HandleErrCode(puser, kErrTombNotOpen, 0);
        return;
    }

    if ( puser->data.tomb_target_list.size() != kTombPart * (kTombPartCount+1) )
    {
        HandleErrCode(puser, kErrTombPlayerData, 0 );
        return;
    }
    //容错
    if ( puser->data.tomb_info.win_count != player_index )
        return;

    if ( puser->data.tomb_info.reward_count != puser->data.tomb_info.win_count )
    {
        HandleErrCode(puser, kErrTombRewardNotGet, 0 );
        return;
    }

    STombTarget target = puser->data.tomb_target_list[player_index];
    if ( target.target_id != player_guid )
        return;

    //阵型是否OK
    if( !formation::Set( puser, list, kFormationTypeTomb) )
        return;

    CFight *pcfight = fight::Interface( kFightTypeTomb );
    SFight *psfight = NULL;
    if ( NULL == pcfight )
        return;
    if ( target.attr == kAttrSoldier )
    {
        psfight = pcfight->AddFightToPlayer( puser, target.target_id );
    }
    else if ( target.attr == kAttrMonster )
    {
        psfight = pcfight->AddFightToMonster( puser, target.target_id );
    }
    if ( NULL != psfight )
        fight::ReplyFightInfo(psfight);

    event::dispatch( SEventTombFight(puser, player_index, kPathTombFight ) );

}

uint32 tomb_reward_get_value( CTombRewardData::SData *pdata )
{
    return pdata->percent;
}

uint32 tomb_reward_get_extra_value( CTombRewardData::SData *pdata )
{
    return pdata->extra_percent;
}

void RewardGet(SUser *puser, uint32 reward_index)
{
    if ( reward_index + 1 != puser->data.tomb_info.win_count )
        return;
    if ( 0 != puser->data.tomb_target_list[reward_index].reward )
        return;

    CTombRewardBaseData::SData *pbase = theTombRewardBaseExt.Find( reward_index+1 );
    if ( NULL == pbase )
        return;

    uint32 quality = kBoxQualityCopper;
    if ( (reward_index + 1)%(kTombPartCount+1) == 0 )
        quality = kBoxQualitySilver;

    if ( (reward_index + 1)%(kTombPart*(kTombPartCount+1)) == 0 )
        quality = kBoxQualityGolden;

    std::vector<CTombRewardData::SData*> list = theTombRewardExt.GetRandomList( quality, puser->data.simple.team_level);
    if ( list.empty() )
    {
        HandleErrCode( puser, kErrTombRewardDataNoExitLevel, 0 );
        return;
    }

    CTombRewardData::SData *pdata = round_rand( list, tomb_reward_get_value );
    if ( NULL == pdata )
    {
        HandleErrCode( puser, kErrTombRewardDataNoExitLevel, 0 );
        return;
    }

    CTombRewardData::SData *pextra_data = round_rand( list, tomb_reward_get_extra_value );
    if ( NULL == pextra_data )
    {
        HandleErrCode( puser, kErrTombRewardDataNoExitLevel, 0 );
        return;
    }

    PRTombRewardGet rep;
    bccopy( rep, puser->ext );

    CRewardData::SData* preward_rand = theRewardExt.Find( pdata->reward );
    CRewardData::SData* preward_rand_extra = theRewardExt.Find( pextra_data->extra_reward );
    CRewardData::SData* preward_base = theRewardExt.Find( pbase->reward );
    CRewardData::SData* preward_tomb_coin = theRewardExt.Find( pbase->tomb_coin );
    if ( NULL == preward_rand || NULL == preward_base )
    {
        HandleErrCode(puser, kErrTombRewardDataNoExit, 0);
        return;
    }
    //等级相关系数
    std::vector<S3UInt32> base_coin_list = preward_base->coins;
    CLevelData::SData *plv_data = theLevelExt.Find( puser->data.simple.team_level);
    if ( NULL != plv_data )
    {
        for( std::vector<S3UInt32>::iterator iter = base_coin_list.begin();
            iter != base_coin_list.end();
            ++iter )
        {
            iter->val = (uint32)(iter->val * (plv_data->tomb_ratio/10000));
        }
    }
    //vip增加金币
    uint32 vip_level = theGlobalExt.get<uint32>( "tomb_vip_add_money_level" );
    std::vector<S3UInt32> rand_coins = preward_rand->coins;
    if ( puser->data.simple.vip_level >= vip_level )
    {
        for( std::vector<S3UInt32>::iterator iter = base_coin_list.begin();
            iter != base_coin_list.end();
            ++iter )
        {
            if ( iter->cate == kCoinMoney )
                iter->val = (uint32)(iter->val * 1.5);
        }
    }

    coin::give(puser, rand_coins, kPathTombRewardGet);
    coin::give(puser, base_coin_list, kPathTombRewardGet);
    if ( NULL != preward_rand_extra )
    {
        std::vector<S3UInt32> change_coins = soldier::ChangeSoldierToOther(puser, preward_rand_extra->coins);
        rep.reward_list.insert(rep.reward_list.end(), change_coins.begin(), change_coins.end() );
        coin::give( puser, preward_rand_extra->coins, kPathTombRewardGet);
    }
    rep.reward_list.insert(rep.reward_list.end(), base_coin_list.begin(), base_coin_list.end() );
    rep.reward_list.insert(rep.reward_list.end(), rand_coins.begin(), rand_coins.end() );
    if( NULL != preward_tomb_coin && puser->data.tomb_info.try_count_now == 1)
    {
        rep.reward_list.insert(rep.reward_list.end(), preward_tomb_coin->coins.begin(), preward_tomb_coin->coins.end() );
        coin::give(puser, preward_tomb_coin->coins, kPathTombRewardGet);
    }

    puser->data.tomb_info.reward_count++;
    puser->data.tomb_info.totem_value_target = 0;
    puser->data.tomb_target_list[reward_index].reward = 1;
    rep.target = puser->data.tomb_target_list[reward_index];
    local::write(local::access, rep );
    ReplyInfo(puser);

    //修改阵型
    puser->data.formation_map[kFormationTypeTombTarget].clear();
    formation::ReplyList(puser, kFormationTypeTombTarget);

    event::dispatch( SEventTombRewardGet(puser, reward_index+1, kPathTombRewardGet ) );
}

void Reset(SUser *puser)
{
    if ( puser->data.tomb_target_list.empty() )
        return;

    uint32 win_count = puser->data.tomb_info.win_count;
    if ( win_count > 0 && 0 == puser->data.tomb_target_list[win_count-1].reward )
    {
        HandleErrCode(puser, kErrTombRewardNotGet, 0 );
        return;
    }

    uint32 max_count = 1;
    uint32 vip_level = theGlobalExt.get<uint32>( "tomb_vip_add_count_level" );
    if ( puser->data.simple.vip_level >= vip_level )
        max_count++;

    if ( puser->data.tomb_info.try_count >= max_count )
        return;

    RandomCreate(puser);
    puser->data.tomb_info.try_count++;
    puser->data.tomb_info.try_count_now = puser->data.tomb_info.try_count;
    puser->data.tomb_info.win_count = 0;
    puser->data.tomb_info.reward_count = 0;
    puser->data.tomb_info.totem_value_self = 0;
    puser->data.tomb_info.totem_value_target = 0;
    puser->data.tomb_info.history_reset_count++;

    //如果是当天第一次重置那么清空max_win_count
    if ( 1 == puser->data.tomb_info.try_count )
        puser->data.tomb_info.max_win_count = 0;

    puser->data.soldier_map[kSoldierTypeTombSelf].clear();
    soldier::ReplyList(puser,kSoldierTypeTombSelf);
    puser->data.soldier_map[kSoldierTypeTombTarget].clear();
    soldier::ReplyList(puser,kSoldierTypeTombTarget);

    puser->data.formation_map[kFormationTypeTombTarget].clear();
    formation::ReplyList(puser, kFormationTypeTombTarget);

    PRTombReset rep;
    bccopy(rep, puser->ext);
    rep.tomb_info = puser->data.tomb_info;
    rep.tomb_target_list = puser->data.tomb_target_list;
    local::write( local::access, rep );

    ReplyInfo(puser);
}

void PlayerReset(SUser *puser, uint32 player_index)
{
    //容错
    if ( puser->data.tomb_info.win_count != player_index )
        return;
    if ( puser->data.tomb_target_list.empty() )
        return;
    if ( puser->data.tomb_target_list[player_index].attr == kAttrMonster )
        return;
    uint32 part = player_index/kTombPart+1;

    uint32 cost_i = theGlobalExt.get<uint32>("tomb_player_reset_cost");
    S3UInt32 cost;
    cost.cate = kCoinGold;
    cost.val = cost_i;

    uint32 ret = coin::check_take( puser, cost );
    if ( 0 != ret )
    {
        HandleErrCode(puser, kErrCoinLack, ret );
        return;
    }
    coin::take( puser, cost, kPathTombPlayerReset );

    uint32 target_id = RandomCreatePlayer(puser, part);
    puser->data.tomb_target_list[player_index].target_id = target_id;
    puser->data.tomb_info.totem_value_target = 0;
    puser->data.soldier_map[kSoldierTypeTombTarget].clear();
    soldier::ReplyList(puser,kSoldierTypeTombTarget);
    puser->data.formation_map[kFormationTypeTombTarget].clear();
    formation::ReplyList(puser,kFormationTypeTombTarget);

    PRTombPlayerReset rep;
    bccopy( rep, puser->ext );
    rep.player_index = player_index;
    rep.target = puser->data.tomb_target_list[player_index];
    local::write(local::access, rep );
    ReplyInfo(puser);
}

void MopUp(SUser *puser)
{
    //一定是重置2次之后才能扫荡
    if ( 2 != puser->data.tomb_info.try_count )
        return;

    //如果已经胜利过那么就不能扫荡
    if ( 0 != puser->data.tomb_info.win_count )
        return;

    //把所有武将的血量变成0
    std::map<uint32, SUserSoldier> &soldier_list = puser->data.soldier_map[kSoldierTypeCommon];
    std::map<uint32, SUserSoldier> &soldier_list_tomb = puser->data.soldier_map[kSoldierTypeTombSelf];
    soldier_list_tomb.clear();
    for( std::map<uint32, SUserSoldier>::iterator iter = soldier_list.begin();
        iter != soldier_list.end();
        ++iter )
    {
        SUserSoldier soldier = iter->second;
        soldier.hp = 0;
        soldier_list_tomb[soldier.guid] = soldier;
    }

    PRTombMopUp rep;
    bccopy(rep, puser->ext);
    //获取奖励
    CLevelData::SData *plv_data = theLevelExt.Find( puser->data.simple.team_level);
    for( uint32 i = puser->data.tomb_info.reward_count+1; i <= puser->data.tomb_info.max_win_count; ++i )
    {

        uint32 quality = kBoxQualityCopper;
        if ( (i+ 1)%(kTombPartCount+1) == 0 )
            quality = kBoxQualitySilver;

        if ( (i+ 1)%(kTombPart*(kTombPartCount+1)) == 0 )
            quality = kBoxQualityGolden;

        std::vector<CTombRewardData::SData*> list = theTombRewardExt.GetRandomList( quality, puser->data.simple.team_level);
        if ( list.empty() )
            continue;

        std::vector<uint32> reward_list;
        CTombRewardData::SData *pdata = round_rand( list, tomb_reward_get_value );
        if ( NULL == pdata )
        {
            HandleErrCode( puser, kErrTombRewardDataNoExitLevel, 0 );
            continue;
        }

        CTombRewardData::SData *pextra_data = round_rand( list, tomb_reward_get_extra_value );
        if ( NULL == pextra_data )
        {
            HandleErrCode( puser, kErrTombRewardDataNoExitLevel, 0 );
            continue;
        }

        CTombRewardBaseData::SData *pbase = theTombRewardBaseExt.Find( i );
        CRewardData::SData* preward_rand = theRewardExt.Find( pdata->reward );
        CRewardData::SData* preward_rand_extra = theRewardExt.Find( pextra_data->extra_reward );
        CRewardData::SData* preward_base = theRewardExt.Find( pbase->reward );
        if ( NULL == preward_rand || NULL == preward_base )
            continue;

        std::vector<S3UInt32> base_coin_list = preward_base->coins;
        if ( NULL != plv_data )
        {
            for( std::vector<S3UInt32>::iterator iter = base_coin_list.begin();
                iter != base_coin_list.end();
                ++iter )
            {
                iter->val = (uint32)(iter->val * (plv_data->tomb_ratio/10000));
            }
        }

        //vip增加金币
        uint32 vip_level = theGlobalExt.get<uint32>( "tomb_vip_add_money_level" );
        std::vector<S3UInt32> rand_coins = preward_rand->coins;
        if ( puser->data.simple.vip_level >= vip_level )
        {
            for( std::vector<S3UInt32>::iterator iter = rand_coins.begin();
                iter != rand_coins.end();
                ++iter )
            {
                if ( iter->cate == kCoinMoney )
                    iter->val = (uint32)(iter->val * 1.5);
            }
        }

        std::vector<S3UInt32> coin_list;
        if ( NULL != preward_rand_extra )
        {

            std::vector<S3UInt32> change_coins = soldier::ChangeSoldierToOther(puser, preward_rand_extra->coins);
            coin_list.insert(coin_list.end(), change_coins.begin(), change_coins.end() );
            coin::give( puser, preward_rand_extra->coins, kPathTombMopUp);
        }

        coin::give(puser, rand_coins, kPathTombMopUp);
        coin::give(puser, base_coin_list, kPathTombMopUp);
        coin_list.insert(coin_list.end(), rand_coins.begin(), rand_coins.end() );
        coin_list.insert(coin_list.end(), base_coin_list.begin(), base_coin_list.end() );

        rep.reward_list.push_back( coin_list );
        puser->data.tomb_target_list[i-1].reward = 1;
    }

    puser->data.tomb_info.win_count = puser->data.tomb_info.max_win_count;
    puser->data.tomb_info.reward_count = puser->data.tomb_info.max_win_count;

    local::write( local::access, rep );
    ReplyInfo(puser);
    soldier::ReplyList(puser,kSoldierTypeTombSelf);
}

void TimeLimit(SUser *puser)
{
    singlearena::SaveYesterday(puser);
    puser->data.tomb_info.try_count = 0;
    ReplyInfo(puser);
}

uint32 RandomCreatePlayer(SUser *puser, uint32 part)
{
    std::vector<uint32> list;
    rank::QuerySingleArena( puser->guid, kTombFront, kTombBack, list);

    //补足
    if ( list.size() < kTombPart * kTombPartCount )
    {
        LOG_ERROR("list size too small");
        return 0;
    }
    part = kTombPart - part;
    uint32 part_size = list.size()/kTombPart;

    while(true)
    {
        uint32 rand_index = (uint32)rand_r( thread_rand_seed() )%part_size;
        uint32 index = part*part_size + rand_index;
        uint32 target_id = list[index];
        std::vector<STombTarget>::iterator iter = std::find_if( puser->data.tomb_target_list.begin(), puser->data.tomb_target_list.end(), TombCmp(kAttrSoldier,target_id));
        if ( iter == puser->data.tomb_target_list.end() )
        {
            return target_id;
        }
    }
}

void RandomCreate(SUser *puser)
{
    puser->data.tomb_target_list.clear();

    std::vector<uint32> monster_list;
    monster_list.push_back(1);
    monster_list.push_back(2);
    monster_list.push_back(3);
    monster_list.push_back(4);
    random_shuffle( monster_list.begin(), monster_list.end() );
    monster_list.push_back(5);

    STombTarget target;
    for( uint32 i = 1; i <= kTombPart; ++i )
    {
        //添加玩家数据
        for( uint32 j = 0; j < kTombPartCount; ++j )
        {
            target.attr = kAttrSoldier;
            target.target_id = RandomCreatePlayer(puser, i);

            //如果这个玩家不存在就不添加 到时候用怪物补足
            std::map<uint32,std::string>::iterator iter = theUserDC.db().user_id_name.find( target.target_id );
            if ( iter == theUserDC.db().user_id_name.end() )
                continue;

            if ( 0 != target.target_id )
                puser->data.tomb_target_list.push_back(target);
        }
        //添加BOSS数据
        CTombData::SData *pdata = theTombExt.Find(monster_list[i-1]);
        if ( NULL != pdata )
        {
            target.attr = kAttrMonster;
            target.target_id = pdata->monster_id;
            //如果本关的数据不足5个那么用boss来补足
            while( puser->data.tomb_target_list.size() < i * 5 )
            {
                puser->data.tomb_target_list.push_back(target);
            }
        }
    }
}

void SetSoldier( SUser *puser, SUserFormation& formation, SFightSoldier &fight_soldier )
{
    fight_soldier.fight_index = formation.formation_index;
    if ( kAttrSoldier == formation.attr )
    {
        SUserSoldier soldier;
        uint32 soldier_type = GetSoldierType(formation.formation_type);
        if ( !soldier::GetSoldier(puser, formation.guid,soldier, soldier_type ) )
            return;
        CSoldierData::SData *psoldier = theSoldierExt.Find( soldier.soldier_id );
        if ( NULL == psoldier )
            return;
        fight_soldier.name = psoldier->name;
        fight_soldier.occupation = psoldier->occupation;
        fight_soldier.quality = soldier.quality;
        fight_soldier.attr = kAttrSoldier;
        fight_soldier.soldier_id = soldier.soldier_id;
        fight_soldier.soldier_guid = formation.guid;
        fight_soldier.level = soldier.level;
        fight_soldier.equip_type = psoldier->equip_type;
        fightextable::GetFightExtAble( puser, formation.guid, formation.attr, fight_soldier.fight_ext_able);

        soldier::GetSoldierSkill( puser, formation.guid, soldier_type, fight_soldier.skill_list );
        soldier::GetSoldierOdd( puser, formation.guid, soldier_type, fight_soldier.fight_index, fight_soldier.odd_list );
        fight_soldier.rage = soldier::GetSoldierRage( puser, formation.guid );
        fight_soldier.hp = fight_soldier.fight_ext_able.hp;
    }
    else if ( kAttrTotem == formation.attr )
    {
        uint32 packet = kTotemPacketNormal;
        if ( formation.formation_type == kFormationTypeYesterday )
            packet = kTotemPacketYesterday;

        totem::GetFightInfo(puser, packet, formation.guid, fight_soldier);
    }

}

void SetMonster( SUser *puser, uint32 monster_id, uint32 user_level, SFightPlayerInfo &play_info, uint32 &guid )
{
    CMonsterFightConfData::SData *pdata = theMonsterFightConfExt.Find( monster_id );
    if ( NULL == pdata )
        return;

    uint32 index = puser->data.tomb_info.win_count;
    float ratio = 0.1;
    uint32 id = index/(kTombPartCount+1) + 1;
    CTombData::SData *ptomb_data = theTombExt.Find(id);
    if ( NULL != ptomb_data )
    {
        ratio = ptomb_data->ratio/10000.0;
        if( 0 != (index+1)%(kTombPartCount+1) )
            ratio -= 0.1;
    }

    if ( ratio < 0.1 )
        ratio = 0.1;

    for( std::vector<S2UInt32>::iterator iter = pdata->add.begin();
        iter != pdata->add.end();
        ++iter )
    {
        CMonsterData::SData *pmonster_data = theMonsterExt.Find(iter->first);
        if ( NULL == pmonster_data )
            continue;
        SFightSoldier fight_soldier;
        fight_soldier.guid = ++guid;
        fight_soldier.soldier_id = pmonster_data->id;
        fight_soldier.soldier_guid = pmonster_data->id;
        fight_soldier.fight_index = iter->second;
        if ( !fight::GetFightIndex(play_info, iter->second) )
            continue;
        fight_soldier.name = pmonster_data->name;
        fight_soldier.attr = kAttrMonster;
        fight_soldier.rage = pmonster_data->initial_rage;
        fight_soldier.occupation = pmonster_data->occupation;
        fight_soldier.level = pmonster_data->level;
        fight_soldier.equip_type = pmonster_data->equip_type;
        GetMonsterExt(iter->first, user_level, ratio, fight_soldier.fight_ext_able);
        fight::GetMonsterSkill(iter->first,fight_soldier.skill_list);
        fight::GetMonsterOdd(iter->first, iter->second, fight_soldier.odd_list);
        fight_soldier.hp = fight_soldier.fight_ext_able.hp;

        SUserSoldier soldier;
        if ( soldier::GetSoldier(puser, fight_soldier.soldier_guid, soldier, kSoldierTypeTombTarget) )
        {
            if( soldier.hp == 0 )
                continue;
            fight_soldier.hp = soldier.hp;
            fight_soldier.rage = soldier.mp;
        }

        play_info.soldier_list.push_back( fight_soldier );
    }

    for( std::vector<S2UInt32>::iterator iter = pdata->totemadd.begin();
        iter != pdata->totemadd.end();
        ++iter )
    {
        CTotemExtData::SData *pconf_data = theTotemExtExt.Find(iter->first);
        if ( NULL == pconf_data )
            continue;

        CTotemData::SData *ptotem_data = theTotemExt.Find(pconf_data->totem_id);
        if ( NULL == ptotem_data )
            continue;
        //设置图腾属性
        SFightSoldier fight_soldier;
        fight_soldier.guid = ++guid;
        fight_soldier.fight_index = iter->second;
        fight::SetTotem( iter->first, fight_soldier );
        play_info.soldier_list.push_back( fight_soldier );
    }
}

void GetMonsterExt( uint32 monster_id, uint32 lv, float ratio, SFightExtAble &dst_able )
{
    CMonsterData::SData *pmonster_data = theMonsterExt.Find( monster_id );
    if ( NULL == pmonster_data )
        return;

    CTombMonsterLvData::SData *plv_data = theTombMonsterLvExt.Find( lv );
    if ( NULL == plv_data )
        return;

    dst_able.hp  = (uint32)(plv_data->hp * (pmonster_data->hp/10000.0) * ratio);
    dst_able.physical_ack  = (uint32)(plv_data->physical_ack * (pmonster_data->physical_ack/10000.0) * ratio);
    dst_able.physical_def  = (uint32)(plv_data->physical_def * (pmonster_data->physical_def/10000.0) * ratio);
    dst_able.magic_ack  = (uint32)(plv_data->magic_ack * (pmonster_data->magic_ack/10000.0) * ratio );
    dst_able.magic_def  = (uint32)(plv_data->magic_def * (pmonster_data->magic_def/10000.0) * ratio );
    dst_able.speed  = (uint32)(plv_data->speed * (pmonster_data->speed/10000.0) * ratio);
    dst_able.critper  = (uint32)(plv_data->critper * (pmonster_data->critper/10000.0));
    dst_able.crithurt  = (uint32)(plv_data->crithurt * (pmonster_data->crithurt/10000.0));
    dst_able.critper_def  = (uint32)(plv_data->critper_def * (pmonster_data->critper_def/10000.0));
    dst_able.crithurt_def  = (uint32)(plv_data->crithurt_def * (pmonster_data->crithurt_def/10000.0));
    dst_able.recover_critper  = (uint32)(plv_data->recover_critper * (pmonster_data->recover_critper/10000.0));
    dst_able.recover_critper_def  = (uint32)(plv_data->recover_critper_def * (pmonster_data->recover_critper_def/10000.0));
    dst_able.hitper  = (uint32)(plv_data->hitper * (pmonster_data->hitper/10000.0));
    dst_able.dodgeper  = (uint32)(plv_data->dodgeper * (pmonster_data->dodgeper/10000.0));
    dst_able.parryper  = (uint32)(plv_data->parryper * (pmonster_data->parryper/10000.0));
    dst_able.parryper_dec  = (uint32)(plv_data->parryper_dec * (pmonster_data->parryper_dec/10000.0));
    dst_able.recover_add_fix  = (uint32)(plv_data->recover_add_fix * (pmonster_data->recover_add_fix/10000.0));
    dst_able.recover_del_fix  = (uint32)(plv_data->recover_del_fix * (pmonster_data->recover_del_fix/10000.0));
    dst_able.recover_add_per  = (uint32)(plv_data->recover_add_per * (pmonster_data->recover_add_per/10000.0));
    dst_able.recover_del_per  = (uint32)(plv_data->recover_del_per * (pmonster_data->recover_del_per/10000.0));
    dst_able.rage_add_fix  = (uint32)(plv_data->rage_add_fix * (pmonster_data->rage_add_fix/10000.0));
    dst_able.rage_del_fix  = (uint32)(plv_data->rage_del_fix * (pmonster_data->rage_del_fix/10000.0));
    dst_able.rage_add_per  = (uint32)(plv_data->rage_add_per * (pmonster_data->rage_add_per/10000.0));
    dst_able.rage_del_per  = (uint32)(plv_data->rage_del_per * (pmonster_data->rage_del_per/10000.0));
}

void AddWinCount(SUser *puser)
{
    puser->data.tomb_info.win_count++;
    if ( puser->data.tomb_info.max_win_count < puser->data.tomb_info.win_count )
        puser->data.tomb_info.max_win_count = puser->data.tomb_info.win_count;

    if ( puser->data.tomb_info.history_win_count < puser->data.tomb_info.win_count )
        puser->data.tomb_info.history_win_count = puser->data.tomb_info.win_count;

    //如果是25关那么通关+1
    if ( 25 == puser->data.tomb_info.win_count )
        puser->data.tomb_info.history_pass_count++;

    ReplyInfo(puser);
}

void ReplyInfo(SUser *puser)
{
    PRTombInfo rep;
    rep.info = puser->data.tomb_info;
    bccopy(rep, puser->ext);
    local::write( local::access, rep );
}

void ReplyList(SUser *puser)
{
    if ( puser->data.tomb_target_list.empty() )
    {
        RandomCreate(puser);
        puser->data.tomb_info.try_count++;
        puser->data.tomb_info.try_count_now = puser->data.tomb_info.try_count;
        ReplyInfo(puser);
    }

    //如果数据有问题的情况下
    if ( !CheckList(puser) )
    {
        RandomCreate(puser);

        puser->data.tomb_info.win_count = 0;
        puser->data.tomb_info.reward_count = 0;
        puser->data.tomb_info.totem_value_self = 0;
        puser->data.tomb_info.totem_value_target = 0;

        puser->data.soldier_map[kSoldierTypeTombSelf].clear();
        soldier::ReplyList(puser,kSoldierTypeTombSelf);
        puser->data.soldier_map[kSoldierTypeTombTarget].clear();
        soldier::ReplyList(puser,kSoldierTypeTombTarget);

        puser->data.formation_map[kFormationTypeTombTarget].clear();
        formation::ReplyList(puser, kFormationTypeTombTarget);
    }

    PRTombTargetList rep;
    rep.tomb_target_list = puser->data.tomb_target_list;
    bccopy(rep, puser->ext);
    local::write( local::access, rep );
}

bool CheckList(SUser *puser )
{
    for( std::vector<STombTarget>::iterator iter = puser->data.tomb_target_list.begin();
        iter != puser->data.tomb_target_list.end();
        ++iter )
    {
        if ( iter->attr == kAttrSoldier && iter->target_id < 1000000 )
            return false;
    }
    return true;
}

}// namespace tomb

