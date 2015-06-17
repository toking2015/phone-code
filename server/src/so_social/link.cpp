#include "linkdef.h"
#include "netio.h"
#include "pack.h"
#include "settings.h"
#include "proto/market.h"
#include "social_dc.h"
#include "log.h"
#include "remote.h"

//sharedb 接入
NET_SINGLE_READ( sharedb )
{
    thePack.PushData( local::sharedb, sock, buff, size );
}

NET_SINGLE_CONNECT( sharedb )
{
    if ( !theSocialDC.db().initialized )
    {
        theSocialDC.db().initialized = true;

        //角色数据加载
        {
            PQSocialServerRoleList msg;

            local::write( local::sharedb, msg );
        }

        //市场数据加载
        {
            PQMarketList msg;

            local::write( local::sharedb, msg );
        }
    }
}

//外部接入
void link_outside_read( void* param, int32 sock, char* buff, int32 size )
{
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
void link_outside_accept( void* param, int32 sock )
{
    LOG_INFO( "accept: %d", sock );

    //派发内部事件包
    tag_msg_access_event msg;
    msg.sock = sock;
    msg.code = 610073348;   //kErrAccessSockOpen;

    uint32 length = sizeof( msg );
    wd::CStream stream( 4 + sizeof( msg ) );

    stream << length;
    stream.write( &msg, sizeof( msg ) );

    theMsg.Post( 0, local::self, &stream[0], stream.length() );

    theNet.Read( msg.sock, remote::link_outside_read, NULL );
}
void link_outside_start(void)
{
    static uint16 bind_sock = 0;
    if ( bind_sock == 0 )
    {
        bind_sock = theNet.Accept( settings::json()[ "outside_addr" ].asString().c_str(), link_outside_accept, NULL );
        if ( bind_sock == 0 )
        {
            LOG_ERROR( "建立监听失败[%s]", settings::json()[ "outside_addr" ].asString().c_str() );
        }
        else
        {
            LOG_INFO( "外部连接创建成功: %hu", bind_sock );
        }
    }
}

