#include "misc.h"
#include "proto/viptimelimitshop.h"
#include "proto/reportpost.h"
#include "netsingle.h"
#include "user_dc.h"
#include "viptimelimitshop_imp.h"
#include "user_imp.h"
#include "settings.h"
#include "log.h"
#include "command_imp.h"
#include "local.h"
#include "server.h"

MSG_FUNC( PQVipTimeLimitShopWeek )
{
    QU_ON( user, msg.role_id );

    viptimelimit_shop::ReplyWeek( user );
}

MSG_FUNC( PQVipTimeLimitShopBuy )
{
    QU_ON( user, msg.role_id );

    viptimelimit_shop::Buy( user, msg.vip_level, msg.count );
}
