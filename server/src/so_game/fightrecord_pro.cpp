#include "misc.h"
#include "local.h"
#include "fightrecord_dc.h"
#include "user_dc.h"
#include "proto/fight.h"
#include "pro.h"

MSG_FUNC( PRFightRecordID )
{
    theFightRecordDC.set(msg.id);
}

MSG_FUNC( PQFightRecordGet )
{
    QU_ON(user, msg.role_id);

    local::write(local::fight, msg);
}

MSG_FUNC( PRFightRecordGet )
{
    local::write(local::access, msg);
}
