#include "misc.h"
#include "opentarget_imp.h"
#include "proto/opentarget.h"
#include "proto/constant.h"
#include "local.h"
#include "user_dc.h"

MSG_FUNC( PQOpenTargetTake )
{
    QU_ON( user, msg.role_id );

    opentarget::Take( user, msg.day, msg.guid );
}

MSG_FUNC( PQOpenTargetBuy )
{
    QU_ON( user, msg.role_id );

    opentarget::Buy( user, msg.day, msg.guid );
}


