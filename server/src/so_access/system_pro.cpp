#include "misc.h"
#include "proto/system.h"
#include "user.h"
#include "netio.h"
#include "cache.h"
#include "local.h"
#include "raw.h"
#include "server.h"
#include "pro.h"
#include "cool.h"

//Ping
MSG_FUNC( PQSystemPing )
{
    SO_PRO_ORDER_CHECK();

    user::SData* user = user::find( msg.role_id );
    if ( user == NULL )
        return;

    PRSystemPing rep;
    bccopy( rep, msg );

    rep.server_time = server::local_time();

    //Ping 包之所以使用 order 序列是客户端需要通过 ping 返回包进行持续序列校验, 发现缺失及时请求补发
    user::write( user->server_order++, rep );

    /*
       不再使用底层直接回发 ping
    raw::send_msg_whitout_session( sock, rep );
    */
}

//Login
MSG_FUNC( PQSystemLogin )
{
    msg.outside_sock = sock;

    //转发到game
    local::write( local::game, msg );
}

MSG_FUNC( PRSystemLogin )
{
    //异地登录错误返回
    user::SData* user = user::find( msg.role_id );
    if ( user != NULL && user->sock != 0 )
    {
        /*
        PRSystemErrCode rep;

        rep.err_no = kErrSystemRemoteLogin;

        wd::CStream stream;
        stream.resize( sizeof( tag_pack_head ) );
        stream << rep;

        CPack::fill_pack_head
        (
            (tag_pack_head*)&stream[0],
            &stream[ sizeof( tag_pack_head ) ],
            stream.length() - sizeof( tag_pack_head )
        );

        theNet.Write( user->sock, &stream[0], stream.length() );
        */
    }

    //更新用户session
    user = user::update_session( msg.role_id, msg.session );

    //重置 server_order 和 client_order 为 1
    user::reset_order( msg.role_id );

    //登录第一个包 order 必须为 0, 客户端需要根据特定协议对 server_order 进行重置
    msg.order = 0;

    if ( user->sock != msg.outside_sock )
    {
        if ( user->sock == 0 )
        {
            //用户之前为离线态
            cache::online( msg.role_id );
        }
        else
        {
            //异地同 session 登录? 或断线重连成功, 旧 sock 没有正确被 close ?
            cool::append( user->sock );
        }

        //更新用户 sock
        user::update_sock( msg.role_id, msg.outside_sock );
    }

    user::write( 0, msg );
}

MSG_FUNC( PQSystemResend )
{
    PRSystemErrCode rep;
    bccopy( rep, msg );

    do
    {
        if ( !user::check_session( msg.role_id, msg.session ) )
        {
            rep.err_no = kErrSystemSession;
            break;
        }

        if ( user::resend_buffer( msg.role_id, msg.server_order ) <= 0 )
        {
            rep.err_no = kErrSystemResend;
            break;
        }
    }
    while(0);

    if ( rep.err_no != 0 )
        user::write( 0, rep );
}

MSG_FUNC( PRSystemKick )
{
    //通知客户端
    user::write( 0, msg );

    //清空session
    user::update_session( msg.role_id, 0 );
}

MSG_FUNC( PRSystemErrCode )
{
    switch ( msg.err_no )
    {
    case kErrSystemUnusualError:
        {
            user::write( 0, msg );

            //删除session
            user::delete_session( msg.role_id );
        }
        return;
    }

    user::SData* user = user::find( msg.role_id );
    if ( user != NULL )
        user::write( user->server_order++, msg );
}

/*
//Session
MSG_FUNC( PRSystemUserUpdateSession )
{
    user::update_session( msg.role_id, msg.session );
}
*/

