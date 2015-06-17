#include "pro.h"
#include "proto/social.h"
#include "proto/constant.h"

MSG_FUNC( PQSocialServerRoleList )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
        return;

    QuerySql( "select role_id, level, name from roleinfo" );

    SSocialRole role;
    PRSocialServerRoleList rep;

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        int32 i = 0;

        role.role_id    = sql->getInteger(i++);
        role.level      = sql->getInteger(i++);
        role.name       = sql->getString(i++);

        rep.list.push_back( role );

        if ( rep.list.size() > 512 )
        {
            local::write( local::social, rep );

            rep.list.clear();
        }
    }

    if ( !rep.list.empty() )
    {
        local::write( local::social, rep );

        rep.list.clear();
    }

    local::write( local::social, rep );
}

MSG_FUNC( PQSocialServerRole )
{
    wd::CSql* sql = sql::get( "share" );
    if ( sql == NULL )
        return;

    std::string escape_name = escape( msg.role.name );
    ExecuteSql( "insert into roleinfo ( role_id, level, name ) values( %u, %u, '%s' ) "
        "on duplicate key update level = %u, name = '%s'",
        msg.role.role_id,
        msg.role.level, escape_name.c_str(),
        msg.role.level, escape_name.c_str() );
}

