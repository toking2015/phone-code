#include "misc.h"
#include "fightextable_imp.h"
#include "proto/fightextable.h"
#include "user_dc.h"

MSG_FUNC( PQFightExtAbleList )
{
    QU_ON( user, msg.role_id );

    fightextable::ReplyList( user, msg.attr );
}

