#include "cool.h"
#include "server.h"
#include "netio.h"
#include "pack.h"

namespace cool
{

std::map< int32, uint32 >& sock_map(void)
{
    static std::map< int32, uint32 > map;

    return map;
}

void append( int32 sock )
{
    theNet.Read( sock, NULL, NULL );
    thePack.Clear( sock );

    sock_map()[ sock ] = (uint32)time(NULL);
}

bool is_cool( int32 sock )
{
    return ( sock_map().find( sock ) != sock_map().end() );
}

void release_timeout( int32 seconds )
{
    uint32 time_now = (uint32)time(NULL);

    for ( std::map< int32, uint32 >::iterator iter = sock_map().begin();
        iter != sock_map().end(); )
    {
        if ( time_now > iter->second + seconds )
        {
            close( iter->first );

            sock_map().erase( iter++ );
            continue;
        }

        ++iter;
    }
}

} // namespace cool

