#include "timer.h"
#include "cool.h"

SO_LOAD( system_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "system_cool_timeout_timer",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Minute,
        1,
        0
    );
}

TIMER( system_cool_timeout_timer )
{
    cool::release_timeout( 60 );
}

