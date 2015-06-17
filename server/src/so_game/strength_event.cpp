#include "user_event.h"
#include "var_imp.h"
#include "coin_imp.h"
#include "resource/r_levelext.h"
#include "server.h"
#include "proto/strength.h"

EVENT_FUNC( strength, SEventUserInit )
{
    ev.user->data.simple.strength = theLevelExt.Find(1)->strength;

    var::set( ev.user, "strength_last_time", server::local_time() );
}

EVENT_FUNC( strength, SEventUserTimeLimit )
{
    var::set( ev.user, "strength_day_buy_count", 0 );
}

EVENT_FUNC( strength, SEventUserMeet )
{
    uint32 time_now = server::local_time();

    //获取上次检查点
    uint32 strength_last_time = var::get( ev.user, "strength_last_time" );
    if ( time_now <= strength_last_time )
        return;

    //计算时间距离
    uint32 sub_time = time_now - strength_last_time;
    if ( sub_time < 360 )
        return;

    //恢复体力和检查点计算
    uint32 strength = sub_time / 360;

    //重置检查点时间值
    strength_last_time += strength * 360;
    var::set( ev.user, "strength_last_time", time_now );

    //查看体力点恢复空间
    uint32 space_value = coin::space( ev.user, kCoinStrength );

    //给予体力
    S3UInt32 coin = coin::create( kCoinStrength, 0, std::min( strength, space_value ) );
    if ( coin.val >= 0 )
        coin::give( ev.user, coin, kPathStrengthTimer );
}

