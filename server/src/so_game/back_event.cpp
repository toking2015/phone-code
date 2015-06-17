#include "event.h"
#include "user_event.h"
#include "coin_event.h"
#include "soldier_event.h"
#include "team_event.h"
#include "timer_event.h"
#include "proto/constant.h"
#include "back_imp.h"
#include "server.h"
#include "util.h"
#include "misc.h"

EVENT_FUNC( back, SEventUserLogin )
{
    back::write( "login.txt", "%s\t%u\t%s\t%s",
        time2str( server::local_time() ).c_str(),
        ev.user->guid,
        ev.user->data.simple.name.c_str(),
        ev.user->data.simple.platform.c_str() );
}

EVENT_FUNC( back, SEventCoin )
{
    const char* str_op = NULL;
    uint32 cur_val = 0;

    switch ( ev.set_type )
    {
    case kObjectAdd:
        str_op = "+";
        cur_val = ev.old_val + ev.coin.val;
        break;
    case kObjectDel:
        str_op = "-";
        cur_val = ev.old_val - ev.coin.val;
        break;
    }

    if ( str_op == NULL )
        return;

    back::write
    (
        "coins.txt", "%s\t%u\t%u\t%s\t%u\t%u\t%u\t%s\t%u\t%u\t%s",
        time2str( server::local_time() ).c_str(),
        global_action,
        ev.user->guid,
        ev.user->data.simple.name.c_str(),
        ev.coin.cate,
        ev.coin.objid,
        ev.old_val,
        str_op,
        ev.coin.val,
        cur_val,
        constant::get_path_name( ev.path )
    );
}

EVENT_FUNC( back, SEventSoldierQualityUp )
{
    back::write
    (
        "soldier_quality.txt", "%s\t%u\t%u\t%s\t%u\t%u\t+\t%u\t%u",
        time2str( server::local_time() ).c_str(),
        global_action,
        ev.user->guid,
        ev.user->data.simple.name.c_str(),
        ev.soldier_id,
        ev.old_quality,
        1,
        ev.old_quality + 1
    );
}

EVENT_FUNC( back, SEventSoldierLvUp )
{
    back::write
    (
        "soldier_level.txt", "%s\t%u\t%u\t%s\t%u\t%u\t+\t%u\t%u",
        time2str( server::local_time() ).c_str(),
        global_action,
        ev.user->guid,
        ev.user->data.simple.name.c_str(),
        ev.soldier_id,
        ev.old_level,
        1,
        ev.old_level + 1
    );
}

EVENT_FUNC( back, SEventTeamLevelUp )
{
    back::write
    (
        "team_level.txt", "%s\t%u\t%u\t%s\t%u\t+\t%u\t%u",
        time2str( server::local_time() ).c_str(),
        global_action,
        ev.user->guid,
        ev.user->data.simple.name.c_str(),
        ev.old_level,
        ev.user->data.simple.team_level - ev.old_level,
        ev.user->data.simple.team_level
    );
}

EVENT_FUNC( back, SEventUserSave )
{
    back::write
    (
        "save_user.txt", "%s\t%u\t%s\t%u\t%s\t%d",
        time2str( server::local_time() ).c_str(),
        ev.user->guid,
        ev.user->data.simple.name.c_str(),
        ev.user->data.simple.team_level,
        ev.value.c_str(),
        ev.saved ? 1 : 0
    );
}

EVENT_FUNC( back, SEventTimerOnTime )
{
    back::write
    (
        "timer.txt", "%s\t%s",
        time2str( server::local_time() ).c_str(),
        ev.key.c_str()
    );
}

