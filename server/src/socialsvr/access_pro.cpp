#include "misc.h"
#include "proto/access.h"
#include "pack.h"
#include "local.h"
#include "netio.h"

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
            LOG_INFO( "outside sock[%d] close!", msg.sock );
        }
        break;
    }
}

