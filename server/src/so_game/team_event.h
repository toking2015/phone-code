#ifndef _IMMORTAL_SO_GAME_TEAM_EVENT_H_
#define _IMMORTAL_SO_GAME_TEAM_EVENT_H_

#include "event.h"

//战队等级升级
struct SEventTeamLevelUp : public SEvent
{
    uint32 old_level;
    SEventTeamLevelUp( SUser* u, uint32 p, uint32 lv ) : SEvent(u, p), old_level(lv){}
};

//玩家角色头像更改
struct SEventAvatarChange : public SEvent
{
    uint32 avatar;
    SEventAvatarChange( SUser* u, uint32 p, uint32 av ) : SEvent(u, p), avatar(av){}
};

//玩家角色名字更改
struct SEventNameChange : public SEvent
{
    std::string name;
    SEventNameChange( SUser* u, uint32 p, std::string n ) : SEvent(u, p), name(n){}
};

#endif
