#include "shop_imp.h"
#include "var_imp.h"
#include "user_event.h"
#include "coin_event.h"
#include "proto/constant.h"
#include "proto/coin.h"

EVENT_FUNC(shop, SEventUserTimeLimit)
{
    shop::TimeLimit(ev.user);
}

EVENT_FUNC(shop, SEventCoin)
{
    if (ev.set_type == kObjectDel && ev.coin.cate == kCoinMedal)
    {
        std::string key("medal_history_consume");
        uint32 v = var::get(ev.user, key);
        v += ev.coin.val;
        var::set(ev.user, key, v);
    }
}
