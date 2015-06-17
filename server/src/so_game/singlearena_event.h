#ifndef _GAME_SINGLEARENA_EVENT_H_
#define _GAME_SINGLEARENA_EVENT_H_

#include "event.h"

//排行榜加载成功( 从数据库加载数据完成 )
struct SEventSingleArenaRankLoad
{
    SEventSingleArenaRankLoad(){}
};

struct SEventSingleArenaLogLoad
{
    SEventSingleArenaLogLoad(){}
};

struct SEventSingleArenaBattle : public SEvent
{
    uint32 role_id;         //挑战者id
    uint32 camp;            //战斗结果

    SEventSingleArenaBattle
    (
        SUser* u,
        uint32 p,
        uint32 id,
        uint32 c
    )   : SEvent( u, p ), role_id( id), camp( c ){}
};

#endif //_GAME_SINGLEARENA_EVENT_H_
