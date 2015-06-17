#include "misc.h"
#include "proto/access.h"
#include "pack.h"
#include "cache.h"
#include "user.h"
#include "local.h"
#include "netio.h"
#include "cool.h"

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

            uint32 role_id = user::reset_sock( msg.sock );

            cool::append( msg.sock );

            if ( role_id != 0 )
                cache::offline( role_id );
        }
        break;
    }
}

