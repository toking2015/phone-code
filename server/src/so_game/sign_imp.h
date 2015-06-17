#ifndef _GAMESVR_SIGN_IMP_H_
#define _GAMESVR_SIGN_IMP_H_

#include "common.h"
#include "proto/common.h"
#include "proto/user.h"
#include "proto/sign.h"
#include "dynamicmgr.h"

typedef std::vector<SSign> SignList;

namespace sign
{
    void Sign(SUser *user);
    void OnPay(SUser *user, uint32 coin);
    void TakeHaoHuaReward(SUser *user);
    void TakeReward(SUser *user, uint32 reward_id);
    void ReplySignInfo(SUser *user);
    void TimeLimit(SUser *user);
}// namespace sign

#endif
