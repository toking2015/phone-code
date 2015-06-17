#include "linkdef.h"
#include "link_event.h"

//access
NET_SINGLE_READ( access )
{
    thePack.PushData( local::access, sock, buff, size );
}
NET_SINGLE_CONNECT( access )
{
    //回调网关连接事件
    event::dispatch( SEventNetAccess() );
}

//realdb
NET_SINGLE_READ( realdb )
{
    thePack.PushData( local::realdb, sock, buff, size );
}
NET_SINGLE_CONNECT( realdb )
{
    //回调realdb连接事件
    event::dispatch( SEventNetRealDB() );
}

//fight
NET_SINGLE_READ( fight )
{
    thePack.PushData( local::fight, sock, buff, size );
}
NET_SINGLE_CONNECT( fight )
{
    //回调fightsvr连接事件
    event::dispatch( SEventNetFight() );
}

//auth
NET_SINGLE_READ( auth )
{
    thePack.PushData( local::auth, sock, buff, size );
}
NET_SINGLE_CONNECT( auth )
{
    //回调authsvr连接事件
    event::dispatch( SEventNetAuth() );
}
