#ifndef _GAME_TOMB_EVENT_H_
#define _GAME_TOMB_EVENT_H_

#include "event.h"

//用户出发大墓地战斗
struct SEventTombFight: public SEvent
{
    uint32 index;
    SEventTombFight( SUser* u, uint32 _index, uint32 p ) : SEvent(u, p) { index = _index; }
};

struct SEventTombRewardGet: public SEvent
{
    uint32 index;
    SEventTombRewardGet( SUser* u, uint32 _index, uint32 p ) : SEvent(u, p) { index = _index; }
};



#endif //_GAME_TOMB_EVENT_H_
