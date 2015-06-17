#ifndef _IMMORTAL_SO_GAME_ITEM_EVENT_H_
#define _IMMORTAL_SO_GAME_ITEM_EVENT_H_

#include "event.h"

// 物品合成
struct SEventItemMerge : public SEvent
{
    uint32 merge_id;        // ItemMerge.xls的id
    std::vector<S3UInt32> merge_item;    // 合成获取的物品

    SEventItemMerge(SUser *u, uint32 p, uint32 _merge_id, std::vector<S3UInt32> _merge_item) : SEvent(u, p), merge_id(_merge_id) { merge_item = _merge_item; }
};

#endif
