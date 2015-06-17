#ifndef _GAME_TASK_EVENT_H_
#define _GAME_TASK_EVENT_H_

#include "event.h"
#include "resource/r_taskext.h"

//用户接受新任务
struct SEventTaskAccept : public SEvent
{
    uint32 task_id;
    CTaskData::SData* task;
    SUserTask& data;

    SEventTaskAccept( SUser* u, uint32 p, uint32 id, CTaskData::SData* t, SUserTask& d ) :
        SEvent(u, p), task_id(id), task(t), data(d){}
};

//用户完成任务
struct SEventTaskFinished : public SEvent
{
    uint32 task_id;
    CTaskData::SData* task;

    SEventTaskFinished( SUser* u, uint32 p, uint32 id, CTaskData::SData* t ) : SEvent(u, p), task_id(id), task(t){}
};

#endif

