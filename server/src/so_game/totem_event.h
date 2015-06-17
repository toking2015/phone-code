#ifndef _GAME_TOTEM_EVENT_H_
#define _GAME_TOTEM_EVENT_H_

#include "event.h"

// 雕文合成
struct SEventTotemGlyphMerge : public SEvent
{
    uint32 type; // 雕文类型

    SEventTotemGlyphMerge(SUser* u, uint32 p, uint32 t) : SEvent(u, p), type(t) { }
};

// 雕文镶嵌
struct SEventTotemGlyphEmbed : public SEvent
{
    uint32 type; // 雕文类型

    SEventTotemGlyphEmbed(SUser* u, uint32 p, uint32 t) : SEvent(u, p), type(t) { }
};

// 图腾技能升级
struct SEventTotemSkillLevelUp : public SEvent
{
    SEventTotemSkillLevelUp(SUser* u, uint32 p) : SEvent(u, p) { }
};

// 图腾升级
struct SEventTotemLevelUp : public SEvent
{
    uint32 id;     // 图腾id
    uint32 old_lv; // 升级前等级
    uint32 new_lv; // 升级后等级

    SEventTotemLevelUp(SUser* u, uint32 p, uint32 _id, uint32 olv, uint32 nlv)
        : SEvent(u, p), id(_id), old_lv(olv), new_lv(nlv) { }
};

#endif

