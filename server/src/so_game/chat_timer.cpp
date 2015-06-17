#include "timer.h"
#include "jsonconfig.h"
#include "chat_imp.h"

SO_LOAD( chat_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "chat_time_sound_auto_clear",
        "",
        "",
        NULL,
        CSysTimeMgr::Minute,
        1,
        0
    );
}

//定时保存
TIMER( chat_time_sound_auto_clear )
{
    chat::clear_timeout_sound();
}

