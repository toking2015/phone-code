#include "raw.h"

#include "proto/market.h"

RAW_USER_LOAD( market_log )
{
    QuerySql( "select name, cate, objid, val, time, price from market_log where role_id = %u", guid );

    SMarketLog log;
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        log.name       = sql->getString(i++);
        log.coin.cate  = sql->getInteger(i++);
        log.coin.objid = sql->getInteger(i++);
        log.coin.val   = sql->getInteger(i++);
        log.time       = sql->getInteger(i++);
        log.price      = sql->getInteger(i++);

        data.market_log.push_back( log );
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( market_log )
{
    stream << strprintf( "delete from market_log where role_id = %u;", guid ) << std::endl;

    if ( !data.market_log.empty() )
    {
        stream << "insert into market_log values";
        for ( std::vector< SMarketLog >::iterator iter = data.market_log.begin();
            iter != data.market_log.end();
            ++iter )
        {
            if ( iter != data.market_log.begin() )
                stream << ", ";

            SMarketLog& log = (*iter);

            stream << strprintf( "( %u, '%s', %u, %u, %u, %u, %u )",
                guid, escape( log.name ).c_str(), log.coin.cate, log.coin.objid, log.coin.val, log.time, log.price );
        }
        stream << ";" << std::endl;
    }
}

