#ifndef _IMMORTAL_SO_GAME_TEAM_IMP_H_
#define _IMMORTAL_SO_GAME_TEAM_IMP_H_

#include "common.h"
#include "proto/user.h"

namespace team
{

void level_up( SUser* user );
void change_name( SUser *user, std::string name );
void change_avatar( SUser *user, uint32 avatar );

} // namespace team

#endif

