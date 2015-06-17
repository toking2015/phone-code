#ifndef _GAME_MARKET_EVENT_H_
#define _GAME_MARKET_EVENT_H_

#include "event.h"

//物品上架
struct SEventMarketCargoUp : public SEvent
{
    SEventMarketCargoUp( SUser* u, uint32 p ) : SEvent( u, p ){}
};

#endif

