#include "misc.h"
#include "sign_imp.h"
#include "netsingle.h"
#include "user_dc.h"
#include "proto/sign.h"

MSG_FUNC(PQSignInfo)
{
    QU_ON(user, msg.role_id);

    sign::ReplySignInfo(user);
}

MSG_FUNC(PQSign)
{
    QU_ON(user, msg.role_id);

    sign::Sign(user);
}

MSG_FUNC(PQTakeSignSumReward)
{
    QU_ON(user, msg.role_id);

    sign::TakeReward(user, msg.reward_id);
}

MSG_FUNC(PQTakeHaohuaReward)
{
    QU_ON(user, msg.role_id);

    sign::TakeHaoHuaReward(user);
}
