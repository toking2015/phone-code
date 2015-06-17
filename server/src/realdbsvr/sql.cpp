#include "sql.h"
#include "util.h"
#include "settings.h"

std::map< std::string, wd::CSql* > sql_map;

wd::CSql* sql::get( int32 id )
{
    return get( strprintf( "%d", id ) );
}

wd::CSql* sql::get( std::string name )
{
    wd::CSql* sql = NULL;

    std::map< std::string, wd::CSql* >::iterator iter = sql_map.find( name );
    if ( iter != sql_map.end() )
    {
        if ( !iter->second->test() )
        {
            delete iter->second;
            sql_map.erase( iter );
            iter = sql_map.end();
        }
    }

    if ( iter == sql_map.end() )
    {
        sql = allocate( name );
        if ( sql == NULL )
            return NULL;

        sql_map.insert( std::make_pair( name, sql ) );
    }
    else
        sql = iter->second;

    return sql;
}

wd::CSql* sql::allocate( std::string name )
{
    const Json::Value aj = settings::json()[ "sql" ];

    std::string host, db, user, pwd;
    uint32 port = 0;

    for ( uint32 i = 0; i < aj.size(); ++i )
    {
        if ( aj[i]["name"].asString() != name )
            continue;

        host    = aj[i]["host"].asString();
        db      = aj[i]["db"].asString();
        user    = aj[i]["user"].asString();
        pwd     = aj[i]["pwd"].asString();

        port    = aj[i]["port"].asUInt();
    }

    if ( port == 0 )
        return NULL;

    wd::CSql* sql = new wd::CSql;

    if ( !sql->connect( host.c_str(), (uint16)port, db.c_str(), user.c_str(), pwd.c_str() ) )
    {
        delete sql;
        return NULL;
    }

    return sql;
}


