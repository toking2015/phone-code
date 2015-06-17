#ifndef IMMORTAL_GAMESVR_MONSTERIMP_H_
#define IMMORTAL_GAMESVR_MONSTERIMP_H_

#include "common.h"
#include "proto/formation.h"
#include "proto/user.h"
#include "luamgr.h"
/*
 * 战斗功能:
 * 1.常规接口: 列表/开通/移动
 */

namespace monster
{
    std::vector<S3UInt32> GetMonsterDrop( SUser *puser, uint32 monster_id );
}

#endif  //IMMORTAL_GAMESVR_MONSTERIMP_H_
