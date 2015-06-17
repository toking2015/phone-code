#include <time.h>
#include "pro.h"
#include "log.h"
#include "misc.h"
#include "util.h"
#include "local.h"
#include "server.h"
#include "altar_imp.h"
#include "altar_event.h"
#include "coin_imp.h"
#include "soldier_imp.h"
#include "var_imp.h"
#include "user_imp.h"
#include "copy_imp.h"
#include "proto/constant.h"
#include "resource/r_globalext.h"
#include "resource/r_soldierdata.h"
#include "resource/r_soldierext.h"
#include "resource/r_itemext.h"
#include "building_imp.h"

// 候选列表类型
#define CANDICATE_ALL  0 // 所有
#define CANDICATE_RARE 1 // 稀有物品
#define CANDICATE_TEN  2 // 累计十次

namespace altar
{
uint32* GetSeed(SUser *user, uint32 type , uint32 count)
{
    if(type == kAltarLotteryByMoney)
    {
        if(count == 1)
        {
            return &(user->data.altar_info.money_seed_1);
        }
        else if(count == 10)
        {
            return &(user->data.altar_info.money_seed_10);
        }
    }
    else if(type == kAltarLotteryByGold)
    {
        if(count == 1)
        {
            return &(user->data.altar_info.gold_seed_1);
        }
        else if(count == 10)
        {
            return &(user->data.altar_info.gold_seed_10);
        }
    }

    return NULL;
}

std::vector<CAltarData::SData*> Random(std::vector<CAltarData::SData*> &candicate_list, uint32 count, uint32* seed)
{
    std::vector<CAltarData::SData*> list;

    uint32 total_probs = 0;
    for(uint32 i = 0; i < candicate_list.size(); ++i)
    {
        total_probs += candicate_list[i]->prob;
    }

    for(uint32 i = 0; i < count; ++i)
    {
        uint32 ran_value = TRand((uint32)0, total_probs, seed);
        for(uint32 j = 0; j < candicate_list.size(); ++j)
        {
            CAltarData::SData *data = candicate_list[j];
            if(ran_value <= data->prob)
            {
                list.push_back(data);
                break;
            }
            else
            {
                ran_value -= data->prob;
            }
        }
    }

    return list;
}

std::vector<CAltarData::SData*> GetCandicates(uint32 user_lv, uint32 altar_type, uint32 candicate_type, bool is_first_cost_gold)
{
    std::vector<CAltarData::SData*> list;

    const CAltarData::UInt32AltarMap &all_list = theAltarExt.GetAltarList();
    for(CAltarData::UInt32AltarMap::const_iterator iter = all_list.begin(); iter != all_list.end(); ++iter)
    {
        if((iter->second == NULL) || (iter->second->type != altar_type) || (iter->second->lv > user_lv))
        {
            continue;
        }

        if(is_first_cost_gold)
        {
            if(iter->second->reward.objid == 10701) // 钻石的首抽，不允许抽到女刺客
            {
                continue;
            }

            if(iter->second->reward.objid == 10804) // 钻石的首抽，不允许抽到小牛酋长
            {
                continue;
            }
        }

        bool is_add = false;
        if(candicate_type == CANDICATE_RARE)
        {
            is_add = (iter->second->is_rare != 0);
        }
        else if(candicate_type == CANDICATE_TEN)
        {
            is_add = (iter->second->is_ten != 0);
        }
        else if(candicate_type == CANDICATE_ALL)
        {
            is_add = true;
        }

        if(is_add)
        {
            list.push_back(iter->second);
        }
    }

    return list;
}

bool RandomRewards(SUser *user, std::vector<uint32> &id_list, std::vector<S3UInt32> &reward_list, std::vector<S3UInt32> &extra_reward_list,
                   uint32 user_lv, uint32 type, uint32 count, uint32 total_count, bool is_first_cost_gold)
{
    std::vector<CAltarData::SData*> candicate_list = GetCandicates(user_lv, type, CANDICATE_ALL, is_first_cost_gold);
    if(candicate_list.size() < count)
    {
        LOG_ERROR("the candicate list size=%u, but random count=%u", (uint32)candicate_list.size(), count);
        return false;
    }

    uint32 *seed = GetSeed(user, type, count);
    if(seed == NULL)
    {
        LOG_ERROR("cannot get seed, by type=%u, count=%u", type, count);
        return false;
    }

    std::vector<CAltarData::SData*> selected_list = Random(candicate_list, count, seed);
    if(selected_list.size() != count)
    {
        LOG_ERROR("the select list size=%u, but count=%u", (uint32)selected_list.size(), count);
        return false;
    }

    int32 candicate_type = -1;
    if(count == 1)
    {
        if(is_first_cost_gold) // 第一次消耗钻石的抽卡，必抽中稀有
        {
            candicate_type = CANDICATE_RARE;
        }
        else if(total_count % 10 == 0) // 每十次出必出的物品
        {
            bool has_ten = false;
            for(uint32 i = 0; i < selected_list.size(); ++i)
            {
                if(selected_list[i]->is_ten != 0)
                {
                    has_ten = true;
                    LOG_DEBUG("total_count=%u, ten_count item=%u", total_count, selected_list[i]->id);
                    break;
                }
            }
            if(!has_ten)
            {
                candicate_type = CANDICATE_TEN;
            }
        }
    }
    else
    {
        // 十次必出稀有
        bool contains_rare = false;
        for(uint32 i = 0; i < selected_list.size(); ++i)
        {
            if(selected_list[i]->is_rare != 0)
            {
                contains_rare = true;
                break;
            }
        }
        if(!contains_rare)
        {
            candicate_type = CANDICATE_RARE;
        }
    }

    if(candicate_type >= 0)
    {
        std::vector<CAltarData::SData*> clist = GetCandicates(user_lv, type, candicate_type, is_first_cost_gold);
        std::vector<CAltarData::SData*> slist = Random(clist, 1, seed);
        if(slist.size() == 1)
        {
            selected_list[count - 1] = slist[0];
            LOG_DEBUG("candicate_type=%u, random id=%u", candicate_type, slist[0]->id);
        }
        else
        {
            LOG_ERROR("cannot select a candicate_type=%u reward", candicate_type);
            return false;
        }
    }

    // 赋值返回数据
    for(uint32 i = 0; i < selected_list.size(); ++i)
    {
        CAltarData::SData *altar_data = selected_list[i];

        id_list.push_back(altar_data->id);
        LOG_DEBUG("%u: altar_data_id=%u", i + 1, altar_data->id);

        reward_list.push_back(altar_data->reward);
        extra_reward_list.push_back(altar_data->extra_reward);
    }

    reward_list = soldier::ChangeSoldierToOther(user, reward_list);

    return true;
}

void Lottery(SUser *user, uint32 type, uint32 count, uint32 use_type)
{
    LOG_DEBUG(">>>>begin_lottery[uid=%u,ulv=%u,type=%u,count=%u, use_type=%u]>>>>>",
              user->guid, user->data.simple.team_level, type, count, use_type);
    //检测祭坛是否已开放
    if(building::GetCount(user, kBuildingTypeAlter) == 0)
    {
        LOG_ERROR("uid=%u,ulv=%u, altar system not open", user->guid, user->data.simple.team_level);
        return;
    }

    if(((type != kAltarLotteryByMoney) && (type != kAltarLotteryByGold)) ||
       ((count != 1) && (count != 10)) ||
       ((use_type != kAltarLotteryUseDefault) && (use_type != kAltarLotteryUseFree) && (use_type != kAltarLotteryUseItem)))
    {
        LOG_WARN("error type=%u or count=%u or use_type=%u", type, count, use_type);
        return;
    }

    // 钻石抽卡，玩家需通关第2个副本
    if(type == kAltarLotteryByGold)
    {
        SCopyLog log = copy::get_copy_log(user, theGlobalExt.get<uint32>("altar_lottery_gold_copy_passed_id"));
        if(log.time == 0)
        {
            HandleErrCode(user, kErrAltarCopyNotPassed, 0);
            return;
        }
    }

    SAltarInfo &info = user->data.altar_info;
    uint32 ts_now = server::local_time();
    bool is_first_cost_gold = false; // 第一次消耗钻石

    // 判断货币
    uint32 first_soldier_id = 0;
    uint32 total_count      = 0;
    S3UInt32 cost_coin;
    S3UInt32 cost_item;
    cost_item.cate = 0;
    if(type == kAltarLotteryByMoney)
    {
        cost_coin.cate = kCoinMoney;
        if(count == 1)
        {
            if(use_type == kAltarLotteryUseFree)
            {
                if((info.free_count > 0) && (ts_now >= info.free_time + theGlobalExt.get<uint32>("altar_lottery_free_interval")))
                {
                    --info.free_count;
                    info.free_time = ts_now;
                }
                else
                {
                    LOG_WARN("client req use money free, but free_count is 0 or not arrival time");
                    return;
                }
            }
            else if(use_type == kAltarLotteryUseItem)
            {
                cost_item = theGlobalExt.get<S3UInt32>("altar_lottery_money_onece_item_cost");
            }
            else if(use_type == kAltarLotteryUseDefault)
            {
                cost_coin.val = theGlobalExt.get<uint32>("altar_lottery_money_onece_cost");
            }

            // 总次数
            total_count = var::get(user, "altar_lottery_money_count") + 1;
            var::set(user, "altar_lottery_money_count", total_count);
            if(total_count == 1)
            {
                first_soldier_id = theGlobalExt.get<uint32>("altar_lottery_money_first_get");
            }
        }
        else
        {
            cost_coin.val = theGlobalExt.get<uint32>("altar_lottery_money_ten_cost");
        }
    }
    else if(type == kAltarLotteryByGold)
    {
        cost_coin.cate = kCoinGold;
        if(count == 1)
        {
            if(use_type == kAltarLotteryUseFree)
            {
                if(ts_now >= info.gold_free_time + theGlobalExt.get<uint32>("altar_lottery_gold_free_interval"))
                {
                    info.gold_free_time = ts_now;
                }
                else
                {
                    LOG_WARN("client req use gold free, but not arrival time");
                    return;
                }
            }
            else if(use_type == kAltarLotteryUseItem)
            {
                cost_item = theGlobalExt.get<S3UInt32>("altar_lottery_gold_onece_item_cost");
            }
            else if(use_type == kAltarLotteryUseDefault)
            {
                cost_coin.val = theGlobalExt.get<uint32>("altar_lottery_gold_onece_cost");

                if(var::get(user, "altar_lottery_first_cost_gold_time") == 0)
                {
                    is_first_cost_gold = true;
                    var::set(user, "altar_lottery_first_cost_gold_time", ts_now);
                }
            }

            // 总次数
            total_count = var::get(user, "altar_lottery_gold_count") + 1;
            var::set(user, "altar_lottery_gold_count", total_count);
            if(total_count == 1)
            {
                first_soldier_id = theGlobalExt.get<uint32>("altar_lottery_gold_first_get");

                // 特殊处理了，为了下一次必出英雄
                total_count = 9;
                var::set(user, "altar_lottery_gold_count", total_count);
            }
        }
        else
        {
            cost_coin.val = theGlobalExt.get<uint32>("altar_lottery_gold_ten_cost");

            if(var::get(user, "altar_lottery_first_ten_count_time") == 0)
            {
                is_first_cost_gold = true;
                var::set(user, "altar_lottery_first_ten_count_time", ts_now);
            }
        }
    }

    std::vector<uint32>   id_list;
    std::vector<S3UInt32> reward_list;
    std::vector<S3UInt32> extra_reward_list;
    // 第一次给武将
    if(first_soldier_id > 0)
    {
        soldier::Add(user, first_soldier_id, kPathAltar);
        LOG_INFO("FirstGiveSoldier[uid=%u,type=%u,count=%u,use_type=%u,SOLDIER=%u]", user->guid, type, count, use_type, first_soldier_id);
    }
    else
    {
        // 随机物品
        if(!RandomRewards(user, id_list, reward_list, extra_reward_list,
                          user->data.simple.team_level, type, count, total_count, is_first_cost_gold))
        {
            LOG_ERROR("random reward failed, type=%u, count=%u", type, count);
            return;
        }

        // 正式扣钱发奖
        if(cost_item.cate != 0)
        {
            if(coin::check_take(user, cost_item) == 0)
            {
                coin::take(user, cost_item, kPathAltar);
            }
            else
            {
                LOG_WARN("lack of item");
                return;
            }
        }
        else if(cost_coin.val > 0)
        {
            if(coin::check_take(user, cost_coin) == 0)
            {
                coin::take(user, cost_coin, kPathAltar);
            }
            else
            {
                LOG_WARN("lack of money or gold");
                return;
            }
        }
        coin::give(user, reward_list, kPathAltar);
        coin::give(user, extra_reward_list, kPathAltar);
    }

    // 返回
    PRAltarLottery rsp;
    bccopy(rsp, user->ext);
    rsp.id_list           = id_list;
    rsp.reward_list       = reward_list;
    rsp.extra_reward_list = extra_reward_list;
    rsp.soldier_id        = first_soldier_id;
    rsp.info              = user->data.altar_info;
    local::write(local::access, rsp);

    event::dispatch(SEventLotteryCard(user, kPathAltar, type, count));
    LOG_DEBUG("<<<<<end_lottery[uid=%u,type=%u,count=%u, use_type=%u]<<<<<<", user->guid, type, count, use_type);
}

void ReplyAltarInfo(SUser *user)
{
    PRAltarInfo rsp;
    bccopy(rsp, user->ext);
    rsp.info = user->data.altar_info;

    local::write(local::access, rsp);
}

void TimeLimit(SUser *user)
{
    user->data.altar_info.reset_time = server::local_time();
    user->data.altar_info.free_count = theGlobalExt.get<uint32>("altar_lottery_free_count");
    ReplyAltarInfo(user);

    LOG_DEBUG("uid=%u, altar money lottery free count reset!!!", user->guid);
}

void InitSeed(SUser *user)
{
    uint32 min = 10000;
    uint32 max = (uint32)(-1);

    user->data.altar_info.money_seed_1  = TRand(min, max);
    user->data.altar_info.money_seed_10 = TRand(min, max);
    user->data.altar_info.gold_seed_1   = TRand(min, max);
    user->data.altar_info.gold_seed_10  = TRand(min, max);
}

}// namespace altar
