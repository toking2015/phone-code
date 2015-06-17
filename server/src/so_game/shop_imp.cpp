#include "shop_imp.h"
#include "coin_imp.h"
#include "mysteryshop_imp.h"
#include "var_imp.h"
#include "guild_dc.h"
#include "shop_event.h"
#include "local.h"
#include "misc.h"
#include "resource/r_guildlevelext.h"
#include "resource/r_achievementgoodsext.h"
#include "proto/constant.h"

namespace shop
{

bool Check(SUser *p_user, S3UInt32 cost, S3UInt32 item_coin)
{
    // 价钱
    if (0 != coin::check_take(p_user, cost))
        return false;

    // 空间
    if (0 != coin::check_give(p_user, item_coin))
        return false;

    return true;
}

bool Buy(SUser *p_user, CVendibleData::SData *p_data, uint32 count, uint32 path)
{
    S3UInt32 cost = p_data->price;
    cost.val *= count;
    S3UInt32 item_coin = p_data->goods;
    item_coin.val *= count;
    // 检查货币和空间
    if (!Check(p_user, cost, item_coin))
        return false;

    // 扣钱
    coin::take(p_user, cost, path);
    // 加物品
    coin::give(p_user, item_coin, path);

    event::dispatch(SEventVendibleBuy(p_user, path, p_data->id, count));

    return true;
}

bool CommonBuy(SUser *p_user, CVendibleData::SData *p_data, uint32 count, uint32 path)
{
    // 每日限购
    if (p_data->daily_limit_count > 0 && GetDailyCount(p_user, p_data->id) + count > p_data->daily_limit_count)
        return false;
    // 历史限购
    if (p_data->history_limit_count > 0 && GetHistoryCount(p_user, p_data->id) + count > p_data->history_limit_count)
        return false;

    if (!Buy(p_user, p_data, count, path))
        return false;

    // 添加购买记录
    AddBuyCount(p_user, p_data, count);
    return true;
}

bool MedalBuy(SUser *p_user, CVendibleData::SData *p_data, uint32 count)
{
    // 竞技场挑战胜利次数限制
    if (p_user->data.other.single_arena_win_times < p_data->win_times_limit)
        return false;
    return CommonBuy(p_user, p_data, count, kPathMedalShop);
}

bool GuildBuy(SUser *p_user, CVendibleData::SData *p_data, uint32 count)
{
    // 公会等级限制
    if (p_user->data.simple.guild_id == 0)
        return false;
    SGuild *guild = theGuildDC.find(p_user->data.simple.guild_id);
    if (!guild)
        return false;

    CGuildLevelData::SData *p_level = theGuildLevelExt.Find(guild->data.simple.level);
    if (!p_level)
        return false;

    if (p_data->id < p_level->vendible_begin || p_data->id > p_level->vendible_end)
        return false;

    return CommonBuy(p_user, p_data, count, kPathGuildShop);
}

bool AchievementBuy(SUser *p_user, CVendibleData::SData *p_data, uint32 count, uint32 path)
{
    CAchievementGoodsData::SData *p_achieve = theAchievementGoodsExt.Find(p_data->id);
    if (!p_achieve)
        return false;

    uint32 progress = 0;
    switch (p_achieve->cond.first) {
    case kASCondArenaRank:
        progress = p_user->data.other.single_arena_rank;
        break;
    case kASCondArenaWinTimes:
        progress = p_user->data.other.single_arena_win_times;
        break;
    case kASCondMedalConsume:
        progress = var::get(p_user, std::string("medal_history_consume"));
        break;
    case kASCondTombWinTimes:
        progress = p_user->data.tomb_info.history_win_count;
        break;
    case kASCondTombReset:
        progress = p_user->data.tomb_info.history_reset_count;
        break;
    case kASCondTombPass:
        progress = p_user->data.tomb_info.history_pass_count;
        break;
    }

    if (p_achieve->cond.first == kASCondArenaRank)
    {
        if (progress > p_achieve->cond.second)
            return false;
    }
    else if (progress < p_achieve->cond.second)
    {
        return false;
    }

    return CommonBuy(p_user, p_data, count, path);
}

bool VendibleBuy(SUser *p_user, uint16 id, uint32 count)
{
    CVendibleData::SData *p_data = theVendibleExt.Find(id);
    if (!p_data)
        return false;
    switch (p_data->shop_type) {
    case kShopTypeMedal:
        return MedalBuy(p_user, p_data, count);
    case kShopTypeCommon:
        return CommonBuy(p_user, p_data, count, kPathCommonShop);
    case kShopTypeMystery:
        return mystery_shop::Buy(p_user, p_data, count);
    case kShopTypeTomb:
        return CommonBuy(p_user, p_data, count, kPathTombShop);
    case kShopTypeGuild:
        return GuildBuy(p_user, p_data, count);
    case kShopTypeAchievementMedal:
        return AchievementBuy(p_user, p_data, count, kPathAchievementMedalShop);
    case kShopTypeAchievementTomb:
        return AchievementBuy(p_user, p_data, count, kPathAchievementTombShop);
    default:
        break;
    }
    return false;
}

uint32 GetDailyCount(SUser *p_user, uint16 id)
{
    ShopLogList::iterator find_iter = std::find_if(p_user->data.shop_log.begin(), p_user->data.shop_log.end(), EqualShopLogId(id));
    if (find_iter == p_user->data.shop_log.end())
        return 0;
    return find_iter->daily_count;
}

uint32 GetHistoryCount(SUser *p_user, uint16 id)
{
    ShopLogList::iterator find_iter = std::find_if(p_user->data.shop_log.begin(), p_user->data.shop_log.end(), EqualShopLogId(id));
    if (find_iter == p_user->data.shop_log.end())
        return 0;
    return find_iter->history_count;
}

void AddBuyCount(SUser *p_user, CVendibleData::SData *p_data, uint32 count)
{
    uint32 daily_count = 0;
    uint32 history_count = 0;
    uint32 id = p_data->id;
    if (p_data->daily_limit_count > 0)
        daily_count = count;
    if (p_data->history_limit_count > 0)
        history_count = count;
    if (daily_count == 0 && history_count == 0)
        return;

    ShopLogList::iterator find_iter = std::find_if(p_user->data.shop_log.begin(), p_user->data.shop_log.end(), EqualShopLogId(id));
    if (find_iter == p_user->data.shop_log.end())
    {
        SUserShopLog log;
        log.id = id;
        log.daily_count = daily_count;
        log.history_count = history_count;
        p_user->data.shop_log.push_back(log);
        ReplyLogSet(p_user, log);
    }
    else
    {
        find_iter->daily_count += daily_count;
        find_iter->history_count += history_count;
        ReplyLogSet(p_user, *find_iter);
    }
}

void ReplyShopLog(SUser *p_user)
{
    PRShopLog rep;
    rep.log = p_user->data.shop_log;
    bccopy(rep, p_user->ext);
    local::write( local::access, rep );
}

void ReplyLogSet(SUser *p_user, SUserShopLog &log)
{
    PRShopLogSet rep;
    rep.log = log;
    bccopy(rep, p_user->ext);
    local::write( local::access, rep );
}

static void reset_daily_count(SUserShopLog &log) { log.daily_count = 0; }
void TimeLimit(SUser *p_user)
{
    std::for_each(p_user->data.shop_log.begin(), p_user->data.shop_log.end(), reset_daily_count);
    ReplyShopLog(p_user);

    var::set(p_user, "tomb_refreshed_times", 0);
}

void ResetDailyBuyCount(SUser *p_user, uint32 shop_type)
{
    for (ShopLogList::iterator iter = p_user->data.shop_log.begin();
        iter != p_user->data.shop_log.end();
        ++iter)
    {
        CVendibleData::SData *p_data = theVendibleExt.Find(iter->id);
        if (!p_data || p_data->shop_type != shop_type)
            continue;
        iter->daily_count = 0;
        ReplyLogSet(p_user, *iter);
    }
}

}// namespace shop
