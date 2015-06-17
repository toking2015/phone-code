#include "timer.h"
#include "jsonconfig.h"
#include "log.h"
#include "fight_imp.h"
#include "server.h"
#include "luamgr.h"

SO_LOAD( fight_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "fight_save_timer",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Minute,
        1,
        0
    );
}

//定时保存
TIMER( fight_save_timer )
{
    theLuaMgr.GC();
    //theLuaMgr.GCCount();
}
