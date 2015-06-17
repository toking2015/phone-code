#ifndef _GAME_FORMATION_EVENT_H_
#define _GAME_FORMATION_EVENT_H_

#include "event.h"

//战斗二级属性
struct SEventFormationSet : public SEvent
{
    uint32 formation_type;
    SEventFormationSet( SUser *u, uint32 p, uint32 f ) : SEvent(u, p), formation_type(f) {}
};

#endif //_GAME_FORMATION_EVENT_H_
