#include "pro.h"
#include "proto/team.h"
#include "team_imp.h"
#include "user_dc.h"

MSG_FUNC( PQTeamLevelUp )
{
    QU_ON( user, msg.role_id );

    team::level_up( user );
}

MSG_FUNC( PQTeamChangeName )
{
    QU_ON( user, msg.role_id );

    team::change_name( user, msg.name );
}

MSG_FUNC( PQTeamChangeAvatar )
{
    QU_ON( user, msg.role_id );

    team::change_avatar( user, msg.avatar );
}
