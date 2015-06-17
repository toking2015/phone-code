#ifndef _GAME_FIGHTEXTABLE_EVENT_H_
#define _GAME_FIGHTEXTABLE_EVENT_H_

#include "event.h"

//战斗二级属性
struct SEventFightExtAbleSoldierUpdate : public SEvent
{
    S2UInt32 soldier;
    SEventFightExtAbleSoldierUpdate( SUser *u, S2UInt32 s, uint32 p ) : SEvent(u, p), soldier(s) {}
};

struct SEventFightExtAbleAllUpdate : public SEvent
{
    SEventFightExtAbleAllUpdate( SUser *u, uint32 p ) : SEvent(u, p) {}
};

#endif //_GAME_FIGHTEXTABLE_EVENT_H_
