#include "raw.h"
#include "proto/var.h"
#include "server.h"
#include "log.h"

RAW_USER_LOAD( var_map )
{
    QuerySql( "select var_key, var_value, timelimit from var_info where role_id = %u", guid );

    uint32 time_now = (uint32)server::local_time();

    SUserVar var;
    for ( sql->first(); !sql->empty(); sql->next() )
    {
        var.value       = sql->getInteger(1);
        var.timelimit   = sql->getInteger(2);

        if ( var.timelimit != 0 && time_now > var.timelimit )
            continue;

        data.var_map[ sql->getString(0) ] = var;
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE( var_map )
{
    stream << strprintf( "delete from var_info where role_id = %u;", guid ) << std::endl;

    for ( std::map< std::string, SUserVar >::iterator iter = data.var_map.begin();
        iter != data.var_map.end();
        ++iter )
    {
        stream << strprintf( "insert into var_info( role_id, var_key, var_value, timelimit ) values( %u, '%s', %u, %u );",
            guid, escape( iter->first ).c_str(), iter->second.value, iter->second.timelimit ) << std::endl;
    }
}

