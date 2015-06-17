#include "event.h"
#include "fight_imp.h"
#include "proto/constant.h"
#include "var_imp.h"
#include "user_event.h"
#include "user_imp.h"

EVENT_FUNC( fight, SEventUserLogin )
{
    //清理战斗数据
    user::DelFightId(ev.user);
}
