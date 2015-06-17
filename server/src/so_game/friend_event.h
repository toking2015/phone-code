#ifndef _IMMORTAL_SO_GAME_FRIEND_EVENT_H_
#define _IMMORTAL_SO_GAME_FRIEND_EVENT_H_

#include "event.h"

// 好友赠送活跃度
struct SEventFrdGiveActiveScore : public SEvent
{
    uint32 target_id;       //
    uint32 value;           //赠送的活跃度

    SEventFrdGiveActiveScore(SUser *u, uint32 p, uint32 _target_id, uint32 _value) : SEvent(u, p), target_id(_target_id), value(_value) { }
};

#endif
