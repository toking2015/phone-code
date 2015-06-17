#include "social_imp.h"
#include "social_dc.h"
#include "remote.h"

namespace social
{

void bind( int32 sock, uint32 sid )
{
    theSocialDC.db().server_socket[ sid ] = sock;
    theSocialDC.db().socket_server[ sock ] = sid;
}

void write( uint32 sid, SMsgHead& msg )
{
    std::map< uint32, uint32 >::iterator iter = theSocialDC.db().server_socket.find( sid );
    if ( iter == theSocialDC.db().server_socket.end() )
        return;

    remote::write_to_socket( iter->second, msg );
}

void role( SSocialRole& role )
{
    theSocialDC.db().user_map[ role.role_id ] = role;
}

} // namespace social

