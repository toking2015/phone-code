#include "user_event.h"
#include "altar_imp.h"

EVENT_FUNC(altar, SEventUserInit)
{
    altar::InitSeed(ev.user);
}

EVENT_FUNC(altar, SEventUserTimeLimit)
{
    altar::TimeLimit(ev.user);
}

EVENT_FUNC(altar, SEventUserLogined)
{
    if(ev.user->data.altar_info.money_seed_1 == 0)
    {
        altar::InitSeed(ev.user);
    }
}
