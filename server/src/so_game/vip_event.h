#ifndef _IMMORTAL_SO_GAME_VIP_EVENT_H_
#define _IMMORTAL_SO_GAME_VIP_EVENT_H_

#include "event.h"

//vip等级升级
struct SEventVipLevelUp : public SEvent
{
    uint32 old_level;
    SEventVipLevelUp( SUser* u, uint32 p, uint32 lv ) : SEvent(u, p), old_level(lv){}
};

#endif
