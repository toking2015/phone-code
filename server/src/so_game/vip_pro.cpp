#include "pro.h"
#include "proto/vip.h"
#include "vip_imp.h"
#include "user_dc.h"

MSG_FUNC( PQVipLevelUp )
{
    QU_ON( user, msg.role_id );

    vip::level_up( user );
}
