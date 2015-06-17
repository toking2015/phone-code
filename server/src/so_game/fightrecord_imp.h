#ifndef IMMORTAL_GAMESVR_FIGHTRECORDIMP_H_
#define IMMORTAL_GAMESVR_FIGHTRECORDIMP_H_

#include "common.h"
#include "proto/fight.h"
#include "fightrecord_dc.h"
#include "local.h"
/*
 * 战斗功能:
 * 1.常规接口: 列表/开通/移动
 */

namespace fightrecord
{
    uint32 Save( SFight *psfight );
} // namespace fightrecord

#endif  //IMMORTAL_GAMESVR_FIGHTRECORDIMP_H_
