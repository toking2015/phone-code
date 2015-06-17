#ifndef _IMMORTAL_SO_GAME_CHAT_IMP_H_
#define _IMMORTAL_SO_GAME_CHAT_IMP_H_

#include "common.h"

namespace chat
{

void cache_sound( uint32 rid, uint32 index, wd::CStream& bytes );
wd::CStream* find_sound( uint32 rid, uint32 index );

void clear_timeout_sound(void);

}// namespace chat

#endif

