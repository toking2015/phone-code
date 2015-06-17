#ifndef _IMMORTAL_SO_GAME_EQUIP_EVENT_H_
#define _IMMORTAL_SO_GAME_EQUIP_EVENT_H_

#include "event.h"

struct SEventEquipGradeUpdate : public SEvent
{
    uint32 equip_type;
    uint32 level;
    SEventEquipGradeUpdate(SUser *u, uint32 p, uint32 _type, uint32 _level) : SEvent(u, p), equip_type(_type), level(_level) {}
};

#endif
