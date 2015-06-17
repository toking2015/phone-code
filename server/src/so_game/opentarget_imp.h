#ifndef _IMMORTAL_SO_GAME_OPENTARGET_IMP_H_
#define _IMMORTAL_SO_GAME_OPENTARGET_IMP_H_

#include "common.h"
#include "proto/user.h"
#include "proto/opentarget.h"
#include "resource/r_opentargetext.h"

namespace opentarget
{

//领取奖励
void    Take( SUser* puser, uint32 day, uint32 guid );

//购买半价物品
void    Buy( SUser* puser, uint32 day, uint32 guid );

//检测天数
bool    CheckDay( uint32 day );

//检测条件
bool    CheckFactor( SUser* puser, COpenTargetData::SData* p_data );

}// namespace opentarget

#endif

