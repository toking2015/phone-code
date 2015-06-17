#include <time.h>
#include "pro.h"
#include "log.h"
#include "util.h"
#include "local.h"
#include "server.h"
#include "sign_imp.h"
#include "var_imp.h"
#include "coin_imp.h"
#include "user_imp.h"
#include "proto/constant.h"
#include "resource/r_signdayext.h"
#include "resource/r_globalext.h"
#include "resource/r_signsumext.h"
#include "resource/r_signadditionalcostext.h"

// -------------------------
#define CHECK_DAY()\
    uint32 open_time = server::get<uint32>("open_time");\
    uint32 ts_next   = server::local_time() - 6 * 60 * 60;\
    uint32 day_id    = GetSubDay(open_time, ts_next) + 1;\
    CSignDayData::SData *data = theSignDayExt.Find(day_id);\
    if(data == NULL)\
    {\
        LOG_ERROR("cannot find data by day_id=%u", day_id);\
        return;\
    }

struct FindSignByDayId
{
    uint32 m_id;

    FindSignByDayId(uint32 id) : m_id(id) { }

    bool operator()(const SSign &sign)
    {
        return (sign.day_id == m_id);
    }
};

namespace sign
{

void Sign(SUser *user)
{
    CHECK_DAY();

    SignList::iterator iter = std::find_if(user->data.sign_info.sign_list.begin(), user->data.sign_info.sign_list.end(), FindSignByDayId(day_id));
    if(iter != user->data.sign_info.sign_list.end())
    {
        LOG_WARN("day_id=%u already signed in", day_id);
        return;
    }

    // 发放奖励
    coin::give(user, data->rewards, kPathSign);

    // 签到
    SSign sign;
    sign.day_id    = day_id;
    sign.sign_type = kSignNormal;
    sign.sign_time = server::local_time();
    user->data.sign_info.sign_list.push_back(sign);

    PRSign rsp;
    bccopy(rsp, user->ext);
    rsp.sign = sign;
    local::write(local::access, rsp);
}

void TakeHaoHuaReward(SUser *user)
{
    uint32 taken_time = var::get(user, "sign_today_haohua_take_time");
    if(taken_time > 0)
    {
        LOG_WARN("has taken at %u", taken_time);
        return;
    }

    uint32 count = var::get(user, "sign_today_recharge_count");
    uint32 need  = theGlobalExt.get<uint32>("sign_haohua_reward_recharge_count");
    if(count < need)
    {
        LOG_WARN("count=%u < need=%u", count, need);
        return;
    }

    CHECK_DAY();

    // 发放奖励
    coin::give(user, data->haohua_rewards, kPathSign);
    var::set(user, "sign_today_haohua_take_time", server::local_time());
}

void OnPay(SUser *user, uint32 coin)
{
    uint32 count = var::get(user, "sign_today_recharge_count");
    var::set(user, "sign_today_recharge_count", (count + coin));
}

void TimeLimit(SUser *user)
{
    var::set(user, "sign_today_haohua_take_time", 0);
    var::set(user, "sign_today_recharge_count",   0);
}

void TakeReward(SUser *user, uint32 reward_id)
{
    std::vector<uint32> &sum_list = user->data.sign_info.sum_list;
    for(uint32 i = 0; i < sum_list.size(); ++i)
    {
        if(sum_list[i] == reward_id)
        {
            LOG_WARN("reward_id=%u is already taken", reward_id);
            return;
        }
    }

    CSignSumData::SData *data = theSignSumExt.Find(reward_id);
    if(data == NULL)
    {
        LOG_ERROR("cannot find sign_sum data by reward_id=%u", reward_id);
        return;
    }

    uint32 sum_count = user->data.sign_info.sign_list.size();
    if(sum_count < data->sum_days)
    {
        LOG_WARN("reward_id=%u, sum_days=%u, but signed_days=%u", reward_id, data->sum_days, sum_count);
        return;
    }

    uint32 ret = coin::check_give(user, data->rewards);
    if(ret != 0)
    {
        LOG_WARN("check_give ret=%u", ret);
        return;
    }

    // 发放奖励
    coin::give(user, data->rewards, kPathSign);
    sum_list.push_back(reward_id);

    PRTakeSignSumReward rsp;
    bccopy(rsp, user->ext);
    rsp.reward_id = reward_id;
    local::write(local::access, rsp);
}

void ReplySignInfo(SUser *user)
{
    PRSignInfo rsp;
    bccopy(rsp, user->ext);
    rsp.info = user->data.sign_info;

    local::write(local::access, rsp);
}

}// namespace sign
