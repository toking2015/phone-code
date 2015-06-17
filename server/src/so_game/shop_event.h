#ifndef _IMMORTAL_SO_GAME_SHOP_EVENT_H_
#define _IMMORTAL_SO_GAME_SHOP_EVENT_H_

#include "event.h"

// 商品购买
struct SEventVendibleBuy : public SEvent
{
    uint32 vendible_id;
    uint32 count;
    SEventVendibleBuy(SUser *u, uint32 p, uint32 id, uint32 _count) : SEvent(u, p), vendible_id(id), count(_count) {}
};

#endif
