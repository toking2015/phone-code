#include "iomgr.h"
#include "netio.h"
#include "pack.h"
#include "log.h"
#include "local.h"
#include "msg.h"
#include "sockcoolmgr.h"

//========================CIOMgr=================
void CIOMgr::AddSock( int32 sock )
{
    theNet.Read( sock, OnRead, NULL );
}

void CIOMgr::DelSock( int32 sock )
{
    theNet.Read( sock, NULL, NULL );
    thePack.Clear( sock );
}

//static
void CIOMgr::OnRead( void* param, int32 sock, char* buff, int32 size )
{
    if ( buff == NULL || size <= 0 )
    {
        theIOMgr.DelSock( sock );
        theSockCoolMgr.release( sock );
        return;
    }

    if ( size < 2 || buff[0] != '#' || buff[1] != '#' )
        return;

    uint32 length = sizeof( tag_msg_auth_run_json ) + size;
    char* data = (char*)malloc( length );
    {
        tag_msg_auth_run_json& msg = *( tag_msg_auth_run_json* )data;
        new (&msg)tag_msg_auth_run_json();

        uint32 head_length = sizeof( tag_msg_head );
        uint16* string_length = (uint16*)( data + sizeof( tag_msg_auth_run_json ) );
        char* string = data + sizeof( tag_msg_auth_run_json ) + 2;

        //设置信息
        msg.tag_msg_auth_run_json_size += size;
        msg.outside_sock = sock;
        *string_length = size - 2;
        memcpy( string, buff + 2, *string_length );

        wd::CStream stream( 4 + length );
        stream << head_length;
        stream.write( data, length );

        theMsg.Send( 0, local::self, &stream[0], stream.length() );
    }
    free( data );
}

