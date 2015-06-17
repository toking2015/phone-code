#include "proto/transfrom/transfrom_viptimelimitshop.h"

#include "proto/viptimelimitshop/SUserVipTimeLimitGoods.h"
#include "proto/viptimelimitshop/PQVipTimeLimitShopWeek.h"
#include "proto/viptimelimitshop/PRVipTimeLimitShopWeek.h"
#include "proto/viptimelimitshop/PQVipTimeLimitShopBuy.h"
#include "proto/viptimelimitshop/PRVipTimeLimitShopBuy.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_viptimelimitshop::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 746990542 ] = std::make_pair( "PQVipTimeLimitShopWeek", msg_transfrom< PQVipTimeLimitShopWeek > );
    handles[ 1223021540 ] = std::make_pair( "PRVipTimeLimitShopWeek", msg_transfrom< PRVipTimeLimitShopWeek > );
    handles[ 1936613 ] = std::make_pair( "PQVipTimeLimitShopBuy", msg_transfrom< PQVipTimeLimitShopBuy > );
    handles[ 1101010730 ] = std::make_pair( "PRVipTimeLimitShopBuy", msg_transfrom< PRVipTimeLimitShopBuy > );

    return handles;
}

