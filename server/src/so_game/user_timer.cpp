#include "user_dc.h"
#include "timer.h"
#include "jsonconfig.h"
#include "log.h"
#include "user_event.h"
#include "var_imp.h"
#include "local.h"
#include "server.h"
#include "proto/broadcast.h"

SO_LOAD( user_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "user_save_timer",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Second,
        1,
        0
    );

    theSysTimeMgr.AddLoop
    (
        "user_meet_timeout_check",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Minute,
        10,
        0
    );

    theSysTimeMgr.AddLoop
    (
        "user_defer_timeout_check",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Second,
        60,
        0
    );

    theSysTimeMgr.AddLoop
    (
        "user_time_limit_timer",
        "",
        "06:00:00",
        NULL,
        CSysTimeMgr::Day,
        1,
        0
    );
}

//定时保存
TIMER( user_save_timer )
{
    theUserDC.save_once( 10 );
    //theUserDC.each_save( 600 );
}

//定时检查超时没有访问用户的数据
TIMER( user_meet_timeout_check )
{
    /*
       不应该直接删除用户数据, 应该先发送协议到 access 清除 session

    //释放 30分钟 内没有数据访问的对象
    theUserDC.release_timeout_user( 1800 );
    */

    LOG_ERROR( "user_meet_timeout_check: %d", (int32)theUserDC.db().user_map.size() );
}

//清理异步加载超时的协议
TIMER( user_defer_timeout_check )
{
    //释放 60秒 内没有返回的异步协议
    theUserDC.release_timeout_defer( 60 );
}

//用户 0点 TimeLimit 事件处理
void user_time_limit_timer_process( std::pair< const uint32, SUser >& pair )
{
    SUser* user = &pair.second;

    uint32 user_time_limit = server::local_6_time( var::get( user, "user_time_limit" ) );
    uint32 neal_time_limit = server::local_6_time(0);

    if ( user_time_limit < neal_time_limit )
    {
        var::set( user, "user_time_limit", neal_time_limit );

        event::dispatch( SEventUserTimeLimit( user, kPathUserEveryDay ) );
    }
}
TIMER( user_time_limit_timer )
{
    dc::safe_each( theUserDC.db().user_map, user_time_limit_timer_process );

    //发送时间截协议
    PRUserTimeLimit rep;
    rep.broad_cast = kCastServer;

    local::write( local::access, rep );
}

