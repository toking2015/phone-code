#include "fightextable_event.h"
#include "fightextable_imp.h"
#include "proto/fightextable.h"
#include "proto/constant.h"
#include "system_event.h"
#include "user_event.h"

EVENT_FUNC( fightextable, SEventUserLoaded )
{
    fightextable::UpdateAllAble(ev.user, ev.path);
}

EVENT_FUNC(fightextable, SEventFightExtAbleSoldierUpdate)
{
    fightextable::UpdateSoldierAble(ev.user, ev.soldier, ev.path);
}

EVENT_FUNC(fightextable, SEventFightExtAbleAllUpdate)
{
    fightextable::UpdateAllAble(ev.user, ev.path);
}

