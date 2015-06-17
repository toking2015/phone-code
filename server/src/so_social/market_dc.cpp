#include "market_dc.h"
#include "resource/r_marketext.h"
#include "market_imp.h"
#include "server.h"
#include "misc.h"

CMarketDC::CMarketDC() : TDC< CMarket >( "market" )
{
}

uint32 CMarketDC::alloc_id(void)
{
    if ( db().global_id == 0xFFFFFFFF )
        db().global_id = 0;

    return ++db().global_id;
}

void CMarketDC::init_data( std::vector< SMarketSellCargo >& list )
{
    uint32 time_now = server::local_time();
    for ( std::vector< SMarketSellCargo >::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
        SMarketSellCargo& cargo = *iter;

        CMarketData::SData* market = theMarketExt.Find( cargo.coin.objid );
        if ( market == NULL )
            continue;

        db().global_id = std::max( db().global_id, cargo.cargo_id );

        //设置购买索引
        std::vector< uint32 >& list = market::switch_cargo_map( cargo.sid, market );
        list.push_back( cargo.cargo_id );

        //设置用户索引
        db().user_map[ cargo.role_id ].push_back( cargo.cargo_id );

        //设置数据
        db().data_map[ iter->cargo_id ] = *iter;

        //设置下架索引
        if ( 0 != iter->down_time && iter->down_time < time_now )
            db().down_map[SERVER_ID( iter->role_id )][TIMETOMIN(iter->down_time)].push_back( iter->cargo_id );
    }
}

void CMarketDC::down_data()
{
    for( std::map<uint32, SMarketSellCargo>::iterator iter = db().data_map.begin();
        iter != db().data_map.end();
        ++iter )
    {
    }
}

