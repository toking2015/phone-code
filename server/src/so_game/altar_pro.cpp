#include "misc.h"
#include "altar_imp.h"
#include "netsingle.h"
#include "user_dc.h"
#include "proto/altar.h"

MSG_FUNC(PQAltarInfo)
{
    QU_ON(user, msg.role_id);

    altar::ReplyAltarInfo(user);
}

MSG_FUNC(PQAltarLottery)
{
    QU_ON(user, msg.role_id);

    altar::Lottery(user, msg.lottery_type, msg.lottery_count, msg.use_type);
}
