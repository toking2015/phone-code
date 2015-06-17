#ifndef _GAME_FIGHT_EVENT_H_
#define _GAME_FIGHT_EVENT_H_

#include "event.h"

//战斗二级属性
struct SEventFightKillMonster: public SEvent
{
    uint32  monster_id;
    SEventFightKillMonster( SUser *u, uint32 p, uint32 _m ) : SEvent(u, p), monster_id(_m){}
};

#endif //_GAME_FIGHT_EVENT_H_
