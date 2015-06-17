#include "misc.h"
#include "activity_imp.h"
#include "activity_dc.h"
#include "proto/activity.h"
#include "proto/constant.h"
#include "user_dc.h"
#include "local.h"

MSG_FUNC( PQActivityRewardLoad )
{
    if ( key != local::auth )
        return;

    theActivityDC.clear_reward();

    PQActivityRewardLoad rep;
    local::write( local::realdb, rep );
}

MSG_FUNC( PQActivityFactorLoad )
{
    if ( key != local::auth )
        return;

    theActivityDC.clear_factor();

    PQActivityFactorLoad rep;
    local::write( local::realdb, rep );
}

MSG_FUNC( PQActivityOpenLoad )
{
    if ( key != local::auth )
        return;

    theActivityDC.clear_open();

    PQActivityOpenLoad rep;
    local::write( local::realdb, rep );
}

MSG_FUNC( PQActivityDataLoad )
{
    if ( key != local::auth )
        return;

    theActivityDC.clear_data();

    PQActivityDataLoad rep;
    local::write( local::realdb, rep );
}


MSG_FUNC( PRActivityOpenLoad )
{
    activity::LoadOpen( msg.list );
}

MSG_FUNC( PRActivityDataLoad )
{
    activity::LoadData( msg.list );
}

MSG_FUNC( PRActivityFactorLoad )
{
    activity::LoadFactor( msg.list );
}

MSG_FUNC( PRActivityRewardLoad )
{
    activity::LoadReward( msg.list );
}

MSG_FUNC( PQActivityList )
{
    QU_ON( user, msg.role_id );

    activity::ReplyActivityList( user );
}

MSG_FUNC( PQActivityInfoList )
{
    QU_ON( user, msg.role_id );

    activity::ReplyActivityInfoList( user );
}

MSG_FUNC( PQActivityTakeReward )
{
    QU_ON( user, msg.role_id );

    activity::TakeReward( user, msg.open_guid, msg.index );
}



/**
MSG_FUNC( PQActivityOpenSet )
{
    if ( key != local::auth )
        return;

    activity::OpenSet( msg.guid, msg.type, msg.open );
}

MSG_FUNC( PQActivityDataSet )
{
    if ( key != local::auth )
        return;

    activity::DataSet( msg.guid, msg.type, msg.data );
}

MSG_FUNC( PRActivityOpenSet )
{
    if ( key != local::realdb )
        return;

    if( msg.type == kObjectAdd )
        theActivityDC.set_open( msg.open );
}

MSG_FUNC( PRActivityDataSet )
{
    if ( key != local::realdb )
        return;

    if( msg.type == kObjectAdd )
        theActivityDC.set_data( msg.data );
}
**/

