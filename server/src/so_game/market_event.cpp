#include "server_event.h"
#include "link_event.h"
#include "proto/market.h"
#include "market_dc.h"
#include "server_dc.h"
#include "server.h"
#include "timer.h"
#include "remote.h"

EVENT_FUNC( market, SEventServerInfo )
{
    uint32 open_time = server::get<uint32>( "open_time" );
    theMarketDC.db().social_time = server::local_6_time( open_time, 7 );

    uint32 now_time = server::local_time();
    if ( theMarketDC.db().social_time > now_time )
    {
        //只执行一次
        theSysTimeMgr.AddCall( "market_social_start", "", theMarketDC.db().social_time - now_time );
    }
}

EVENT_FUNC( market, SEventLinkSocial )
{
    PQMarketSellTimeout msg;

    //如果
    if ( theServerDC.db().server_ids.empty() )
    {
        local::post( local::self, msg );
        return;
    }

    msg.sid = *( theServerDC.db().server_ids.begin() );

    remote::write( local::social, msg );

}
