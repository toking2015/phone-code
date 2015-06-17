#ifndef _GAMESVR_ALTAR_IMP_H_
#define _GAMESVR_ALTAR_IMP_H_

#include "common.h"
#include "proto/common.h"
#include "proto/fight.h"
#include "proto/user.h"
#include "proto/altar.h"
#include "dynamicmgr.h"
#include "resource/r_altarext.h"

namespace altar
{
    void InitSeed(SUser *user);
    void Lottery(SUser *user, uint32 type, uint32 count, uint32 use_type);
    void ReplyAltarInfo(SUser *user);
    void TimeLimit(SUser *user);
}// namespace altar

#endif
