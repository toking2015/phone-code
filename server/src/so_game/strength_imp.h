#ifndef _IMMORTAL_SO_GAME_STRENGTH_IMP_H_
#define _IMMORTAL_SO_GAME_STRENGTH_IMP_H_

#include "proto/user.h"

namespace strength
{

//体力的增加和别的货币有所不同 只要是没满都可以i加 只要是满了就不能加
uint32 GetSpace( SUser* user );

//购买单次体力
void buy( SUser* user );

} // namespace strength

#endif
