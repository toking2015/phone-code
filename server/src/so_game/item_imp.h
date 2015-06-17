#ifndef _GAMESVR_ITEMLOGIC_H_
#define _GAMESVR_ITEMLOGIC_H_

#include "common.h"
#include "proto/common.h"
#include "proto/user.h"
#include "proto/item.h"
#include "resource/r_itemext.h"
#include "dynamicmgr.h"
/*
 * 物品功能:
 * 1.常规接口:      拆分/移动/整理/使用/删除/出售
 * 2.仅服务端使用:  添加/检查剩余空间
 */

#define MacroCheckItemGuid(item)\
    std::vector<SUserItem>& item_list = user->data.item_map[(item).first];\
std::vector<SUserItem>::iterator iter = std::find_if(item_list.begin(), item_list.end(), Item_EqualItemGuid((item).second));\
if (item_list.end() == iter)\
{\
    HandleErrCode(user, kErrItemGuidNotExist, 0);\
    return;\
}

#define MacorCheckItemId(pitem, item_id)\
    CItemData::SData* pitem = theItemExt.Find(item_id);\
if (!pitem)\
{\
    HandleErrCode(user, kErrItemDataNotExist, item_id);\
    return;\
}

namespace item
{
    //获得物品的可移动背包
    void GetItemBagMoves( uint32 item_id, std::vector<uint32> &bag_moves );
    void GetItemBagDel( uint32 item_id, std::vector<uint32> &bag_moves );
    //获取bag_type的空格数量, item_id == 0 返回空格子数, item_id != 0 返回可接受物品总数
    uint32 GetItemSpace( SUser *user, uint32 bag_type, uint32 item_id = 0 );
    //获取物品还可以叠加的数量
    uint32 GetItemStackableCount( SUser *user, uint32 bag_type, uint32 item_id );
    //获取空格子的Index
    uint32 GetIndex( std::vector<SUserItem> &item_list, uint32 bag_type );
    uint32 GetGuid( SUser *user );
    //取得一个物品
    bool GetUserItem( SUser *user, S2UInt32 item, SUserItem &dst_item );
    //获得某物品ID的数量
    uint32 GetItemCount( SUser *user, uint32 item_id );
    //获得某物品ID不具备 flag 属性的物品数量
    uint32 GetItemCountNotFlag( SUser *user, uint32 item_id, uint32 flag );
    //两个物品是否可以叠加
    bool CanSuperposition( SUserItem &item1, SUserItem &item2 );
    //特殊属性操作
    void GenSpecialAttr( SUser *user, SUserItem &user_item );
    //确定物品的绑定和过期
    void GenBindDueAttr( SUserItem &item, uint32 path );
    //添加物品
    void AddItem( SUser *user, uint32 item_id, uint32 count, uint32 path, uint32 flag = 0 );
    //添加物品 一般用于拍卖行购买
    void AddItem( SUser* user, const SWildItem& item, uint32 path);
    //添加到指定背包，无视配表及空间
    uint32 AddItemToBag( SUser* user, const SWildItem& item, uint32 bag_type, uint32 path );
    //根据guid删除物品item.first=bag_type, item.second=guid
    void DelItemByGuid( SUser *user, S2UInt32 item, uint32 count, uint32 path );
    //删除某个物品
    void DelItemById( SUser *user, uint32 item_id, uint32 count, uint32 path );
    //删除某个物品不具备 flag 属性的物品
    void DelItemByIdNotFlag( SUser *user, uint32 item_id, uint32 count, uint32 flag, uint32 path );
    //删除bag背包中对应soldier_guid及index的物品
    void DelItem(SUser *user, uint32 bag, uint32 soldier_guid, uint32 index, uint32 path);
    //拆分物品
    void DiceItem( SUser *user, S2UInt32 item, uint32 dice_count);
    //移动物品 src.second = guid, dst.second = index
    bool MoveItem( SUser *user, S2UInt32 src, S2UInt32 dst, uint32 soldier_guid );
    //使用物品
    void UseItem( SUser *user, S2UInt32 item, uint32 use_num, uint32 index);
    //出售物品
    void SellItem( SUser* user, uint32 bag_type, std::vector<S2UInt32>& item_list);
    //整理物品
    void SortItem( SUser *user, uint32 bag_type );
    //物品赎回
    void Redeem( SUser *user, uint32 guid );
    //物品合成
    bool Merge( SUser *user, uint32 id, uint32 count );
    void Equip( SUser *user, S2UInt32 item, uint32 soldier_guid );
    void ReplyMerge(SUser *user, uint32 id, uint32 count);
    std::vector<SUserItem> GetSoldierItem( SUser *user, uint32 soldier_guid );

    void ReplyItemList( SUser* user, int32 bag_index );
    void ReplyItemSet( SUser* user, SUserItem &item, uint8 set_type, uint32 path );
}// namespace item

#endif
