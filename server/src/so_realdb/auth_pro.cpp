#include "pro.h"
#include "proto/constant.h"
#include "proto/auth.h"

MSG_FUNC( PQAuthRunTimeSet )
{
    wd::CSql* sql = sql::get( "master" );
    if ( sql == NULL )
        return;

    PRAuthRunTimeSet rep;
    bccopy( rep , msg );

    rep.outside_sock = msg.outside_sock;
    rep.set_type = msg.set_type;
    rep.run_time = msg.run_time;

    switch ( msg.set_type )
    {
    case kObjectAdd:
        {
            ExecuteSql( "insert into run_time values( 0, '%s', '%s' )",
                escape( msg.cmd ).c_str(), escape( msg.run_time.data ).c_str() );

            rep.run_time.guid = sql->insertId();
        }
        break;
    case kObjectDel:
        {
            ExecuteSql( "delete from run_time where id = %u limit 1", msg.run_time.guid );
        }
        break;
    }

    local::write( local::auth, rep );
}

MSG_FUNC( PQAuthRunTimeList )
{
    wd::CSql* sql = sql::get( "master" );
    if ( sql == NULL )
        return;

    QuerySql( "select id, data from run_time" );

    PRAuthRunTimeList rep;

    for ( sql->first(); !sql->empty(); sql->next() )
    {
        SAuthRunTime run_time;

        run_time.guid = sql->getInteger(0);
        run_time.data = sql->getString(1);

        rep.list.push_back( run_time );
    }

    local::write( local::auth, rep );
}

