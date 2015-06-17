#include "user_event.h"
#include "mysteryshop_imp.h"

EVENT_FUNC(mystery_shop, SEventUserLogined)
{
    if (ev.user->data.other.mystery_refresh_time < time(NULL) || ev.user->data.mystery_goods_list.empty())
    {
        mystery_shop::RefreshGoodsList(ev.user);
    }
}
