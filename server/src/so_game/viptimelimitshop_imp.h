#ifndef _GAMESVR_VIPTIMELIMIT_SHOP_IMP_H_
#define _GAMESVR_VIPTIMELIMIT_SHOP_IMP_H_

#include "common.h"
#include "resource/r_viptimelimitshopext.h"
#include "proto/common.h"
#include "proto/user.h"
#include "dynamicmgr.h"

namespace viptimelimit_shop
{
    typedef std::vector<SUserVipTimeLimitGoods> VipTimeLimitGoodsList;
    // 购买
    void Buy(SUser *p_user, uint32 vip_level, uint32 count);
    // 玩家登陆后检查是否需要刷新
    void CheckRefresh(SUser *p_user);
    // 获取当前周数
    uint32 GetWeeks(SUser *p_user);
    // 获取下次可以购买时间
    uint32 GetNextBuyTime(SUser *p_user);
    // 请求当前周数
    void ReplyWeek(SUser *p_user);
    // 每天6点检测一次是否满足周一进行更新
    void TimeLimit(SUser *p_user);


} // namespace viptimelimit_shop

#endif
