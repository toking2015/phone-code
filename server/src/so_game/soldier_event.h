#ifndef _GAME_SOLDIER_EVENT_H_
#define _GAME_SOLDIER_EVENT_H_

#include "event.h"

//副本事件提交处理结束后
struct SEventSoldierQualityUp : public SEvent
{
    uint32 soldier_id;
    uint32 old_quality;

    SEventSoldierQualityUp( SUser* u, uint32 id, uint32 _old_quality, uint32 p ) : SEvent( u, p ), soldier_id(id), old_quality(_old_quality){}
};

struct SEventSoldierStarUp : public SEvent
{
    uint32 soldier_id;
    uint32 old_star;

    SEventSoldierStarUp( SUser* u, uint32 id, uint32 _old_star, uint32 p ) : SEvent( u, p ), soldier_id(id), old_star(_old_star){}
};

//武将升级
struct SEventSoldierLvUp : public SEvent
{
    uint32 soldier_id;
    uint32 old_level;

    SEventSoldierLvUp( SUser* u, uint32 id, uint32 old_lv, uint32 p ) : SEvent( u, p ), soldier_id(id), old_level(old_lv){}
};

#endif //_GAME_SOLDIER_EVENT_H_

