#include "pro.h"
#include "proto/pay.h"
#include "pay_imp.h"
#include "user_dc.h"
#include "local.h"

//from real
MSG_FUNC( PRPayList )
{
    QU_ON( user, msg.role_id );

    if ( key != local::realdb )
        return;

    pay::AddPay( user,  msg.list );

    bccopy( msg, user->ext );

    local::write( local::access, msg );
}

MSG_FUNC( PQPayInfo )
{
    QU_ON( user, msg.role_id );

    pay::ReplyData( user );
}

MSG_FUNC( PQPayMonthReward )
{
    QU_ON( user, msg.role_id );

    pay::MonthReward( user );
}

MSG_FUNC( PQPayFristPayReward )
{
    QU_ON( user, msg.role_id );

    pay::GetFristPayReward( user );
}


MSG_FUNC( PQPayNotice )
{
    if( key != local::auth )
        return;

    QU_OFF( user, msg.target_id );

    PQPayList req;
    req.target_id = msg.target_id;

    local::write( local::realdb, req );
}

