#include "proto/transfrom/transfrom_item.h"

#include "proto/item/SWildItem.h"
#include "proto/item/SUserItem.h"
#include "proto/item/CUserItem.h"
#include "proto/item/PQItemList.h"
#include "proto/item/PRItemList.h"
#include "proto/item/PRItemSet.h"
#include "proto/item/PQItemAdd.h"
#include "proto/item/PQItemSort.h"
#include "proto/item/PQItemSell.h"
#include "proto/item/PQItemRedeem.h"
#include "proto/item/PQItemMerge.h"
#include "proto/item/PRItemMerge.h"
#include "proto/item/PQItemEquip.h"
#include "proto/item/PQItemEquipSkill.h"
#include "proto/item/PRItemEquipSkill.h"
#include "proto/item/PQItemUse.h"
#include "proto/item/PRItemUse.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_item::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 857480699 ] = std::make_pair( "PQItemList", msg_transfrom< PQItemList > );
    handles[ 1822834778 ] = std::make_pair( "PRItemList", msg_transfrom< PRItemList > );
    handles[ 1778612727 ] = std::make_pair( "PRItemSet", msg_transfrom< PRItemSet > );
    handles[ 731904243 ] = std::make_pair( "PQItemAdd", msg_transfrom< PQItemAdd > );
    handles[ 394473875 ] = std::make_pair( "PQItemSort", msg_transfrom< PQItemSort > );
    handles[ 222047555 ] = std::make_pair( "PQItemSell", msg_transfrom< PQItemSell > );
    handles[ 88915416 ] = std::make_pair( "PQItemRedeem", msg_transfrom< PQItemRedeem > );
    handles[ 319800917 ] = std::make_pair( "PQItemMerge", msg_transfrom< PQItemMerge > );
    handles[ 1847045381 ] = std::make_pair( "PRItemMerge", msg_transfrom< PRItemMerge > );
    handles[ 708926413 ] = std::make_pair( "PQItemEquip", msg_transfrom< PQItemEquip > );
    handles[ 103471093 ] = std::make_pair( "PQItemEquipSkill", msg_transfrom< PQItemEquipSkill > );
    handles[ 1691421581 ] = std::make_pair( "PRItemEquipSkill", msg_transfrom< PRItemEquipSkill > );
    handles[ 1004860592 ] = std::make_pair( "PQItemUse", msg_transfrom< PQItemUse > );
    handles[ 1222770932 ] = std::make_pair( "PRItemUse", msg_transfrom< PRItemUse > );

    return handles;
}

