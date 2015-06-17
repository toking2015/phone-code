#include "timer.h"
#include "proto/market.h"
#include "remote.h"
#include "server_dc.h"

TIMER( market_social_start )
{
    PQMarketSocialReset msg;

    msg.sid = *( theServerDC.db().server_ids.begin() );

    remote::write( local::social, msg );
}

SO_LOAD( market_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "market_down_check",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Minute,
        1,
        0
    );
}

TIMER( market_down_check )
{
    // down_check 的时候, 可能 server_ids 未准备好
    if ( theServerDC.db().server_ids.empty() )
        return;

    PQMarketDownTimeout msg;

    msg.sid = *( theServerDC.db().server_ids.begin() );

    remote::write( local::social, msg );
}
