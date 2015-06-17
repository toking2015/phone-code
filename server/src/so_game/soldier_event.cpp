#include "event.h"
#include "soldier_imp.h"
#include "user_event.h"
#include "team_event.h"
#include "resource/r_globalext.h"

EVENT_FUNC( soldier, SEventTeamLevelUp )
{
    uint32 level = theGlobalExt.get<uint32>("team_up_soldier_up_level");
    if ( ev.user->data.simple.team_level <= level )
        soldier::LvUpToTeam( ev.user );
}

