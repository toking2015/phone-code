#ifndef _GAME_PAY_EVENT_H_
#define _GAME_PAY_EVENT_H_

#include "event.h"
#include "proto/pay.h"

//支付事件
struct SEventPay: public SEvent, public SUserPay
{
    SEventPay( SUser *u, uint32 p, uint32 id, uint32 c, uint32 t ) : SEvent(u, p){uid=id, price=c, type=t;}
};

//支付月卡
struct SEventPayMonthCard : public SEvent
{
    uint32 old_time;

    SEventPayMonthCard( SUser* u, uint32 p, uint32 t ) : SEvent(u, p), old_time(t){}
};

#endif //_GAME_PAY_EVENT_H_
