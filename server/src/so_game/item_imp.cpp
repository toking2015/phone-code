#include "item_imp.h"
#include "bias_imp.h"
#include "coin_imp.h"
#include "coin_event.h"
#include "item_event.h"
#include "misc.h"
#include "local.h"
#include "netsingle.h"
#include "resource/r_itemext.h"
#include "resource/r_itemtypeext.h"
#include "resource/r_bagcountext.h"
#include "resource/r_itemmergeext.h"
#include "resource/r_rewardext.h"
#include "resource/r_packetext.h"
#include "resource/r_itemopenext.h"
#include "proto/item.h"
#include "proto/constant.h"
#include "proto/soldier.h"
#include "pro.h"
#include "log.h"
#include "user_imp.h"
#include "bias_imp.h"
#include "user_event.h"
#include "server.h"
#include "user_util.h"

/*****************BEGIN-Functor********************/
struct Item_EqualItemGuid
{
    uint32 guid;
    Item_EqualItemGuid(uint32 _guid) {guid = _guid;}
    bool operator () (const SUserItem& item)
    {
        return item.guid == guid;
    }
};

struct coin_equal_cate_objid
{
    uint32 cate;
    uint32 objid;
    coin_equal_cate_objid( uint32 c, uint32 i ):cate(c), objid(i){}

    bool operator()( S3UInt32& coin )
    {
        return ( coin.cate == cate && coin.objid == objid );
    }
};

struct Item_GreaterItem
{
    bool operator () (const SUserItem& item1, const SUserItem& item2)
    {
        CItemData::SData* pitem1 = theItemExt.Find(item1.item_id);
        CItemData::SData* pitem2 = theItemExt.Find(item2.item_id);
        if ( NULL == pitem1 )
            return false;
        if ( NULL == pitem2 )
            return false;
        return pitem1->type < pitem2->type ||
            (pitem1->type == pitem2->type && pitem1->subclass < pitem2->subclass) ||
            (pitem1->type == pitem2->type && pitem1->subclass == pitem2->subclass && pitem1->level < pitem2->level) ||
            (pitem1->type == pitem2->type && pitem1->subclass == pitem2->subclass && pitem1->level == pitem2->level && pitem1->id < pitem2->id)||
            (pitem1->type == pitem2->type && pitem1->subclass == pitem2->subclass && pitem1->level == pitem2->level && pitem1->id == pitem2->id && item1.flags < item2.flags);
    }
};
struct Item_LessItemIndex
{
    bool operator() (const SUserItem& item1, const SUserItem& item2)
    {
        return item1.item_index < item2.item_index;
    }
};
void    FuncCopy(SWildItem& item1, const SWildItem& item2)
{
    item1 = item2;
}

struct SoulStoneCanDressChecker
{
    SoulStoneCanDressChecker(CItemData::SData* pitem, uint16 soldier_guid)
        : other_pitem(NULL), _pitem(pitem), _soldier_guid(soldier_guid)
    {}

    bool operator()(SUserItem &item)
    {
        if(item.soldier_guid == _soldier_guid)
        {
            other_pitem = theItemExt.Find(item.item_id);
            if(other_pitem)
            {
                //魂石的子类型用于判断是否装载冲突
                return 0 != (other_pitem->subclass & _pitem->subclass);
            }
        }
        return false;
    }

    CItemData::SData* other_pitem;
    CItemData::SData* _pitem;
    uint16 _soldier_guid;
};

struct Item_EqualItemIndex
{
    uint16 item_index;
    Item_EqualItemIndex(uint32 _index) {item_index = _index;}
    bool operator () (const SUserItem& item)
    {
        return item.item_index == item_index;
    }
};

//优先删除排序函数
bool item_del_sort( const SUserItem& item1, const SUserItem& item2 )
{
    CItemData::SData* pitem1 = theItemExt.Find(item1.item_id);
    CItemData::SData* pitem2 = theItemExt.Find(item2.item_id);
    if ( NULL == pitem1 )
        return false;
    if ( NULL == pitem2 )
        return false;
    //先看到期时间
    return item1.due_time < item2.due_time;
}

namespace item
{

uint32 GetIndex( std::vector<SUserItem> &item_list, uint32 bag_type )
{
    std::map<uint32,bool> item_map;
    for( std::vector<SUserItem>::iterator iter = item_list.begin();
        iter != item_list.end();
        ++iter )
    {
        item_map[iter->item_index] = true;
    }
    uint32 index = 0;
    for( std::map<uint32,bool>::iterator iter = item_map.begin();
        iter != item_map.end();
        ++iter,++index )
    {
        if ( index != iter->first )
            break;
    }
    return index;
}

uint32 GetGuid( SUser *user )
{
    //将已用guid压放置used_guid_map
    std::map< uint32, bool > used_guid_map;
    std::map< uint32, std::vector< SUserItem > > &item_list_map = user->data.item_map;
    for ( std::map< uint32, std::vector< SUserItem > >::iterator iter = item_list_map.begin();
        iter != item_list_map.end();
        ++iter )
    {
        for ( std::vector< SUserItem >::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            used_guid_map[ jter->guid ] = true;
        }
    }

    //顺序查找没有使用的guid
    uint32 guid = 1;
    for ( std::map< uint32, bool >::iterator iter = used_guid_map.begin();
        iter != used_guid_map.end();
        ++iter,++guid )
    {
        if ( iter->first != guid )
            break;
    }
    return guid;
}

bool GetUserItem( SUser *user, S2UInt32 item, SUserItem &dst_item )
{
    std::vector<SUserItem>& item_list = user->data.item_map[(item).first];
    std::vector<SUserItem>::iterator iter = std::find_if(item_list.begin(), item_list.end(), Item_EqualItemGuid((item).second));
    if (item_list.end() == iter)
        return false;

    dst_item = *iter;
    return true;
}

std::vector<SUserItem> GetSoldierItem( SUser *user, uint32 soldier_guid )
{
    std::vector<SUserItem> temp_list;

    std::vector<SUserItem>& item_list = user->data.item_map[kBagFuncSoldierEquip];
    for( std::vector<SUserItem>::iterator iter = item_list.begin();
        iter != item_list.end();
        ++iter )
    {
        if ( iter->soldier_guid == soldier_guid )
            temp_list.push_back(*iter);
    }
    return temp_list;
}

uint32 GetItemSpace( SUser *user, uint32 bag_type, uint32 item_id/* = 0 */ )
{
    std::vector<SUserItem> &item_list = user->data.item_map[bag_type];

    uint32 bag_size = 0;
    CBagCountData::SData* pdata = theBagCountExt.Find(bag_type);
    if ( NULL != pdata )
        bag_size = pdata->bag_init;

    switch (bag_type)
    {
        case kBagFuncCommon:
            break;
        default:
            break;
    }

    uint32 space_count = bag_size > item_list.size() ? bag_size - item_list.size() : 0;
    if ( item_id == 0 )
        return space_count;

    CItemData::SData* pitem = theItemExt.Find(item_id);
    if ( pitem == NULL )
        return space_count;

    uint32 stackable = std::max( pitem->stackable, (uint32)1 );

    return GetItemStackableCount( user, bag_type, item_id ) + space_count * stackable;
}

uint32 GetItemStackableCount( SUser *user, uint32 bag_type, uint32 item_id )
{
     std::vector<SUserItem> &item_list = user->data.item_map[bag_type];

     uint32 sub_count = 0;
     for( std::vector<SUserItem>::iterator iter = item_list.begin();
         iter != item_list.end();
         ++iter )
     {
        if ( iter->item_id == item_id )
        {
            CItemData::SData* pitem = theItemExt.Find(item_id);
            if ( pitem == NULL )
                return 0;

            sub_count += pitem->stackable > iter->count ? pitem->stackable - iter->count : 0;
        }
     }
    return sub_count;
}

//特殊处理的属性 根据物品的类型进行处理
void GenSpecialAttr( SUser *user, SUserItem& use_item )
{
    MacorCheckItemId( pitem, use_item.item_id );
    use_item.slotattr.resize(kItemSlotMax);
}

//确定物品的绑定和过期
void GenBindDueAttr( SUserItem &item, uint32 path )
{
    CItemData::SData* pitem = theItemExt.Find(item.item_id);
    if ( NULL == pitem )
        return;
    if ( 0 != pitem->bind )
        item.flags |= kCoinFlagBind;
    uint32 time_now = (uint32)server::local_time();
    if ( 0 != pitem->due_time )
        item.due_time = time_now + pitem->due_time;
}

void GetItemBagMoves( uint32 item_id, std::vector<uint32> &bag_moves )
{
    CItemData::SData* pitem = theItemExt.Find(item_id);
    if ( NULL == pitem )
        return;
    CItemTypeData::SData* pitemtype = theItemTypeExt.Find(pitem->type);
    //默认情况就是从背包和仓库找
    if ( NULL == pitemtype )
    {
        bag_moves.push_back(kBagFuncCommon);
        bag_moves.push_back(kBagFuncBank);
    }
    else
        bag_moves = pitemtype->bag_moves;

    bag_moves.push_back(kBagFuncRedeem);
}

void GetItemBagDel( uint32 item_id, std::vector<uint32> &bag_moves )
{
    CItemData::SData* pitem = theItemExt.Find(item_id);
    if ( NULL == pitem )
        return;
    CItemTypeData::SData* pitemtype = theItemTypeExt.Find(pitem->type);
    //默认情况就是从背包和仓库找
    if ( NULL == pitemtype )
    {
        bag_moves.push_back(kBagFuncCommon);
        bag_moves.push_back(kBagFuncBank);
    }
    else
        bag_moves = pitemtype->bag_moves;
}

uint32 GetItemCount( SUser *user, uint32 item_id )
{
    std::vector<uint32> bag_moves;
    GetItemBagDel( item_id, bag_moves );

    uint32 count = 0;
    for( std::vector<uint32>::iterator iter_bag = bag_moves.begin();
        iter_bag != bag_moves.end();
        ++iter_bag )
    {
        std::vector<SUserItem> &item_list = user->data.item_map[*iter_bag];
        for( std::vector<SUserItem>::iterator iter = item_list.begin();
            iter != item_list.end();
            ++iter )
        {
            if ( iter->item_id == item_id )
                count += iter->count;
        }
    }
    return count;
}

uint32 GetItemCountNotFlag( SUser *user, uint32 item_id, uint32 flag )
{
    std::vector<uint32> bag_moves;
    GetItemBagDel( item_id, bag_moves );

    for( std::vector<uint32>::iterator iter = bag_moves.begin();
        iter != bag_moves.end(); )
    {
        if ( 0 == *iter || kBagFuncRedeem == *iter )
            iter = bag_moves.erase(iter);
        else
            ++iter;
    }

    uint32 count = 0;
    for( std::vector<uint32>::iterator iter_bag = bag_moves.begin();
        iter_bag != bag_moves.end();
        ++iter_bag )
    {
        std::vector<SUserItem> &item_list = user->data.item_map[*iter_bag];
        for( std::vector<SUserItem>::iterator iter = item_list.begin();
            iter != item_list.end();
            ++iter )
        {
            if ( iter->item_id != item_id )
                continue;

            if ( state_is( iter->flags, flag ) )
                continue;

            count += iter->count;
        }
    }
    return count;
}

//item1是否可以叠加到item2
bool CanSuperposition( SUserItem &item1, SUserItem &item2 )
{
    CItemData::SData* pitem1 = theItemExt.Find(item1.item_id);
    CItemData::SData* pitem2 = theItemExt.Find(item2.item_id);
    if ( NULL == pitem1 || NULL == pitem2 )
        return false;

    if ( item1.item_id != item2.item_id )
        return false;

    if ( item1.soldier_guid != item2.soldier_guid )
        return false;

    if ( item2.count >= pitem1->stackable && 0 != pitem1->stackable )
        return false;

    if ( item1.due_time != item2.due_time )
        return false;

    if ( item1.flags != item2.flags )
        return false;
    return true;
}

void AddItem( SUser *user, uint32 item_id, uint32 count, uint32 path, uint32 flag )
{
    MacorCheckItemId(pitem, item_id);

    uint32 add_count = count;
    uint32 old_count = GetItemCount( user, item_id );

    uint32 bag_type = kBagFuncCommon;
    CItemTypeData::SData *pitemtype = theItemTypeExt.Find( pitem->type );
    if ( NULL != pitemtype && 0 != pitemtype->bag_type )
        bag_type = pitemtype->bag_type;

    std::vector<SUserItem> &item_list = user->data.item_map[bag_type];

    SUserItem user_item;
    //确定物品的绑定和过期时间
    user_item.item_id = item_id;
    user_item.flags = state_is( flag, kCoinFlagBind ) ? kCoinFlagBind : 0;
    GenBindDueAttr( user_item, path );
    //可叠加
    if ( 1 != pitem->stackable )
    {
        for ( std::vector<SUserItem>::iterator iter = item_list.begin(); iter != item_list.end() && count > 0; ++iter )
        {
            if ( !CanSuperposition( user_item, *iter ) )
                continue;

            if ( 0 == count )
                break;

            if ( 0 == pitem->stackable )
            {
                iter->count += count;
                count = 0;
            }
            else
            {
                if ( iter->count + count > pitem->stackable )
                {
                    iter->count = pitem->stackable;
                    count -= pitem->stackable > iter->count ?
                        pitem->stackable - iter->count : 0;
                }
                else
                {
                    iter->count += count;
                    count = 0;
                }
            }
            ReplyItemSet( user, *iter, kObjectUpdate, path );
        }
    }

    while( 0 < count )
    {
        if ( 0 == GetItemSpace(user, bag_type) )
        {
            //邮件发送
            break;
        }
        else
        {
            user_item.item_index = GetIndex(item_list, bag_type);
            user_item.guid       = GetGuid( user );
            user_item.item_id    = pitem->id;
            user_item.bag_type   = bag_type;

            //
            GenSpecialAttr(user, user_item);

            if (0 == pitem->stackable || count <= pitem->stackable)
            {
                user_item.count =  count;
            }
            else
            {
                user_item.count =  pitem->stackable;
            }
            count -= user_item.count;
            item_list.push_back(user_item);
            ReplyItemSet( user, user_item, kObjectAdd, path );
        }
    }

    //货币事件
    event::dispatch( SEventCoin( user, path, kCoinItem, item_id, add_count, kObjectAdd, old_count ) );
}

void AddItem( SUser* user, const SWildItem& item, uint32 path)
{
    MacorCheckItemId(pitem, item.item_id);

    uint32 bag_type = kBagFuncCommon;
    CItemTypeData::SData *pitemtype = theItemTypeExt.Find( pitem->type );
    if ( NULL != pitemtype && 0 != pitemtype->bag_type )
        bag_type = pitemtype->bag_type;

    std::vector<SUserItem>& item_list = user->data.item_map[bag_type];

    if ( 0 == GetItemSpace( user, bag_type ) )
        return;

    uint32 old_count = GetItemCount( user, item.item_id );

    SUserItem user_item;
    (SWildItem&)user_item = item;
    user_item.item_index  = GetIndex( item_list, bag_type );
    user_item.guid        = GetGuid( user );
    user_item.bag_type    = bag_type;

    item_list.push_back(user_item);
    ReplyItemSet( user, user_item, kObjectAdd, path );

    //货币事件
    event::dispatch( SEventCoin( user, path, kCoinItem, item.item_id, 1, kObjectAdd, old_count ) );
}

//添加到指定背包，无视配表及空间
uint32 AddItemToBag( SUser* user, const SWildItem& item, uint32 bag_type, uint32 path )
{
    CItemData::SData* pitem = theItemExt.Find(item.item_id);
    if (!pitem)
        return 0;

    std::vector<SUserItem>& item_list = user->data.item_map[bag_type];
    uint32 old_count = GetItemCount( user, item.item_id );

    SUserItem user_item;
    (SWildItem&)user_item = item;
    user_item.item_index  = GetIndex( item_list, bag_type );
    user_item.guid        = GetGuid( user );
    user_item.bag_type    = bag_type;

    item_list.push_back(user_item);
    ReplyItemSet( user, user_item, kObjectAdd, path );

    //货币事件
    event::dispatch( SEventCoin( user, path, kCoinItem, item.item_id, 1, kObjectAdd, old_count ) );
    return user_item.guid;
}

//根据guid删除物品item.first=bag_type, item.second=guid 调用这个方法的时候小心vector删除的风险
void DelItemByGuid( SUser *user, S2UInt32 item, uint32 count, uint32 path )
{
    MacroCheckItemGuid(item);

    uint32 old_count = iter->count;
    //删除这个物品
    if ( 0 == count || iter->count <= count )
    {
        ReplyItemSet(user,*iter, kObjectDel, path );
        item_list.erase(iter);
    }
    else
    {
        iter->count -= count;
        ReplyItemSet(user, *iter, kObjectUpdate, path );
    }

    //货币事件
    event::dispatch( SEventCoin( user, path, kCoinItem, iter->item_id, count, kObjectDel, old_count ) );
}

//根据ID删除物品
void DelItemById( SUser *user, uint32 item_id, uint32 count, uint32 path )
{
    std::vector<uint32> bag_moves;
    GetItemBagDel( item_id, bag_moves );

    //uint32 old_count = GetItemCount(user, item_id);
    //先把所有目标都放到一个临时List
    std::vector<SUserItem> item_del_list;
    for( std::vector<uint32>::iterator iter_bag = bag_moves.begin();
        iter_bag != bag_moves.end();
        ++iter_bag )
    {
        std::vector<SUserItem> &item_list = user->data.item_map[*iter_bag];
        for( std::vector<SUserItem>::iterator iter = item_list.begin();
            iter != item_list.end();
            ++iter )
        {
            //找到物品
            if ( iter->item_id == item_id )
            {
                item_del_list.push_back(*iter);
            }
        }
    }
    //进行删除的优先级排序
    std::sort( item_del_list.begin(), item_del_list.end(), item_del_sort );

    //一个一个删除
    S2UInt32 del_item;
    for( std::vector<SUserItem>::iterator iter = item_del_list.begin();
        iter != item_del_list.end();
        ++iter )
    {
        if ( 0 == count )
            break;

        del_item.first = iter->bag_type;
        del_item.second = iter->guid;
        if ( iter->count <= count )
        {
            DelItemByGuid(user, del_item, iter->count, path );
            count -= iter->count;
        }
        else
        {
            DelItemByGuid(user, del_item, count, path );
            count = 0;
        }
    }

    //货币事件 这个事件不过派发在 DelItemByGuid里面有派发了
    //event::dispatch( SEventCoin( user, path, kCoinItem, item_id, count, kObjectDel, old_count ) );
}

//删除某个物品不具备 flag 属性的物品
void DelItemByIdNotFlag( SUser *user, uint32 item_id, uint32 count, uint32 flag, uint32 path )
{
    std::vector<uint32> bag_moves;
    GetItemBagDel( item_id, bag_moves );

    uint32 old_count = GetItemCount(user, item_id);

    //先把所有目标都放到一个临时List
    std::vector<SUserItem> item_del_list;
    for( std::vector<uint32>::iterator iter_bag = bag_moves.begin();
        iter_bag != bag_moves.end();
        ++iter_bag )
    {
        std::vector<SUserItem> &item_list = user->data.item_map[*iter_bag];
        for( std::vector<SUserItem>::iterator iter = item_list.begin();
            iter != item_list.end();
            ++iter )
        {
            //找到物品
            if ( iter->item_id != item_id )
                continue;

            if ( state_is( iter->flags, flag ) )
                continue;

            item_del_list.push_back(*iter);
        }
    }

    //进行删除的优先级排序
    std::sort( item_del_list.begin(), item_del_list.end(), item_del_sort );

    //一个一个删除
    S2UInt32 del_item;
    for( std::vector<SUserItem>::iterator iter = item_del_list.begin();
        iter != item_del_list.end();
        ++iter )
    {
        if ( 0 == count )
            break;
        del_item.first = iter->bag_type;
        del_item.second = iter->guid;
        if ( iter->count <= count )
        {
            DelItemByGuid(user, del_item, iter->count, path );
            count -= iter->count;
        }
        else
        {
            DelItemByGuid(user, del_item, count, path );
            count = 0;
        }
    }

    //货币事件
    event::dispatch( SEventCoin( user, path, kCoinItem, item_id, count, kObjectDel, old_count ) );
}

void DelItem(SUser *user, uint32 bag, uint32 soldier_guid, uint32 index, uint32 path)
{
    std::vector<SUserItem> &item_list = user->data.item_map[bag];
    std::vector<SUserItem>::iterator iter = std::find_if(item_list.begin(), item_list.end(), Item_EqualItemIndexAndSoldier(index, soldier_guid));
    if (iter == item_list.end())
        return;
    S2UInt32 src_item;
    src_item.first = bag;
    src_item.second = iter->guid;
    item::DelItemByGuid(user, src_item, iter->count, path);
}

void DiceItem( SUser *user, S2UInt32 item, uint32 dice_count)
{
    std::vector<SUserItem>& item_list = user->data.item_map[item.first];
    std::vector<SUserItem>::iterator iter = std::find_if(item_list.begin(), item_list.end(), Item_EqualItemGuid(item.second));
    if ( item_list.end() == iter )
    {
        HandleErrCode(user, kErrItemGuidNotExist, 0 );
        return;
    }

    if ( 0 == GetItemSpace( user, item.first ) )
        return;

    if ( 0 == dice_count )
        return;

    if ( iter->count < 2 || dice_count > iter->count )
    {
        HandleErrCode(user, kErrItemDiceCount, 0);
        return;
    }

    if ( dice_count == iter->count )
    {
        uint32 index = GetIndex( item_list, item.first );
        S2UInt32 temp_dst;
        temp_dst.first = item.first;
        temp_dst.second = index;
        MoveItem( user, item, temp_dst, iter->soldier_guid );
        return;
    }

    if ( dice_count < iter->count )
    {
        iter->count -= dice_count;
        ReplyItemSet( user, *iter, kObjectUpdate, kPathItemDice);

        SUserItem user_item = *iter;
        user_item.item_index= GetIndex(item_list, item.first);
        user_item.guid      = GetGuid( user );
        user_item.count     = dice_count;

        item_list.push_back(user_item);
        ReplyItemSet( user, user_item, kObjectAdd, kPathItemDice);
    }
}

//返回成功与否 移动物品函数中不添加其他操作 需要操作的请判断返回值 再进行操作
//装备穿戴请新增加协议 然后进行条件判断之后 再调用MoveItem
bool MoveItem( SUser *user, S2UInt32 src, S2UInt32 dst, uint32 soldier_guid )
{
    //检查物品guid
    std::vector<SUserItem>& item_list = user->data.item_map[src.first];
    std::vector<SUserItem>::iterator iter = std::find_if(item_list.begin(), item_list.end(), Item_EqualItemGuid(src.second));
    if ( item_list.end() == iter )
    {
        HandleErrCode(user, kErrItemGuidNotExist, 0 );
        return false;
    }
    //检查item_id,返回pitem
    CItemData::SData* pitem = theItemExt.Find(iter->item_id);
    if ( NULL == pitem )
    {
        HandleErrCode(user, kErrItemDataNotExist, iter->item_id);
        return false;
    }

    //判断是否是同一个地方
    if ( iter->item_index == dst.second && src.first == dst.first )
        return false;

    //是否可以移动
    std::vector<uint32> move_bags;
    GetItemBagMoves( iter->item_id, move_bags );
    std::vector<uint32>::iterator iter_move = std::find(move_bags.begin(), move_bags.end(), dst.first );
    if ( iter_move == move_bags.end() )
    {
        HandleErrCode( user, kErrItemMoveIllegalBag, 0 );
        return false;
    }

    //取目的地的物品信息
    std::vector<SUserItem>& dst_item_list = user->data.item_map[dst.first];
    std::vector<SUserItem>::iterator dst_iter = std::find_if(dst_item_list.begin(), dst_item_list.end(), Item_EqualItemIndexAndSoldier(dst.second, soldier_guid));
    if (dst_item_list.end() == dst_iter)
    {
        if (src.first == dst.first)
        {
            iter->item_index            = dst.second;
            ReplyItemSet( user, *iter, kObjectUpdate, kPathItemMove );
        }
        else
        {
            SUserItem dst_user_item     = *iter;
            dst_user_item.bag_type      = dst.first;
            dst_user_item.item_index    = dst.second;
            dst_user_item.soldier_guid  = soldier_guid;
            ReplyItemSet( user, *iter, kObjectDel, kPathItemMove);
            item_list.erase(iter);

            ReplyItemSet( user, dst_user_item, kObjectAdd, kPathItemMove);
            dst_item_list.push_back(dst_user_item);
        }
    }
    else
    {
        //可以叠加的条件下
        if ( CanSuperposition( *iter, *dst_iter ) )
        {
            if ( 0 == pitem->stackable || dst_iter->count + iter->count <= pitem->stackable )
            {
                dst_iter->count += iter->count;
                ReplyItemSet( user, *dst_iter, kObjectUpdate, kPathItemMove);
                ReplyItemSet( user, *iter, kObjectDel, kPathItemMove);
                item_list.erase(iter);
            }
            else
            {
                uint32 sub_count = pitem->stackable > dst_iter->count ? pitem->stackable - dst_iter->count : 0;
                iter->count = iter->count > sub_count ? iter->count - sub_count : 0;
                dst_iter->count = dst_iter->count > pitem->stackable ? dst_iter->count : pitem->stackable;
                if ( 0 != sub_count )
                {
                    ReplyItemSet( user, *dst_iter, kObjectUpdate, kPathItemMove);
                    ReplyItemSet( user, *iter, kObjectUpdate, kPathItemMove);
                }
            }
        }
        else
        {
            //使用对调物品信息,使用自己GUID/INDEX
            SUserItem tmp_item      = *dst_iter;
            uint16 guid             = dst_iter->guid;
            uint16 index            = dst_iter->item_index;
            uint16 bag_type         = dst_iter->bag_type;
            uint32 soldier_guid     = dst_iter->soldier_guid;
            //目的
            *dst_iter               = *iter;
            dst_iter->guid          = guid;
            dst_iter->item_index    = index;
            dst_iter->bag_type      = bag_type;
            dst_iter->soldier_guid  = soldier_guid;

            guid                    = iter->guid;
            index                   = iter->item_index;
            bag_type                = iter->bag_type;
            soldier_guid            = iter->soldier_guid;

            //源
            *iter                   = tmp_item;
            iter->guid              = guid;
            iter->item_index        = index;
            iter->bag_type          = bag_type;
            iter->soldier_guid      = soldier_guid;
            //先发送src, 再发送dst
            ReplyItemSet( user, *iter, kObjectUpdate, kPathItemMove);
            ReplyItemSet( user, *dst_iter, kObjectUpdate, kPathItemMove);
        }
    }
    return true;
}

uint32 item_open_reward_get_value( CItemOpenData::SData *pdata )
{
    return pdata->percent;
}

void UseItem( SUser *user, S2UInt32 item, uint32 use_num, uint32 index)
{
    //检查物品guid
    MacroCheckItemGuid(item);
    //检查item_id,返回pitem
    MacorCheckItemId(pitem, iter->item_id);
    //限制条件

    if ( user->data.simple.team_level < pitem->limitlevel )
    {
        HandleErrCode(user, kErrItemUseLimitLevel, 0 );
        return;
    }

    S3UInt32 cost;
    cost.cate = kCoinItem;
    cost.objid = iter->item_id;
    cost.val = use_num;

    //使用
    switch ( pitem->buff.cate )
    {
        case kItemUseAddRewardRandom:
        {
            uint32 ret = coin::check_take( user, cost );
            if ( ret != 0 )
            {
                coin::reply_lack( user, ret );
                return;
            }

            //coin::take(user, cost, kPathItemUse );
            for( uint32 i = 1; i <= use_num; ++i )
            {
                uint32 open_id = pitem->id;
                if ( 0 != pitem->bias_id )
                {
                    uint32 back_id = bias::Random( user, pitem->bias_id );
                    if ( 0 != back_id )
                    {
                        open_id = back_id;
                    }
                }
                std::vector<CItemOpenData::SData*> plist = theItemOpenExt.GetRandomList( open_id, user->data.simple.team_level);
                if ( plist.empty() )
                {
                    cost.val = i-1;
                    break;
                }

                CItemOpenData::SData *pdata = round_rand( plist, item_open_reward_get_value );
                if ( NULL == pdata )
                {
                    cost.val = i-1;
                    break;
                }

                CRewardData::SData* preward = theRewardExt.Find( pdata->reward );
                if ( NULL == preward )
                {
                    cost.val = i-1;
                    break;
                }

                if ( 0 != coin::check_give( user, preward->coins ) )
                {
                    cost.val = i-1;
                    break;
                }

                coin::give(user, preward->coins, kPathItemUse );
            }
            if ( cost.val > 0 )
                coin::take(user, cost, kPathItemUse );
        }
        break;
        case kItemUseAddRewardIndex:
        {
            std::vector<CItemOpenData::SData*> plist = theItemOpenExt.GetRandomList( pitem->id, user->data.simple.team_level);
            if ( plist.empty() )
            {
                HandleErrCode( user, kErrItemOpenRewardDataNoExitLevel, 0 );
                return;
            }
            index--;
            if ( index >= plist.size() )
                return;
            CItemOpenData::SData *pdata = plist[index];
            if ( NULL == pdata )
            {
                HandleErrCode( user, kErrItemOpenRewardDataNoExitLevel, 0 );
                return;
            }

            CRewardData::SData* preward = theRewardExt.Find( pdata->reward );
            if ( NULL == preward )
                return;

            uint32 ret = coin::check_take( user, cost );
            if ( ret != 0 )
            {
                coin::reply_lack( user, ret );
                return;
            }

            //coin::take(user, cost, kPathItemUse );
            for( uint32 i = 1; i <= use_num; ++i )
            {
                if ( 0 != coin::check_give( user, preward->coins ) )
                {
                    cost.val = i-1;
                    break;
                }
                coin::give(user, preward->coins, kPathItemUse );
            }
            if ( cost.val > 0 )
                coin::take(user, cost, kPathItemUse );
        }
        break;
        default:
            break;
    }

    PRItemUse rep;
    bccopy( rep, user->ext );
    rep.item_id = iter->item_id;
    rep.count = cost.val;
    local::write( local::access, rep );
}

//出售物品，可能的情况是放入回收站
void SellItem( SUser *puser, uint32 bag_type, std::vector<S2UInt32>& item_list)
{
    S2UInt32 dst;
    dst.first = kBagFuncRedeem;
    std::vector<S3UInt32 > coins;
    S3UInt32 coin;

    std::vector<SUserItem> &list = puser->data.item_map[bag_type];

    for( std::vector<S2UInt32>::iterator iter = item_list.begin();
        iter != item_list.end();
        ++iter )
    {
        std::vector<SUserItem>::iterator jter = std::find_if( list.begin(), list.end(), Item_EqualItemGuid(iter->first) );
        if ( jter == list.end() )
        {
            HandleErrCode(puser, kErrItemGuidNotExist, iter->second );
            break;
        }

        CItemData::SData* pitem = theItemExt.Find(jter->item_id);
        if (NULL == pitem)
        {
            HandleErrCode(puser, kErrItemDataNotExist, jter->item_id);
            break;
        }

        if ( 0 == pitem->can_sell )
        {
            HandleErrCode(puser, kErrItemNoSell, jter->item_id );
            break;
        }

        //如果卖的数量比当前的多
        if ( jter->count < iter->second )
            break;

        coin = pitem->coin;
        coin.val *= iter->second;

        if ( 0 == coin.cate || 0 == coin.val )
            break;

        uint32 max_index = 0;
        std::vector<SUserItem> &dst_item_list = puser->data.item_map[kBagFuncRedeem];

        for( std::vector<SUserItem>::iterator jter = dst_item_list.begin();
            jter != dst_item_list.end();
            ++jter )
            max_index = std::max(max_index, (uint32)jter->item_index);

        dst.second = ++max_index;

        //如果全部卖完
        if ( iter->second == jter->count )
        {
            S2UInt32 src;
            src.first = bag_type;
            src.second = iter->first;
            if ( !MoveItem(puser, src, dst, 0 ) )
                break;
        }
        else
        {
            SUserItem temp_item = *jter;
            temp_item.count = iter->second;
            temp_item.bag_type = kBagFuncRedeem;
            temp_item.item_index = max_index;
            dst_item_list.push_back(temp_item);
            ReplyItemList( puser, kBagFuncRedeem );
            jter->count -= iter->second;
            ReplyItemSet( puser, *jter, kObjectUpdate, kPathSell );
        }

        coins.push_back(coin);
    }

    coin::give( puser, coins, kPathSell );
}

//整理物品
void SortItem( SUser *user, uint32 bag_type )
{
    std::vector<SUserItem> &item_list = user->data.item_map[bag_type];
    std::sort( item_list.begin(), item_list.end(), Item_GreaterItem() );

    //叠加
    SUserItem *plastitem = NULL;
    for( std::vector<SUserItem>::iterator iter = item_list.begin();
        iter != item_list.end();
        )
    {
        //非同类
        if ( NULL == plastitem || !CanSuperposition( *plastitem, *iter ) )
        {
            plastitem = &(*iter++);
            continue;
        }

        //上限
        CItemData::SData *pitem = theItemExt.Find( plastitem->item_id );
        if ( NULL == pitem || plastitem->count >= pitem->stackable )
        {
            plastitem = &(*iter++);
            continue;
        }

        if ( 0 == pitem->stackable || plastitem->count + iter->count <= pitem->stackable )
        {
            plastitem->count += iter->count;
            iter = item_list.erase(iter);
        }
        else
        {

            uint32 sub_count = pitem->stackable > plastitem->count ? pitem->stackable - plastitem->count : 0;
            iter->count = iter->count > sub_count ? iter->count - sub_count : 0;
            plastitem->count = plastitem->count > pitem->stackable ? plastitem->count : pitem->stackable;

            plastitem = &(*iter++);
        }
    }

    //重置索引
    uint32 index = 0;
    for( std::vector<SUserItem>::iterator iter = item_list.begin();
        iter != item_list.end();
        ++iter )
    {
        iter->item_index = index++;
    }

    ReplyItemList( user, bag_type );
}

void Redeem( SUser *user, uint32 guid )
{
    std::vector<SUserItem> &item_list = user->data.item_map[kBagFuncRedeem];

    std::vector<SUserItem>::iterator iter = std::find_if(item_list.begin(), item_list.end(), Item_EqualItemGuid(guid));

    if (item_list.end() == iter)
    {
        HandleErrCode(user, kErrItemGuidNotExist, guid);
        return;
    }

    MacorCheckItemId(pitem, iter->item_id);

    CItemTypeData::SData *pitemtype = theItemTypeExt.Find( pitem->type );
    if ( NULL == pitemtype )
        return;

    uint32 bag_type = kBagFuncCommon;
    if ( 0 != pitemtype->bag_type )
        bag_type = pitemtype->bag_type;

    S3UInt32 coin = pitem->coin;
    coin.val *= iter->count;

    uint32 ret = coin::check_take( user, coin );
    if ( ret != 0 )
    {
        coin::reply_lack( user, ret );
        return;
    }
    if ( 0 == GetItemSpace( user, bag_type ) )
    {
        HandleErrCode(user, kErrItemSpaceFull, bag_type);
        return;
    }

    uint32 index = GetIndex( user->data.item_map[bag_type], bag_type );

    S2UInt32 src;
    src.first = kBagFuncRedeem;
    src.second = guid;
    S2UInt32 dst;
    dst.first = bag_type;
    dst.second = index;
    if (!MoveItem(user, src, dst, 0))
        return;

    coin::take( user, coin, kPathRedeem );
}

bool Merge( SUser *user, uint32 id, uint32 count )
{
    if (count == 0)
        count = 1;

    CItemMergeData::SData *pitemmerge = theItemMergeExt.Find( id );
    if( NULL == pitemmerge )
        return false;

    if ( user->data.simple.team_level < pitemmerge->limit_level )
    {
        HandleErrCode( user, kErrItemMergeLevel, 0 );
        return false;
    }

    std::vector<S3UInt32> materials = pitemmerge->materials;
    for (std::vector<S3UInt32>::iterator iter = materials.begin();
        iter != materials.end();
        ++iter)
    {
        iter->val *= count;
    }

    if (coin::check_take(user, materials) != 0)
        return false;

    // 合成产生的是掉落包
    uint32 reward_id = bias::PacketRandomReward( user, pitemmerge->package_id);
    CRewardData::SData *preward = theRewardExt.Find(reward_id);
    if (!preward)
        return false;

    uint32 path = kPathMerge;
    switch (pitemmerge->type)
    {
    case kItemMergeTypeEquip:
        path = kPathMergeEquip;
        break;
    case kItemMergeTypeSkillBook:
        path = kPathMergeBook;
        break;
    }

    coin::take( user, materials, path);
    std::vector<S3UInt32> coins = preward->coins;
    for (std::vector<S3UInt32>::iterator iter = coins.begin();
        iter != coins.end();
        ++iter)
    {
        iter->val *= count;
    }
    coin::give( user, coins, path);

    event::dispatch(SEventItemMerge(user, path, id, coins));

    ReplyMerge(user, id, count);
    return true;
}

void ReplyMerge(SUser *user, uint32 id, uint32 count)
{
    PRItemMerge rep;
    rep.id = id;
    rep.count = count;
    bccopy(rep, user->ext);
    local::write(local::access, rep);
}

void Equip( SUser *user, S2UInt32 item, uint32 soldier_guid )
{
    MacroCheckItemGuid( item );

    //判断是否已经存在这个物品
    std::vector<SUserItem>& item_list_equip = user->data.item_map[kBagFuncSoldierEquip];
    for( std::vector<SUserItem>::iterator jter = item_list_equip.begin();
        jter != item_list_equip.end();
        ++jter )
    {
        if ( soldier_guid == jter->soldier_guid && jter->item_id == iter->item_id )
        {
            HandleErrCode(user, kErrSoldierEquipHave, 0 );
            return;
        }
    }

    //如果只有1个
    if ( iter->count == 1 )
    {
        uint32 index = GetIndex( item_list_equip, kBagFuncSoldierEquip );
        S2UInt32 temp_dst;
        temp_dst.first = kBagFuncSoldierEquip;
        temp_dst.second = index;
        MoveItem( user, item, temp_dst, soldier_guid );
    }
    else
    {
        iter->count--;
        ReplyItemSet( user, *iter, kObjectUpdate, kPathSoldierEquip );

        SUserItem user_item = *iter;
        user_item.item_index= GetIndex(item_list_equip, kBagFuncSoldierEquip );
        user_item.guid      = GetGuid( user );
        user_item.count     = 1;
        user_item.soldier_guid = soldier_guid;
        user_item.bag_type = kBagFuncSoldierEquip;

        item_list_equip.push_back(user_item);
        ReplyItemSet( user, user_item, kObjectAdd, kBagFuncSoldierEquip );
    }

}

void ReplyItemList( SUser* user, int32 bag_type )
{
    PRItemList rep;
    rep.bag_index   = bag_type;
    rep.item_list = user->data.item_map[bag_type];
    bccopy( rep, user->ext );

    local::write( local::access, rep );
}

void ReplyItemSet( SUser* user, SUserItem &item, uint8 set_type, uint32 path )
{
    PRItemSet rep;
    rep.set_type = set_type;
    rep.path = path;
    rep.item = item;
    bccopy( rep, user->ext );

    local::write( local::access, rep );
}

}// namespace item
