#include "proto/transfrom/transfrom_market.h"

#include "proto/market/SMarketSellCargo.h"
#include "proto/market/SMarketMatch.h"
#include "proto/market/SMarketLog.h"
#include "proto/market/SMarketIndices.h"
#include "proto/market/CMarket.h"
#include "proto/market/PQMarketBuyList.h"
#include "proto/market/PQMarketCustomBuyList.h"
#include "proto/market/PRMarketCustomBuyList.h"
#include "proto/market/PRMarketBuyList.h"
#include "proto/market/PRMarketBuyData.h"
#include "proto/market/PQMarketSellList.h"
#include "proto/market/PRMarketSellList.h"
#include "proto/market/PRMarketSellData.h"
#include "proto/market/PQMarketCargoUp.h"
#include "proto/market/PQMarketCargoDown.h"
#include "proto/market/PRMarketCargoDown.h"
#include "proto/market/PQMarketCargoChange.h"
#include "proto/market/PQMarketBuy.h"
#include "proto/market/PRMarketBuy.h"
#include "proto/market/PQMarketBuyAll.h"
#include "proto/market/PRMarketBuyAll.h"
#include "proto/market/PQMarketBatchMatch.h"
#include "proto/market/PRMarketBatchMatch.h"
#include "proto/market/PQMarketBatchBuy.h"
#include "proto/market/PRMarketBatchBuy.h"
#include "proto/market/PQMarketSell.h"
#include "proto/market/PRMarketSell.h"
#include "proto/market/PQMarketSocialReset.h"
#include "proto/market/PQMarketDownTimeout.h"
#include "proto/market/PQMarketSellTimeout.h"
#include "proto/market/PQMarketList.h"
#include "proto/market/PRMarketList.h"
#include "proto/market/PRMarketLogData.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_market::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 680228560 ] = std::make_pair( "PQMarketBuyList", msg_transfrom< PQMarketBuyList > );
    handles[ 11023047 ] = std::make_pair( "PQMarketCustomBuyList", msg_transfrom< PQMarketCustomBuyList > );
    handles[ 1472681061 ] = std::make_pair( "PRMarketCustomBuyList", msg_transfrom< PRMarketCustomBuyList > );
    handles[ 1411658984 ] = std::make_pair( "PRMarketBuyList", msg_transfrom< PRMarketBuyList > );
    handles[ 1819854724 ] = std::make_pair( "PRMarketBuyData", msg_transfrom< PRMarketBuyData > );
    handles[ 1030132927 ] = std::make_pair( "PQMarketSellList", msg_transfrom< PQMarketSellList > );
    handles[ 1659115855 ] = std::make_pair( "PRMarketSellList", msg_transfrom< PRMarketSellList > );
    handles[ 1824851074 ] = std::make_pair( "PRMarketSellData", msg_transfrom< PRMarketSellData > );
    handles[ 761321872 ] = std::make_pair( "PQMarketCargoUp", msg_transfrom< PQMarketCargoUp > );
    handles[ 107099549 ] = std::make_pair( "PQMarketCargoDown", msg_transfrom< PQMarketCargoDown > );
    handles[ 2006886785 ] = std::make_pair( "PRMarketCargoDown", msg_transfrom< PRMarketCargoDown > );
    handles[ 921604485 ] = std::make_pair( "PQMarketCargoChange", msg_transfrom< PQMarketCargoChange > );
    handles[ 350735340 ] = std::make_pair( "PQMarketBuy", msg_transfrom< PQMarketBuy > );
    handles[ 1339903691 ] = std::make_pair( "PRMarketBuy", msg_transfrom< PRMarketBuy > );
    handles[ 344619840 ] = std::make_pair( "PQMarketBuyAll", msg_transfrom< PQMarketBuyAll > );
    handles[ 1279944605 ] = std::make_pair( "PRMarketBuyAll", msg_transfrom< PRMarketBuyAll > );
    handles[ 382628001 ] = std::make_pair( "PQMarketBatchMatch", msg_transfrom< PQMarketBatchMatch > );
    handles[ 1229779097 ] = std::make_pair( "PRMarketBatchMatch", msg_transfrom< PRMarketBatchMatch > );
    handles[ 214967243 ] = std::make_pair( "PQMarketBatchBuy", msg_transfrom< PQMarketBatchBuy > );
    handles[ 1792916194 ] = std::make_pair( "PRMarketBatchBuy", msg_transfrom< PRMarketBatchBuy > );
    handles[ 402301576 ] = std::make_pair( "PQMarketSell", msg_transfrom< PQMarketSell > );
    handles[ 1795127888 ] = std::make_pair( "PRMarketSell", msg_transfrom< PRMarketSell > );
    handles[ 131107855 ] = std::make_pair( "PQMarketSocialReset", msg_transfrom< PQMarketSocialReset > );
    handles[ 338435276 ] = std::make_pair( "PQMarketDownTimeout", msg_transfrom< PQMarketDownTimeout > );
    handles[ 262770350 ] = std::make_pair( "PQMarketSellTimeout", msg_transfrom< PQMarketSellTimeout > );
    handles[ 532964337 ] = std::make_pair( "PQMarketList", msg_transfrom< PQMarketList > );
    handles[ 1593277506 ] = std::make_pair( "PRMarketList", msg_transfrom< PRMarketList > );
    handles[ 2026116139 ] = std::make_pair( "PRMarketLogData", msg_transfrom< PRMarketLogData > );

    return handles;
}

