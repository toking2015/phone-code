#include "pro.h"
#include "proto/pay.h"

MSG_FUNC( PQPayList )
{
    wd::CSql* sql = sql::get( SERVER_ID( msg.target_id ) );
    if ( sql == NULL )
        return;

    QuerySql( "select uid, price, time, type from pay where rid = %u and flag = 0 order by `time` asc", msg.target_id);

    PRPayList rep;
    rep.role_id = msg.target_id;

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        SUserPay pay;

        pay.uid    = sql->getInteger(i++);
        pay.price  = sql->getInteger(i++);
        pay.time   = sql->getInteger(i++);
        pay.type   = sql->getInteger(i++);
        pay.flag   = 0;

        rep.list.push_back( pay );
    }

    if ( !rep.list.empty() )
        local::write( key, rep );
}


