#ifndef IMMORTAL_GAMESVR_BIASIMP_H_
#define IMMORTAL_GAMESVR_BIASIMP_H_

#include "common.h"
#include "proto/user.h"
/*
 * 掉落功能:
 * 1.常规接口: 列表/开通/移动
 */

namespace bias
{
    uint32 Random( SUser *puser, uint32 id );
    uint32 PacketRandomReward( SUser *puser, uint32 packet_id );
    void TimeLimit(SUser *user);
}

#endif  //IMMORTAL_GAMESVR_BIASIMP_H_
