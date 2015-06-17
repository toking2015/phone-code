#include "misc.h"
#include "shop_imp.h"
#include "coin_imp.h"
#include "mysteryshop_imp.h"
#include "var_imp.h"
#include "netsingle.h"
#include "local.h"
#include "proto/shop.h"
#include "user_dc.h"

// 购买
MSG_FUNC(PQShopBuy)
{
    QU_ON(user, msg.role_id);
    bool ret = shop::VendibleBuy(user, msg.id, msg.count);
    PRShopBuy rep;
    rep.status = ret;
    rep.id = msg.id;
    rep.count = msg.count;
    bccopy(rep, user->ext);
    local::write(local::access, rep);
}

// 神秘商店刷新请求
MSG_FUNC(PQShopRefresh)
{
    QU_ON(user, msg.role_id);
    S3UInt32 cost = coin::create(kCoinItem, 8, 1);
    if (coin::check_take(user, cost) != 0)
    {
        cost.cate = kCoinGold;
        cost.objid = 0;
        cost.val = 50;
        if (coin::check_take(user, cost) != 0)
            return;
    }
    coin::take(user, cost, kPathClearMasteryCD);
    mystery_shop::RefreshGoodsList(user);
}

// 大墓地商店刷新
MSG_FUNC(PQShopTombRefresh)
{
    static uint32 cost_coin[] = {20, 20, 50, 50, 100, 100};
    QU_ON(user, msg.role_id);
    uint32 refreshed_times = var::get(user, "tomb_refreshed_times");
    uint32 gold = 0;
    if (refreshed_times >= sizeof(cost_coin)/sizeof(cost_coin[0]))
        gold = 200;
    else
        gold = cost_coin[refreshed_times];

    S3UInt32 cost = coin::create(kCoinGold, 0, gold);
    if (coin::check_take(user, cost) != 0)
        return;
    coin::take(user, cost, kPathTombShopRefresh);

    var::set(user, "tomb_refreshed_times", refreshed_times+1);
    shop::ResetDailyBuyCount(user, kShopTypeTomb);
}
