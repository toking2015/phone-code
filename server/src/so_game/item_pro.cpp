#include "misc.h"
#include "item_imp.h"
#include "equip_imp.h"
#include "netsingle.h"
#include "resource/r_itemmergeext.h"
#include "proto/item.h"
#include "user_dc.h"

/*****************物品协议请求*****************/
//请求物品列表
MSG_FUNC( PQItemList )
{
    QU_ON( user, msg.role_id );

    item::ReplyItemList(user, msg.bag_index);
}

//这个协议废弃
MSG_FUNC( PQItemAdd )
{
    QU_ON( user, msg.role_id );
    //item::AddItem( user, msg.id, msg.count, kPathItemAdd );
}

MSG_FUNC( PQItemSort )
{
    QU_ON( user, msg.role_id );
    item::SortItem( user, msg.bag_index );
}

MSG_FUNC( PQItemSell )
{
    QU_ON( user, msg.role_id );
    item::SellItem( user, msg.bag_type, msg.item_list );
}

MSG_FUNC( PQItemRedeem )
{
    QU_ON( user, msg.role_id );
    item::Redeem( user, msg.guid );
}

MSG_FUNC( PQItemMerge )
{
    QU_ON( user, msg.role_id );
    CItemMergeData::SData *pitemmerge = theItemMergeExt.Find( msg.id );
    if (NULL == pitemmerge)
        return;
    if (pitemmerge->type == kItemMergeTypeEquip)
        return;
    item::Merge( user, msg.id, msg.count );
}

MSG_FUNC( PQItemEquip )
{
    QU_ON( user, msg.role_id );
    equip::Equip( user, msg.src );
}

MSG_FUNC( PQItemEquipSkill )
{
    QU_ON( user, msg.role_id );
    equip::EquipSkill( user, msg.src, msg.soldier_guid );
}

MSG_FUNC( PQItemUse )
{
    QU_ON( user, msg.role_id );
    item::UseItem( user, msg.item, msg.count, msg.index );
}
/*****************物品协议回复*****************/

