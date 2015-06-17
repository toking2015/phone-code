#include "linkdef.h"

NET_SINGLE_READ( social )
{
    thePack.PushData( local::social, sock, buff, size );
}

NET_SINGLE_CONNECT( social )
{
}

