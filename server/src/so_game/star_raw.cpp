#include "raw.h"

#include "proto/star.h"

RAW_USER_LOAD( star )
{
    QuerySql( "select copy, hero, totem from userstar where guid = %u", guid );

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;
        SUserStar user_star;

        user_star.copy      = sql->getInteger( i++ );
        user_star.hero      = sql->getInteger( i++ );
        user_star.totem     = sql->getInteger( i++ );

        data.star = user_star;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( star )
{
    stream << strprintf( "delete from userstar where guid = %u;", guid ) << std::endl;

    stream << strprintf( "insert into userstar( guid, copy, hero, totem ) values( %u, %u, %u, %u );",
        guid, data.star.copy, data.star.hero, data.star.totem ) << std::endl;
}

