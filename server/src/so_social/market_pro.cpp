#include "pro.h"
#include "proto/constant.h"
#include "proto/market.h"
#include "local.h"
#include "market_imp.h"
#include "market_dc.h"
#include "link.h"

MSG_FUNC( PRMarketList )
{
    if ( msg.list.empty() )
    {
        link_outside_start();
        return;
    }

    theMarketDC.init_data( msg.list );
}

MSG_FUNC( PQMarketBuyList )
{
    market::get_buy_list( msg.sid, msg.role_id, msg.level );
}

MSG_FUNC( PQMarketCustomBuyList )
{
    market::get_custom_list( msg.sid, msg.role_id, msg.equip, msg.level );
}

MSG_FUNC( PQMarketSellList )
{
    market::get_sell_list( msg.sid, msg.role_id );
}

MSG_FUNC( PQMarketCargoUp )
{
    market::cargo_up( msg.sid, msg.role_id, msg.coin, msg.percent );
}

MSG_FUNC( PQMarketCargoDown )
{
    market::cargo_down( msg.role_id, msg.cargo_id );
}

MSG_FUNC( PQMarketCargoChange )
{
    market::cargo_change( msg.role_id, msg.cargo_id, msg.percent );
}

MSG_FUNC( PQMarketBuy )
{
    market::cargo_buy( msg.role_id, msg.guid, msg.count, msg.value, msg.percent );
}

MSG_FUNC( PQMarketBatchMatch )
{
    market::batch_match( msg.sid, msg.role_id, msg.coins );
}

MSG_FUNC( PQMarketBatchBuy )
{
    market::batch_buy( msg.sid, msg.role_id, msg.cargos, msg.value, msg.path );
}

MSG_FUNC( PQMarketBuyAll )
{
    market::cargo_buy_all( msg.role_id, msg.coins, msg.value, msg.percent );
}

MSG_FUNC( PQMarketSocialReset )
{
    market::cargo_reset( msg.sid );
}

MSG_FUNC( PQMarketDownTimeout )
{
    market::down_time_out( msg.sid );
}

MSG_FUNC( PQMarketSellTimeout )
{
    market::sell_time_out( msg.sid );
}

MSG_FUNC( PQMarketSell )
{
    market::sell_money( msg.role_id, msg.cargo_id );
}

