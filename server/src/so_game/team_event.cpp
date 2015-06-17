#include "team_event.h"
#include "coin_imp.h"
#include "proto/team.h"
#include "resource/r_levelext.h"

EVENT_FUNC( team, SEventTeamLevelUp )
{
    CLevelData::SData* level = theLevelExt.Find( ev.old_level );
    if ( level == NULL )
        return;

    S3UInt32 coin = coin::create( kCoinStrength, 0, level->strength_give );

    coin::give( ev.user, coin, ev.path, kCoinFlagOverflow );
}

