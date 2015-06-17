#ifndef _IMMORTAL_SO_GAME_BUILDING_EVENT_H_
#define _IMMORTAL_SO_GAME_BUILDING_EVENT_H_

#include "event.h"

struct SEventBuildingResourceTake : public SEvent
{
    uint32 type;
    uint32 value;

    SEventBuildingResourceTake( SUser* u, uint32 p, uint32 t, uint32 v ) :
        SEvent(u, p), type(t), value(v){}
};

struct SEventBuildingSpeedOutput : public SEvent
{
    uint32 type;

    SEventBuildingSpeedOutput( SUser* u, uint32 p, uint32 t ) :
        SEvent(u, p), type(t){}
};

#endif
