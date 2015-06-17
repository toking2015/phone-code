#ifndef _GAME_TIMER_EVENT_H_
#define _GAME_TIMER_EVENT_H_

#include "event.h"

struct SEventTimerOnTime : public SEvent
{
    const std::string& key;
    uint32 msec;

    SEventTimerOnTime( const std::string& k, uint32 m ) : SEvent(NULL, 0), key(k), msec(m) {}
};

#endif

