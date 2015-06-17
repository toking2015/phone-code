#include "link_event.h"
#include "user_event.h"
#include "singlearena_imp.h"
#include "singlearena_dc.h"
#include "team_event.h"
#include "fightextable_event.h"
#include "formation_event.h"
#include "proto/singlearena.h"
#include "local.h"

EVENT_FUNC( singlearena, SEventNetRealDB )
{
    //发送数据加载请求
    theSingleArenaDC.InitLoadLog();
    theSingleArenaDC.InitGuid();

    PQSingleArenaRankLoad msg;
    local::write( local::realdb, msg );

    PQSingleArenaLogLoad rep;
    local::write( local::realdb, rep );
}

EVENT_FUNC( singlearena, SEventUserTimeLimit )
{
    singlearena::TimeLimit( ev.user );
}

EVENT_FUNC( singlearena, SEventAvatarChange )
{
    theSingleArenaDC.UpdateAvatar( ev.user->guid, ev.avatar );
}

EVENT_FUNC( singlearena, SEventNameChange )
{
    theSingleArenaDC.UpdateName( ev.user->guid, ev.name );
}

EVENT_FUNC( singlearena, SEventTeamLevelUp )
{
    theSingleArenaDC.UpdateLevel( ev.user->guid, ev.user->data.simple.team_level );
}

EVENT_FUNC( singlearena, SEventFightExtAbleAllUpdate )
{
    theSingleArenaDC.UpdateFightValue( ev.user );
}

EVENT_FUNC( singlearena, SEventFormationSet )
{
    if( ev.formation_type == kFormationTypeSingleArenaDef )
        theSingleArenaDC.UpdateFightValue( ev.user );
}
