#include "raw.h"

#include "proto/user.h"

//
RAW_USER_LOAD( other )
{
    QuerySql( "select single_arena_rank, single_arena_win_times, paper_skill, mystery_refresh_time, purview, chat_ban_endtime, last_action, market_day_get, market_day_cost, market_day_time from userother where guid = %u limit 1;",
        guid );

    if ( sql->empty() )
        return DB_SUCCEED;

    int32 i = 0;

    data.other.single_arena_rank        = sql->getInteger( i++ );
    data.other.single_arena_win_times   = sql->getInteger( i++ );
    data.other.paper_skill              = sql->getInteger( i++ );
    data.other.mystery_refresh_time     = sql->getInteger( i++ );
    data.other.purview                  = sql->getInteger( i++ );
    data.other.chat_ban_endtime         = sql->getInteger( i++ );
    data.other.last_action              = sql->getString( i++ );
    data.other.market_day_get           = sql->getInteger( i++ );
    data.other.market_day_cost          = sql->getInteger( i++ );
    data.other.market_day_time          = sql->getInteger( i++ );

    return DB_SUCCEED;

}
RAW_USER_SAVE( other )
{
    stream << strprintf( "delete from userother where guid = %u limit 1;", guid ) << std::endl;
    stream << strprintf
    (
        "insert into userother( guid, single_arena_rank, single_arena_win_times, paper_skill, mystery_refresh_time, purview, chat_ban_endtime, last_action, market_day_get, market_day_cost, market_day_time ) "
        "values( %u, %u, %u, %u, %u, %u, %u, '%s', %u, %u, %u );",
        guid,
        data.other.single_arena_rank,
        data.other.single_arena_win_times,
        data.other.paper_skill,
        data.other.mystery_refresh_time,
        data.other.purview,
        data.other.chat_ban_endtime,
        escape( data.other.last_action ).c_str(),
        data.other.market_day_get,
        data.other.market_day_cost,
        data.other.market_day_time
    ) << std::endl;
}

