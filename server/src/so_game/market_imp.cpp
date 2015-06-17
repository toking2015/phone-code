#include "market_imp.h"
#include "user_dc.h"
#include "local.h"
#include "server.h"
#include "server_dc.h"
#include "market_dc.h"

namespace market
{

uint32 get_social_sid(void)
{
    if ( server::local_time() > theMarketDC.db().social_time )
        return 0;

    return *( theServerDC.db().server_ids.begin() );
}

void reply_log_data( SUser* user, SMarketLog& data )
{
    PRMarketLogData msg;
    bccopy( msg, user->ext );

    msg.data = data;

    local::write( local::access, msg );
}

} // namespace market

