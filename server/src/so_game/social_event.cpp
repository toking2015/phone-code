#include "user_event.h"
#include "proto/social.h"
#include "remote.h"

EVENT_FUNC( social, SEventUserLogined )
{
    PQSocialServerRole msg;

    msg.role.role_id = ev.user->guid;
    msg.role.level = ev.user->data.simple.team_level;
    msg.role.name = ev.user->data.simple.name;

    remote::write( local::social, msg );
}
