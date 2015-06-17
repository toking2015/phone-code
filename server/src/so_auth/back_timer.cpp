#include "timer.h"
#include "back_imp.h"

SO_LOAD( back_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "back_time_limit_timer",
        "",
        "00:00:00",
        NULL,
        CSysTimeMgr::Day,
        1,
        0
    );
}

TIMER( back_time_limit_timer )
{
    back::close_limit_file();
    back::open_limit_file();
}

