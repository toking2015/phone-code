#ifndef _GAME_COPY_EVENT_H_
#define _GAME_COPY_EVENT_H_

#include "event.h"

//副本事件提交处理结束后
struct SEventCopyCommit : public SEvent
{
    uint32 copy_id;

    SEventCopyCommit( SUser* u, uint32 p, uint32 id ) : SEvent( u, p ), copy_id(id){}
};

//单个副本通关
struct SEventCopyFinished : public SEvent
{
    uint32 copy_id;

    SEventCopyFinished( SUser* u, uint32 p, uint32 id ) : SEvent(u, p), copy_id(id){}
};

//副本集群完成后
struct SEventCopyGroupFinished : public SEvent
{
    uint32 gid; //副本集群id( copy_id / 10 )

    SEventCopyGroupFinished( SUser* u, uint32 p, uint32 id ) : SEvent(u, p), gid(id){}
};

//副本区域完成后
struct SEventCopyAreaFinished : public SEvent
{
    uint32 aid; //副本区域id( copy_id / 1000 )

    SEventCopyAreaFinished( SUser* u, uint32 p, uint32 id ) : SEvent(u, p), aid(id){}
};

//副本区域满星完成后( 用户触发满星奖励领取后才算通关 )
struct SEventCopyAreaPresentTake : public SEvent
{
    uint32 mopup_type;
    uint32 aid; //副本区域id( copy_id / 1000 )
    uint32 area_attr;

    SEventCopyAreaPresentTake( SUser* u, uint32 p, uint32 t, uint32 id, uint32 a ) :
        SEvent(u, p), mopup_type(t), aid(id), area_attr(a){}
};

//副本boss击杀后
struct SEventCopyBossKill : public SEvent
{
    uint32 mopup_type;
    uint32 boss_id;

    SEventCopyBossKill( SUser* u, uint32 p, uint32 t, uint32 b ) : SEvent(u, p), mopup_type(t), boss_id(b){}
};

//副本boss扫荡后
struct SEventCopyBossMopup : SEventCopyBossKill
{
    uint32 count;

    SEventCopyBossMopup( SUser* u, uint32 p, uint32 t, uint32 b, uint32 c )
        : SEventCopyBossKill( u, p, t, b ), count(c){}
};
#endif //_GAME_COPY_EVENT_H_

