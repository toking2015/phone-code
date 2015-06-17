#include "remote.h"
#include "netio.h"
#include "pack.h"

namespace remote
{

std::map< int32, int32 >& remote_sock(void)
{
    return theRemoteMgr.remote_map;
}

bool valid( int32 remote_id )
{
    std::map< int32, int32 >::iterator iter = remote_sock().find( remote_id );

    return ( iter != remote_sock().end() || iter->second > 0 );
}

void clear( int32 remote_id )
{
    std::map< int32, int32 >::iterator iter = remote_sock().find( remote_id );

    if ( iter == remote_sock().end() )
        return;

    if ( iter->second > 0 )
    {
        theNet.Clear( iter->second );
        thePack.Clear( iter->second );
        close( iter->second );
    }

    remote_sock().erase( iter );
}

//外部接入拍卖行服务器用的
void link_outside_read( void* param, int32 sock, char* buff, int32 size )
{
    if ( 0 == sock )
        return;
    if ( size <= 0 )
    {
        theNet.Clear( sock );
        thePack.Clear( sock );

        close( sock );

        //派发错误包
        tag_msg_access_event msg;
        msg.sock = sock;
        msg.code = 1989318792; //kErrAccessSockClose;

        uint32 head_length = sizeof( tag_msg_head );
        uint32 length = sizeof( msg );
        wd::CStream stream( 4 + length );

        stream << head_length;
        stream.write( &msg, length );

        theMsg.Post( 0, local::self, &stream[0], stream.length() );
        return;
    }

    thePack.PushData( local::outside, sock, buff, size );
}

void OnRemoteRead( void* p, int32 sock, char* buff, int32 size )
{
    int32 remote_id = (int32)(int64)p;
    if ( size <= 0 )
    {
        clear( remote_id );
        return;
    }

    thePack.PushData( local::social, remote_id, buff, size );
}
void deposit( int32 remote_id, int32 sock )
{
    clear( remote_id );

    if ( sock <= 0 )
        return;

    remote_sock()[ remote_id ] = sock;

    theNet.Read( sock, OnRemoteRead, (void*)(int64)remote_id );
}

void write( int32 remote_id, SMsgHead& msg )
{
    int32 sock = remote_sock()[ remote_id ];
    if ( sock <= 0 )
        return;

    write_to_socket( sock, msg );
}

void write_to_socket( int32 sock, SMsgHead& msg )
{
    wd::CStream stream;
    stream.resize( sizeof( tag_pack_head ) );
    stream << msg;

    CPack::fill_pack_head
    (
        (tag_pack_head*)&stream[0],
        &stream[ sizeof( tag_pack_head ) ],
        stream.length() - sizeof( tag_pack_head )
    );

    theNet.Write( sock, &stream[0], stream.length() );
}

} // namespace remote

