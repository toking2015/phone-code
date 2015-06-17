#ifndef _GAME_TEMPLE_EVENT_H_
#define _GAME_TEMPLE_EVENT_H_

#include "event.h"

// 神殿组合获得
struct SEventTempleGroupAdd : public SEvent
{
    uint32 group_id;

    SEventTempleGroupAdd(SUser* u, uint32 p, uint32 id) : SEvent(u, p), group_id(id) { }
};

// 神殿组合升级
struct SEventTempleGroupLevelUp : public SEvent
{
    uint32 group_id;
    uint32 new_level;

    SEventTempleGroupLevelUp(SUser* u, uint32 p, uint32 id, uint32 nl) : SEvent(u, p), group_id(id), new_level(nl) { }
};

// 解锁神符格
struct SEventTempleOpenHole : public SEvent
{
    uint32 hole_type;

    SEventTempleOpenHole(SUser* u, uint32 p, uint32 t) : SEvent(u, p), hole_type(t) { }
};

// 镶嵌神符
struct SEventTempleGlyphEmbed : public SEvent
{
    uint32 glyph_id;
    uint32 embed_type;

    SEventTempleGlyphEmbed(SUser* u, uint32 p, uint32 id, uint32 t) : SEvent(u, p), glyph_id(id), embed_type(t) { }
};

// 培养神符
struct SEventTempleGlyphTrain : public SEvent
{
    uint32 glyph_id;
    uint32 old_level;
    uint32 new_level;

    SEventTempleGlyphTrain(SUser* u, uint32 p, uint32 id, uint32 ol, uint32 nl) : SEvent(u, p), glyph_id(id), old_level(ol), new_level(nl) { }
};

// 积分变化
struct SEventTempleScoreChanged : public SEvent
{
    SEventTempleScoreChanged(SUser* u, uint32 p) : SEvent(u, p) { }
};

#endif
