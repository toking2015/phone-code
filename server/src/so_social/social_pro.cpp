#include "pro.h"
#include "remote.h"
#include "proto/social.h"
#include "social_imp.h"
#include "social_dc.h"
#include "local.h"

MSG_FUNC( PQSocialServerPing )
{
    PRSocialServerPing rep;

    remote::write_to_socket( sock, rep );
}

MSG_FUNC( PQSocialServerBind )
{
    social::bind( sock, msg.sid );

    LOG_INFO( "bind: sock[%d] - sid[%u]", sock, msg.sid );
}

MSG_FUNC( PQSocialServerRole )
{
    social::role( msg.role );

    local::write( local::sharedb, msg );
}

MSG_FUNC( PRSocialServerRoleList )
{
    theSocialDC.init_data( msg.list );
}

