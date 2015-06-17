#include "pro.h"
#include "proto/present.h"
#include "local.h"

#include "resource/r_globalext.h"
#include "resource/r_rewardext.h"

#include "coin_imp.h"

#include "user_dc.h"

MSG_FUNC( PQPresentGlobalTake )
{
    QU_ON( user, msg.role_id );

    if ( msg.code.empty() )
    {
        PRPresentGlobalTake rep;
        bccopy( rep, msg );

        rep.err_code = kErrPresentCodeEmpty;

        local::write( local::access, msg );
        return;
    }

    if ( theGlobalExt.HasEspecial( msg.code ) )
    {
        PRPresentGlobalTake rep;
        bccopy( rep, msg );

        rep.err_code = kErrPresentCodeFormation;

        local::write( local::access, msg );
        return;
    }

    msg.platform = user->data.simple.platform;

    local::write( local::realdb, msg );
}

MSG_FUNC( PRPresentGlobalTake )
{
    if ( key != local::realdb )
        return;

    QU_OFF( user, msg.role_id );

    if ( msg.err_code == 0 )
    {
        CRewardData::SData* reward = theRewardExt.Find( msg.reward_id );
        if ( reward != NULL )
            coin::give( user, reward->coins, kPathPresentGlobalTake );
    }

    local::write( local::access, msg );
}

