#include "raw.h"

#include "proto/team.h"

//simple
RAW_USER_LOAD( team )
{
    QuerySql( "select can_change_name, change_name_count from team where guid = %u limit 1;",
        guid );

    if ( sql->empty() )
        return DB_SUCCEED;

    int32 i = 0;
    data.team.can_change_name       = sql->getInteger( i++ );
    data.team.change_name_count     = sql->getInteger( i++ );

    return DB_SUCCEED;

}
RAW_USER_SAVE( team )
{
    stream << strprintf( "delete from team where guid = %u limit 1;", guid ) << std::endl;
    stream << strprintf
    (
        "insert into team( guid, can_change_name, change_name_count ) "
        "values( %u, %u, %u );",
        guid, data.team.can_change_name, data.team.change_name_count
    ) << std::endl;
}

