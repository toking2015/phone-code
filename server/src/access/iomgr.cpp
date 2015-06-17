#include "iomgr.h"
#include "netio.h"
#include "pack.h"
#include "log.h"
#include "local.h"
#include "msg.h"

CIO::CIO()
{
    sock = -1;
    state = CIO::eInit;

    last_recv_time = (uint32)time(NULL);
}

//========================CIOMgr=================
void CIOMgr::AddSock( int32 sock )
{
    wd::CGuard< wd::CMutex > safe( &mutex );

    CIO& io = io_map[ sock ];
    io.sock = sock;

    theNet.Read( sock, OnRead, NULL );
}

void CIOMgr::DelSock( int32 sock )
{
    theNet.Read( sock, NULL, NULL );
    thePack.Clear( sock );

    wd::CGuard< wd::CMutex > safe( &mutex );

    std::map< int32, CIO >::iterator iter = io_map.find( sock );
    if ( iter != io_map.end() )
        io_map.erase( iter );
}

int32 CIOMgr::CheckSock( int32 sock )
{
    wd::CGuard< wd::CMutex > safe( &mutex );

    std::map< int32, CIO >::iterator iter = io_map.find( sock );
    if ( iter == io_map.end() )
        return CIO::eNoExist;

    return iter->second.state;
}

std::list< int32 > CIOMgr::GetRecvTimeoutList(void)
{
    uint32 time_now = (uint32)time(NULL);
    std::list< int32 > timeout_list;

    wd::CGuard< wd::CMutex > safe( &mutex );

    for ( std::map< int32, CIO >::iterator iter = io_map.begin();
        iter != io_map.end();
        ++iter )
    {
        if ( time_now > iter->second.last_recv_time + 600 )
            timeout_list.push_back( iter->first );
    }

    return timeout_list;
}

void CIOMgr::ResetRecvTime( int32 sock )
{
    wd::CGuard< wd::CMutex > safe( &mutex );

    std::map< int32, CIO >::iterator iter = io_map.find( sock );
    if ( iter != io_map.end() )
        iter->second.last_recv_time = (uint32)time(NULL);
}

//static
void CIOMgr::OnRead( void* param, int32 sock, char* buff, int32 size )
{
    if ( size <= 0 )
    {
        theNet.Read( sock, NULL, NULL );
        /*
           这里不立即清理, 交由 kErrAccessSockClose 的业务逻辑处理
        thePack.Clear( sock );
        */

        //派发错误包
        tag_msg_access_event msg;
        msg.sock = sock;
        msg.code = 1989318792; //kErrAccessSockClose;

        uint32 head_length = sizeof( tag_msg_head );
        uint32 length = sizeof( msg );
        wd::CStream stream( 4 + length );

        stream << head_length;
        stream.write( &msg, length );

        theMsg.Send( 0, local::self, &stream[0], stream.length() );
        return;
    }

    thePack.PushData( local::outside, sock, buff, size );
}

