#include "viptimelimitshop_imp.h"
#include "user_event.h"

EVENT_FUNC(viptimelimit_shop, SEventUserTimeLimit)
{
    viptimelimit_shop::TimeLimit(ev.user);
}

EVENT_FUNC(viptimelimit_shop, SEventUserLogined)
{
    viptimelimit_shop::CheckRefresh(ev.user);
}
