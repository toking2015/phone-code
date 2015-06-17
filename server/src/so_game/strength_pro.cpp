#include "pro.h"
#include "proto/strength.h"
#include "strength_imp.h"
#include "user_dc.h"

MSG_FUNC( PQStrengthBuy )
{
    QU_ON( user, msg.role_id );

    strength::buy( user );
}

