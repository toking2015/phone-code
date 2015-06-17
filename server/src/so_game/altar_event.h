#ifndef _GAME_ALTER_EVENT_H_
#define _GAME_ALTER_EVENT_H_

#include "event.h"

struct SEventLotteryCard : public SEvent
{
    uint32 type;
    uint32 count;

    SEventLotteryCard( SUser* u, uint32 p, uint32 t, uint32 c ) : SEvent(u, p), type(t), count(c){}
};

#endif

