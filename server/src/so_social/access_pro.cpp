#include "misc.h"
#include "proto/access.h"
#include "pack.h"
#include "local.h"
#include "netio.h"
#include "social_dc.h"

MSG_FUNC( PQAccessEvent )
{
    if ( key != local::self )
        return;

    switch( msg.code )
    {
    case kErrAccessSockOpen:
        {
        }
        break;
    case kErrAccessSockClose:
        {
            std::map< uint32, uint32 >::iterator iter = theSocialDC.db().socket_server.find( msg.sock );
            if ( iter != theSocialDC.db().socket_server.end() )
            {
                theSocialDC.db().server_socket.erase( iter->second );
                theSocialDC.db().socket_server.erase( iter->first );
            }
        }
        break;
    }
}

