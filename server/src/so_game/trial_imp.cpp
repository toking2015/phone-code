#include "trial_imp.h"
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
#include "resource/r_trialmonsterlvext.h"
#include "resource/r_trialrewardext.h"
#include "resource/r_trialext.h"
#include "resource/r_rewardext.h"
#include "resource/r_trialrewardcountext.h"
#include "resource/r_oddext.h"
#include "coin_imp.h"
#include "trial_event.h"
#include "user_imp.h"
#include "resource/r_globalext.h"

namespace trial
{

uint32 GetFormationType(uint32 id)
{
    switch(id)
    {
    case kTrialSurvival:
        return kFormationTypeTrialSurvival;
    case kTrialStrength:
        return kFormationTypeTrialStrength;
    case kTrialAgile:
        return kFormationTypeTrialAgile;
    case kTrialIntelligence:
        return kFormationTypeIntelligence;
    }
    return 0;
}

uint32 GetFightType(uint32 id)
{
    switch(id)
    {
    case kTrialSurvival:
        return kFightTypeTrialSurvival;
    case kTrialStrength:
        return kFightTypeTrialStrength;
    case kTrialAgile:
        return kFightTypeTrialAgile;
    case kTrialIntelligence:
        return kFightTypeTrialIntelligence;
    }
    return 0;

}

void Enter(SUser *puser, uint32 id, std::vector<SUserFormation> &list )
{
    //判断是否能进入
    CTrialData::SData *pdata = theTrialExt.Find(id);
    if ( NULL == pdata )
    {
        HandleErrCode(puser, kErrTrialDataNoExit, 0);
        return;
    }

    if ( 0 != user::GetFightId(puser) )
        return;

    //是否开放时间
    time_t t_time = server::local_time();
    //减去6小时
    t_time = t_time - 6 * 3600;
    struct tm t_tm = {0};
    localtime_r( &t_time, &t_tm );
    uint32 now_day = t_tm.tm_wday;
    if ( 0 == now_day )
        now_day = 7;

    std::vector<uint32>::iterator iter = std::find( pdata->open_day.begin(), pdata->open_day.end(), now_day );
    if ( iter == pdata->open_day.end() )
    {
        HandleErrCode(puser, kErrTrialNotOpen, 0 );
        return;
    }

    //是否超过次数
    if ( puser->data.trial_map[id].try_count >= pdata->try_count )
    {
        HandleErrCode(puser, kErrTrialTryCount, 0 );
        return;
    }

    //体力
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

    //阵型是否OK
    if( !formation::Set( puser, list, GetFormationType(id) ) )
        return;

    //设置id和时间
    puser->ext.trial_id = id;
    puser->ext.trial_time = (uint32)server::local_time();

    CFight *pcfight = fight::Interface( GetFightType(id ) );
    if ( NULL != pcfight )
    {
        SFight *psfight = pcfight->AddFightToMonster( puser, pdata->monster_id );
        if ( NULL != psfight )
            fight::ReplyFightInfo(psfight);
    }
}

void AddVal(SUser *puser, uint32 id, uint32 val)
{
    puser->data.trial_map[id].trial_id = id;
    puser->data.trial_map[id].trial_val += val;
    if ( puser->data.trial_map[id].max_single_val < val )
        puser->data.trial_map[id].max_single_val = val;
    ReplyTrial(puser, id);
}

void AddTry(SUser *puser, uint32 id)
{
    puser->data.trial_map[id].trial_id = id;
    puser->data.trial_map[id].try_count++;

    ReplyTrial(puser, id);
    event::dispatch(SEventTrialFinished( puser, kPathTrialFinish, id));
}

void AddReward(SUser *puser, uint32 id)
{
    puser->data.trial_map[id].trial_id = id;
    puser->data.trial_map[id].reward_count++;
    ReplyTrial(puser, id);
}

void SetMonster( uint32 monster_id, uint32 user_level, SFightPlayerInfo &play_info, uint32 &guid )
{
    CMonsterFightConfData::SData *pdata = theMonsterFightConfExt.Find( monster_id );
    if ( NULL == pdata )
        return;

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
        fight_soldier.fight_index = iter->second;
        if ( !fight::GetFightIndex(play_info, iter->second) )
            continue;
        fight_soldier.name = pmonster_data->name;
        fight_soldier.attr = kAttrMonster;
        fight_soldier.rage = pmonster_data->initial_rage;
        fight_soldier.occupation = pmonster_data->occupation;
        fight_soldier.level = pmonster_data->level;
        fight_soldier.equip_type = pmonster_data->equip_type;
        GetMonsterExt(iter->first, user_level, fight_soldier.fight_ext_able);
        fight::GetMonsterSkill(iter->first,fight_soldier.skill_list);
        fight::GetMonsterOdd(iter->first, iter->second, fight_soldier.odd_list);
        fight_soldier.hp = fight_soldier.fight_ext_able.hp;

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

void GetMonsterExt( uint32 monster_id, uint32 lv, SFightExtAble &dst_able )
{
    CMonsterData::SData *pmonster_data = theMonsterExt.Find( monster_id );
    if ( NULL == pmonster_data )
        return;

    CTrialMonsterLvData::SData *plv_data = theTrialMonsterLvExt.Find( lv );
    if ( NULL == plv_data )
        return;

    dst_able.hp  = (uint32)(plv_data->hp * (pmonster_data->hp/10000.0));
    dst_able.physical_ack  = (uint32)(plv_data->physical_ack * (pmonster_data->physical_ack/10000.0));
    dst_able.physical_def  = (uint32)(plv_data->physical_def * (pmonster_data->physical_def/10000.0));
    dst_able.magic_ack  = (uint32)(plv_data->magic_ack * (pmonster_data->magic_ack/10000.0));
    dst_able.magic_def  = (uint32)(plv_data->magic_def * (pmonster_data->magic_def/10000.0));
    dst_able.speed  = (uint32)(plv_data->speed * (pmonster_data->speed/10000.0));
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

uint32 trial_reward_get_value( CTrialRewardData::SData *pdata )
{
    return pdata->percent;
}

bool RandomCreate(SUser *puser, uint32 id)
{
    const uint32 Trial_Reward_List = 6;

    std::vector<CTrialRewardData::SData*> list = theTrialRewardExt.GetRandomList(id, puser->data.simple.team_level);
    if ( list.empty() )
    {
        return false;
        HandleErrCode( puser, kErrTrialRewardDataNoExitLevel, 0 );
    }

    puser->data.trial_reward_map[id].clear();
    for( uint32 i = 1; i <= Trial_Reward_List; ++i )
    {
        CTrialRewardData::SData *pdata = round_rand( list, trial_reward_get_value );
        if ( NULL == pdata )
        {
            return false;
            HandleErrCode( puser, kErrTrialRewardDataNoExitLevel, 0 );
        }
        SUserTrialReward user_trial_reward;
        user_trial_reward.trial_id = id;
        user_trial_reward.reward = pdata->reward;
        puser->data.trial_reward_map[id].push_back(user_trial_reward);
    }
    return true;
}

void RewardGet(SUser *puser, uint32 id, uint32 index)
{
    std::vector<SUserTrialReward> &list = puser->data.trial_reward_map[id];
    if ( list.empty() || index >= list.size() )
    {
        HandleErrCode(puser, kErrTrialRewardDataNoExit, 0);
        return;
    }

    SUserTrial &user_trial = puser->data.trial_map[id];
    //首先判断能否领取
    CTrialRewardCountData::SData *pcount_data = theTrialRewardCountExt.Find( id, user_trial.reward_count+1 );
    if ( NULL == pcount_data )
    {
        HandleErrCode(puser, kErrTrialRewardDataNoExit, 0);
        return;
    }

    //试炼值没到
    if ( user_trial.trial_val < pcount_data->trial_val )
    {
        HandleErrCode(puser,kErrTrialRewardValNot,0);
        return;
    }

    uint32 reward_count = 0;
    for( std::vector<SUserTrialReward>::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
        if( iter->flag == kTrue )
            reward_count++;
    }

    if ( reward_count >= 4 )
        return;

    pcount_data = theTrialRewardCountExt.Find( id, reward_count + 1 );
    S3UInt32 cost = pcount_data->reward_cost;
    if ( 0 != cost.cate )
    {
        uint32 ret = coin::check_take( puser, cost );
        if ( 0 != ret )
        {
            HandleErrCode(puser, kErrCoinLack, ret );
            return;
        }
    }

    SUserTrialReward &reward = list[index];
    if ( reward.flag == kTrue )
    {
        HandleErrCode(puser, kErrTrialRewardHave, 0);
        return;
    }

    CRewardData::SData* preward = theRewardExt.Find( reward.reward );
    if ( NULL == preward )
    {
        HandleErrCode(puser, kErrTrialRewardDataNoExit, 0);
        return;
    }

    if ( 0 != cost.cate )
        coin::take(puser, cost, kPathTrialRewardGet);
    coin::give( puser, preward->coins, kPathTrialRewardGet);

    reward.flag = kTrue;

    event::dispatch(SEventTrialRewardGet( puser, kPathTrialRewardGet, user_trial.reward_count+1));

    PRTrialRewardGet rep;
    bccopy( rep, puser->ext );
    rep.id = id;
    rep.index = index;
    local::write(local::access, rep);
}

void RewardEnd(SUser *puser, uint32 id)
{
    AddReward(puser,id);
    puser->data.trial_reward_map[id].clear();
    ReplyRewardList(puser,id);

    PRTrialRewardEnd rep;
    bccopy( rep, puser->ext );
    rep.id = id;
    local::write( local::access, rep );
}

void ReplyRewardList(SUser *puser, uint32 id)
{
    if ( puser->data.trial_reward_map[id].empty() )
    {
        if (!RandomCreate( puser, id ) )
            return;
    }

    PRTrialRewardList rep;
    bccopy( rep, puser->ext );
    rep.id = id;
    rep.reward_list = puser->data.trial_reward_map[id];
    local::write(local::access, rep);
}

void ReplyTrial(SUser *puser, uint32 id)
{
    PRTrialUpdate rep;
    bccopy( rep, puser->ext );
    puser->data.trial_map[id].trial_id = id;
    rep.user_trial = puser->data.trial_map[id];
    local::write(local::access, rep);
}

void TimeLimit(SUser *puser)
{
    puser->data.trial_reward_map.clear();
    puser->data.trial_map.clear();
    for( uint32 i = kTrialSurvival; i <= kTrialIntelligence; ++i )
    {
        ReplyTrial(puser, i);
        ReplyRewardList(puser,i);
    }
}

void AddTrialBuff( uint32 trial_id, uint32 soldier_occu, std::vector<SFightOdd> &odd_list )
{
    //判断是否能进入
    CTrialData::SData *pdata = theTrialExt.Find(trial_id);
    if ( NULL == pdata )
        return;

    if ( pdata->trial_occu == soldier_occu )
    {
        for( std::vector<S2UInt32>::iterator iter = pdata->occu_odd.begin();
            iter != pdata->occu_odd.end();
            ++iter )
        {
            COddData::SData *podd = theOddExt.Find( iter->first, iter->second );
            if ( NULL == podd )
                continue;
            SFightOdd fight_odd;
            fight::CreateFightOdd(podd, fight_odd);
            odd_list.push_back(fight_odd);
        }
    }
}

void MopUp( SUser *puser, uint32 id )
{
    //判断是否能进入
    CTrialData::SData *pdata = theTrialExt.Find(id);
    if ( NULL == pdata )
    {
        HandleErrCode(puser, kErrTrialDataNoExit, 0);
        return;
    }

    //是否开放时间
    time_t t_time = server::local_time();
    //减去6小时
    t_time = t_time - 6 * 3600;
    struct tm t_tm = {0};
    localtime_r( &t_time, &t_tm );
    uint32 now_day = t_tm.tm_wday;
    if ( 0 == now_day )
        now_day = 7;

    std::vector<uint32>::iterator iter = std::find( pdata->open_day.begin(), pdata->open_day.end(), now_day );
    if ( iter == pdata->open_day.end() )
    {
        HandleErrCode(puser, kErrTrialNotOpen, 0 );
        return;
    }

    //是否超过次数
    if ( puser->data.trial_map[id].try_count >= pdata->try_count )
    {
        HandleErrCode(puser, kErrTrialTryCount, 0 );
        return;
    }

    uint32 vip_level = theGlobalExt.get<uint32>( "trial_vip_mopup_level" );
    if ( puser->data.simple.vip_level < vip_level )
        return;

    if ( 0 == puser->data.trial_map[id].max_single_val )
        return;

    puser->data.trial_map[id].trial_val += puser->data.trial_map[id].max_single_val;
    puser->data.trial_map[id].try_count++;
    ReplyTrial(puser, id );

    PRTrialMopUp rep;
    bccopy( rep, puser->ext );
    rep.id = id;
    rep.trial_val = puser->data.trial_map[id].trial_val;
    local::write(local::access, rep );
    event::dispatch(SEventTrialFinished( puser, kPathTrialFinish, id));
}

} // namespace trial

