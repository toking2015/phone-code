#include "proto/transfrom/transfrom_shop.h"

#include "proto/shop/SUserShopLog.h"
#include "proto/shop/SUserMysteryGoods.h"
#include "proto/shop/PQShopBuy.h"
#include "proto/shop/PRShopBuy.h"
#include "proto/shop/PQShopRefresh.h"
#include "proto/shop/PQShopLog.h"
#include "proto/shop/PRShopLog.h"
#include "proto/shop/PRShopLogSet.h"
#include "proto/shop/PRShopMysteryGoods.h"
#include "proto/shop/PQShopTombRefresh.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_shop::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 355460715 ] = std::make_pair( "PQShopBuy", msg_transfrom< PQShopBuy > );
    handles[ 1696054534 ] = std::make_pair( "PRShopBuy", msg_transfrom< PRShopBuy > );
    handles[ 891445671 ] = std::make_pair( "PQShopRefresh", msg_transfrom< PQShopRefresh > );
    handles[ 842024592 ] = std::make_pair( "PQShopLog", msg_transfrom< PQShopLog > );
    handles[ 1391203940 ] = std::make_pair( "PRShopLog", msg_transfrom< PRShopLog > );
    handles[ 1510374863 ] = std::make_pair( "PRShopLogSet", msg_transfrom< PRShopLogSet > );
    handles[ 2075346742 ] = std::make_pair( "PRShopMysteryGoods", msg_transfrom< PRShopMysteryGoods > );
    handles[ 756738156 ] = std::make_pair( "PQShopTombRefresh", msg_transfrom< PQShopTombRefresh > );

    return handles;
}

