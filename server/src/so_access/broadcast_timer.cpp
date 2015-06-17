#include "timer.h"
#include "settings.h"
#include "cache.h"

SO_LOAD( broadcast_timer_init )
{
    theSysTimeMgr.AddLoop
    (
        "broadcast_progress",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Millisecond,
        100,
        0
    );
}

TIMER( broadcast_progress )
{
    cache::progress(0);
}

