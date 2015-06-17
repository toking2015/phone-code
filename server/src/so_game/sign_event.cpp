#include "sign_imp.h"
#include "user_event.h"
#include "pay_event.h"

EVENT_FUNC(sign, SEventUserTimeLimit)
{
    sign::TimeLimit(ev.user);
}

EVENT_FUNC(sign, SEventPay)
{
    sign::OnPay(ev.user, ev.price);
}
