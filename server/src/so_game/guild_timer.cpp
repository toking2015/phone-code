#include "guild_dc.h"
#include "timer.h"
#include "jsonconfig.h"
#include "log.h"

SO_LOAD( guild_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "guild_save_timer",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Second,
        5,
        0
    );

    theSysTimeMgr.AddLoop
    (
        "guild_meet_timeout_check",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Minute,
        10,
        0
    );

    theSysTimeMgr.AddLoop
    (
        "guild_defer_timeout_check",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Second,
        60,
        0
    );
}

//定时保存
TIMER( guild_save_timer )
{
    theGuildDC.save_once(5);
}

//定时检查超时没有访问公会的数据
TIMER( guild_meet_timeout_check )
{
    //释放 30分钟 内没有数据访问的对象
    theGuildDC.release_timeout_guild( 1800 );
}

//清理异步加载超时的协议
TIMER( guild_defer_timeout_check )
{
    //释放 60秒 内没有返回的异步协议
    theGuildDC.release_timeout_defer( 60 );
}
