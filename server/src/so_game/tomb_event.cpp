#include "event.h"
#include "tomb_imp.h"
#include "user_event.h"
#include "proto/soldier.h"
#include "proto/formation.h"

EVENT_FUNC( tomb, SEventUserTimeLimit )
{
    tomb::TimeLimit(ev.user);
}

EVENT_FUNC( tomb, SEventUserLoaded )
{
    if ( !tomb::CheckList(ev.user) )
    {
        tomb::RandomCreate(ev.user);

        ev.user->data.tomb_info.win_count = 0;
        ev.user->data.tomb_info.reward_count = 0;
        ev.user->data.tomb_info.totem_value_self = 0;
        ev.user->data.tomb_info.totem_value_target = 0;

        ev.user->data.soldier_map[kSoldierTypeTombSelf].clear();
        ev.user->data.soldier_map[kSoldierTypeTombTarget].clear();
        ev.user->data.formation_map[kFormationTypeTombTarget].clear();
    }
}
