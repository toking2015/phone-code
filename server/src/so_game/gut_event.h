#ifndef _GAME_GUT_EVENT_H_
#define _GAME_GUT_EVENT_H_

#include "event.h"

struct SEventGutStepCommit : public SEvent
{
    uint32 gut_id;
    uint32 index;

    SEventGutStepCommit( SUser* u, uint32 p, uint32 id, uint32 idx ) : SEvent(u, p), gut_id(id), index(idx){}
};

struct SEventGutFinished : public SEvent
{
    uint32 gut_id;
    SEventGutFinished( SUser* u, uint32 p, uint32 id ) : SEvent(u, p), gut_id(id){}
};

#endif

