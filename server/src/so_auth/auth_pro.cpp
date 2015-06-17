#include "misc.h"
#include "proto/constant.h"
#include "proto/auth.h"
#include "netio.h"
#include "local.h"
#include "log.h"
#include "call_imp.h"

MSG_FUNC( PQAuthRunJson )
{
    if ( key != local::self )
        return;

    std::pair< int32, std::string > result = json::Process( msg.outside_sock, msg.json_string, 0 );

    switch ( result.first )
    {
    case kAuthRunJsonFlagDefer:
    case kAuthRunJsonFlagLoop:
        {
            PQAuthRunTimeSet req;
            req.outside_sock = msg.outside_sock;

            req.cmd = result.second;
            req.set_type = kObjectAdd;
            req.run_time.data = msg.json_string;

            local::write( local::realdb, req );
        }
        break;
    }
}

MSG_FUNC( PRAuthRunTimeSet )
{
    if ( key != local::realdb )
        return;

    theNet.Write( msg.outside_sock, "ok", 2 );

    switch ( msg.set_type )
    {
    case kObjectAdd:
        {
            std::pair< int32, std::string > result =
                json::Process( msg.outside_sock, msg.run_time.data, msg.run_time.guid );

            if ( result.first == (int32)kAuthRunJsonFlagSucceed )
            {
                PQAuthRunTimeSet req;
                bccopy( req, msg );

                req.set_type = kObjectDel;
                req.run_time.guid = msg.run_time.guid;

                local::write( local::realdb, req );
            }
        }
        break;
    }
}

MSG_FUNC( PRAuthRunTimeList )
{
    for ( std::vector< SAuthRunTime >::iterator iter = msg.list.begin();
        iter != msg.list.end();
        ++iter )
    {
        std::pair< int32, std::string > result = json::Process( 0, iter->data, iter->guid );

        if ( result.first == (int32)kAuthRunJsonFlagSucceed )
        {
            PQAuthRunTimeSet req;

            req.set_type = kObjectDel;
            req.run_time.guid = iter->guid;

            local::write( local::realdb, req );
        }
    }
}

