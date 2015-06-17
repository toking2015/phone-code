#include "linkdef.h"

NET_SINGLE_READ( game )
{
    thePack.PushData( local::game, sock, buff, size );
}

NET_SINGLE_CONNECT( game )
{
}

