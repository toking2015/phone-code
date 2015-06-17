#ifndef _GAME_GUILD_EVENT_H_
#define _GAME_GUILD_EVENT_H_

#include "event.h"
#include "proto/guild.h"

struct SEventGuild : public SEvent
{
    SGuild* guild;

    SEventGuild( SUser* u, SGuild* g, uint32 p ) : SEvent(u, p), guild(g){}
};

//新创建公会数据初始化
struct SEventGuildInit : public SEventGuild
{
    SEventGuildInit( SGuild* g, uint32 p ) : SEventGuild( NULL, g, p ) {}
};

//公会数据加载成功
struct SEventGuildLoaded : public SEventGuild
{
    SEventGuildLoaded( SGuild* g, uint32 p ) : SEventGuild( NULL, g, p ) {}
};

//用户加入公会
struct SEventGuildJoin : public SEventGuild
{
    SEventGuildJoin( SUser* u, SGuild* g, uint32 p ) : SEventGuild( u, g, p ) {}
};

//用户退出公会
struct SEventGuildExit : public SEventGuild
{
    uint32 job;
    SEventGuildExit( SUser* u, SGuild* g, uint32 p, uint32 j ) : SEventGuild( u, g, p ), job(j) {}
};

//职务修改
struct SEventGuildJobChange : public SEventGuild
{
    SUser* target;
    uint32 old_job;
    uint32 new_job;
    SEventGuildJobChange( SUser* u, SGuild* g, uint32 p, SUser* t, uint32 oj, uint32 nj )
        : SEventGuild( u, g, p ), target(t), old_job(oj), new_job(nj) {}
};

//经验变化
struct SEventGuildXp : public SEventGuild
{
    uint32 value;
    uint32 set_type;
    SEventGuildXp(SUser *u, SGuild *g, uint32 p, uint32 v, uint32 s)
        : SEventGuild(u, g, p), value(v), set_type(s) {}
};

#endif //_GAME_GUILD_EVENT_H_
