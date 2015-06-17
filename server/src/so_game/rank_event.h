#ifndef _GAME_RANK_EVENT_H_
#define _GAME_RANK_EVENT_H_

#include "event.h"

//排行榜加载成功( 从数据库加载数据完成 )
struct SEventRankLoad
{
    uint32 rank_type;

    SEventRankLoad( uint32 t ) : rank_type(t) {}
};

//排行榜记录完成( 一般是能过 RankCopy.xls 控制记录时间点 )
struct SEventRankCopy
{
    uint32 rank_type;

    SEventRankCopy( uint32 t ) : rank_type(t) {}
};

#endif //_GAME_RANK_EVENT_H_
