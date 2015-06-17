#include "pro.h"
#include "util.h"
#include "proto/system.h"
#include "netio.h"
#include "auth_dc.h"

MSG_FUNC( PRSystemAuth )
{
    std::string content = strprintf( "{ \"rid\" : \"%u\", \"session\" : %u }", msg.role_id, msg.session );

    theNet.Write( msg.outside_sock, &content[0], content.size() );
}

MSG_FUNC( PQSystemOnline )
{
    theAuthDC.online( msg.role_id );
}
