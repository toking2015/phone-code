#include "mysteryshop_imp.h"
#include "user_dc.h"
#include "timer.h"
#include "server.h"
#include "util.h"

SO_LOAD(mystery_shop_timer_reg)
{
    theSysTimeMgr.AddLoop
    (
        "mystery_shop_refresh_12",
        "",
        "12:00:00",
        NULL,
        CSysTimeMgr::Day,
        1,
        0
    );

    theSysTimeMgr.AddLoop
    (
        "mystery_shop_refresh_18",
        "",
        "18:00:00",
        NULL,
        CSysTimeMgr::Day,
        1,
        0
    );

    theSysTimeMgr.AddLoop
    (
        "mystery_shop_refresh_21",
        "",
        "21:00:00",
        NULL,
        CSysTimeMgr::Day,
        1,
        0
    );
}

static void goods_refresh(std::pair< const uint32, SUser >& pair)
{
    SUser *p_user = &pair.second;
    mystery_shop::RefreshGoodsList(p_user);
}

TIMER(mystery_shop_refresh_12)
{
    dc::safe_each(theUserDC.db().user_map, goods_refresh);
}

TIMER(mystery_shop_refresh_18)
{
    dc::safe_each(theUserDC.db().user_map, goods_refresh);
}

TIMER(mystery_shop_refresh_21)
{
    dc::safe_each(theUserDC.db().user_map, goods_refresh);
}
