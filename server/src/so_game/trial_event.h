#ifndef _GAME_TRIAL_EVENT_H_
#define _GAME_TRIAL_EVENT_H_

#include "event.h"

//提交处理结束后
struct SEventTrialFinished: public SEvent
{
    uint32 id;

    SEventTrialFinished( SUser* u, uint32 p, uint32 _id ) : SEvent( u, p ), id(id){}
};

struct SEventTrialRewardGet: public SEvent
{
    uint32 index;

    SEventTrialRewardGet( SUser* u, uint32 p, uint32 _index ) : SEvent( u, p ), index(_index){}
};


#endif //_GAME_TRIAL_EVENT_H_
