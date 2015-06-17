#include "pro.h"
#include "proto/market.h"
#include "proto/constant.h"

MSG_FUNC( PQMarketList )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
        return;

    QuerySql( "select cargo_id, sid, role_id, cate, objid, val, percent, start_time, down_time, buy_name, buy_count, money from market_sell" );

    PRMarketList rep;
    {
        SMarketSellCargo cargo;
        for ( sql->first(); !sql->empty(); sql->next() )
        {
            int32 i = 0;

            cargo.cargo_id      = sql->getInteger(i++);
            cargo.sid           = sql->getInteger(i++);
            cargo.role_id       = sql->getInteger(i++);
            cargo.coin.cate     = sql->getInteger(i++);
            cargo.coin.objid    = sql->getInteger(i++);
            cargo.coin.val      = sql->getInteger(i++);
            cargo.percent       = sql->getInteger(i++);
            cargo.start_time    = sql->getInteger(i++);
            cargo.down_time     = sql->getInteger(i++);
            cargo.buy_name      = sql->getString(i++);
            cargo.buy_count     = sql->getInteger(i++);
            cargo.money         = sql->getInteger(i++);

            rep.list.push_back( cargo );

            if ( rep.list.size() > 512 )
            {
                local::write( local::social, rep );

                rep.list.clear();
            }
        }
    }

    if ( !rep.list.empty() )
    {
        local::write( local::social, rep );

        rep.list.clear();
    }

    local::write( local::social, rep );
}

MSG_FUNC( PRMarketSellData )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
        return;

    switch ( msg.set_type )
    {
    case kObjectAdd:
        {
            ExecuteSql( "insert into market_sell values( %u, %u, %u, %u, %u, %u, %hhu, %u, %u, '%s', %u, %u )",
                msg.data.cargo_id, msg.data.sid, msg.data.role_id,
                msg.data.coin.cate, msg.data.coin.objid, msg.data.coin.val,
                msg.data.percent, msg.data.start_time, msg.data.down_time,
                sql->escape(msg.data.buy_name).c_str(), msg.data.buy_count, msg.data.money );
        }
        break;
    case kObjectDel:
        {
            ExecuteSql( "delete from market_sell where cargo_id = %u", msg.data.cargo_id );
        }
        break;
    case kObjectUpdate:
        {
            ExecuteSql( "update market_sell set val = %u, percent = %hhu where cargo_id = %u",
                msg.data.coin.val, msg.data.percent,
                msg.data.cargo_id );
        }
        break;
    }
}

MSG_FUNC( PQMarketSocialReset )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
        return;

    ExecuteSql( "update market_sell set sid = 0 where sid = %u", msg.sid );
}

