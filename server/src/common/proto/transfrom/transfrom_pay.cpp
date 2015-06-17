#include "proto/transfrom/transfrom_pay.h"

#include "proto/pay/SUserPayInfo.h"
#include "proto/pay/SUserPay.h"
#include "proto/pay/PQPayList.h"
#include "proto/pay/PRPayList.h"
#include "proto/pay/PQPayInfo.h"
#include "proto/pay/PRPayInfo.h"
#include "proto/pay/PQPayMonthReward.h"
#include "proto/pay/PRPayMonthReward.h"
#include "proto/pay/PQPayFristPayReward.h"
#include "proto/pay/PQReplyFristPayReward.h"
#include "proto/pay/PRReplyFristPayReward.h"
#include "proto/pay/PRPayNotice.h"
#include "proto/pay/PQPayNotice.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_pay::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 393345959 ] = std::make_pair( "PQPayList", msg_transfrom< PQPayList > );
    handles[ 1166471284 ] = std::make_pair( "PRPayList", msg_transfrom< PRPayList > );
    handles[ 676129012 ] = std::make_pair( "PQPayInfo", msg_transfrom< PQPayInfo > );
    handles[ 2011903693 ] = std::make_pair( "PRPayInfo", msg_transfrom< PRPayInfo > );
    handles[ 923533371 ] = std::make_pair( "PQPayMonthReward", msg_transfrom< PQPayMonthReward > );
    handles[ 2052680871 ] = std::make_pair( "PRPayMonthReward", msg_transfrom< PRPayMonthReward > );
    handles[ 43330202 ] = std::make_pair( "PQPayFristPayReward", msg_transfrom< PQPayFristPayReward > );
    handles[ 898214691 ] = std::make_pair( "PQReplyFristPayReward", msg_transfrom< PQReplyFristPayReward > );
    handles[ 1488769700 ] = std::make_pair( "PRReplyFristPayReward", msg_transfrom< PRReplyFristPayReward > );
    handles[ 1722629611 ] = std::make_pair( "PRPayNotice", msg_transfrom< PRPayNotice > );
    handles[ 721071533 ] = std::make_pair( "PQPayNotice", msg_transfrom< PQPayNotice > );

    return handles;
}

