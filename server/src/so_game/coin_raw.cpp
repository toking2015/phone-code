#include "raw.h"

#include "proto/user.h"

//simple
RAW_USER_LOAD( coin )
{
    QuerySql( "select gold, money, ticket, water, star, active_score, medal, tomb, guild_contribute, day_task_val from usercoin where guid = %u limit 1;",
        guid );

    if ( sql->empty() )
        return DB_SUCCEED;

    int32 i = 0;
    data.coin.gold          = sql->getInteger( i++ );
    data.coin.money         = sql->getInteger( i++ );
    data.coin.ticket        = sql->getInteger( i++ );
    data.coin.water         = sql->getInteger( i++ );
    data.coin.star          = sql->getInteger( i++ );
    data.coin.active_score  = sql->getInteger( i++ );
    data.coin.medal         = sql->getInteger( i++ );
    data.coin.tomb          = sql->getInteger( i++ );
    data.coin.guild_contribute = sql->getInteger( i++ );
    data.coin.day_task_val  = sql->getInteger( i++ );

    return DB_SUCCEED;

}
RAW_USER_SAVE( coin )
{
    stream << strprintf( "delete from usercoin where guid = %u limit 1;", guid ) << std::endl;
    stream << strprintf
    (
        "insert into usercoin( guid, gold, money, ticket, water, star, active_score, medal, tomb, guild_contribute, day_task_val ) "
        "values( %u, %u, %u, %u, %u, %u, %u, %u, %u, %u, %u );",
        guid, data.coin.gold, data.coin.money, data.coin.ticket, data.coin.water, data.coin.star, data.coin.active_score, data.coin.medal, data.coin.tomb,
        data.coin.guild_contribute, data.coin.day_task_val
    ) << std::endl;
}

