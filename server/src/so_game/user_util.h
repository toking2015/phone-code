#ifndef _GAMESVR_USER_UTIL_H_
#define _GAMESVR_USER_UTIL_H_

#include "proto/item.h"

struct Item_EqualItemIndexAndSoldier
{
    uint16  index;
    uint32  soldier_guid;
    Item_EqualItemIndexAndSoldier(uint16 _index, uint32 _soldier_guid) {index = _index; soldier_guid = _soldier_guid;}
    bool operator () (const SUserItem& item)
    {
        return item.item_index == index && item.soldier_guid == soldier_guid;
    }
};

#endif
