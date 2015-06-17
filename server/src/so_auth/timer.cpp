#include "timer.h"
#include "sockcoolmgr.h"

SO_LOAD( _raw_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "_sock_cool_timer",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Second,
        5,
        0
    );
}

TIMER( _sock_cool_timer )
{
    theSockCoolMgr.process();
}

