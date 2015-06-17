#ifndef _GAMESVR_SHOP_IMP_H_
#define _GAMESVR_SHOP_IMP_H_

#include "common.h"
#include "resource/r_vendibleext.h"
#include "proto/common.h"
#include "proto/user.h"
#include "proto/shop.h"
#include "dynamicmgr.h"

typedef std::vector<SUserShopLog> ShopLogList;

struct EqualShopLogId
{
    uint16 id;
    EqualShopLogId(uint16 n) : id(n) {}

    bool operator()(const SUserShopLog &log)
    {
        return log.id == id;
    }
};

namespace shop
{
    // 检测花费cost及获得item_coin的物品空间是否足够
    bool Check(SUser *p_user, S3UInt32 cost, S3UInt32 item_coin);
    // 简朴购买逻辑，扣钱及添加获得
    bool Buy(SUser *p_user, CVendibleData::SData *p_data, uint32 count, uint32 path);
    // 普通购买
    bool CommonBuy(SUser *p_user, CVendibleData::SData *p_data, uint32 count, uint32 path);
    // 勋章商店购买
    bool MedalBuy(SUser *p_user, CVendibleData::SData *p_data, uint32 count);
    // 公会商店购买
    bool GuildBuy(SUser *p_user, CVendibleData::SData *p_data, uint32 count);
    // 成就商店购买
    bool AchievementBuy(SUser *p_user, CVendibleData::SData *p_data, uint32 count, uint32 path);
    // 商品表购买入口
    bool VendibleBuy(SUser *p_user, uint16 id, uint32 count);
    // 获取商品号为id的当天已购买数量
    uint32 GetDailyCount(SUser *p_user, uint16 id);
    // 获取商品号为id的历史已购买数量
    uint32 GetHistoryCount(SUser *p_user, uint16 id);
    // 添加商品id的购买记录
    void AddBuyCount(SUser *p_user, CVendibleData::SData *p_data, uint32 count);
    // 返回商品购买记录列表
    void ReplyShopLog(SUser *p_user);
    // 返回单个商品购买记录
    void ReplyLogSet(SUser *p_user, SUserShopLog &log);
    // 清零每日限购记录
    void TimeLimit(SUser *p_user);
    // 商店每日限购重置
    void ResetDailyBuyCount(SUser *p_user, uint32 shop_type);
}// namespace shop

#endif
