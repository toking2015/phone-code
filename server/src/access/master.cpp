#include "master.h"
#include "log.h"
#include "netio.h"
#include "pack.h"
#include "misc.h"
#include "msg.h"
#include "local.h"
#include "systimemgr.h"
#include "user.h"
#include "netsingle.h"
#include "cache.h"
#include "dynamicmgr.h"
#include "cool.h"

void OnPackStream( uint32 sock, int32 key, void* data, uint32 size )
{
    theMsg.Post( sock, key, data, size );
}

void OnPackError(uint32 sock, int32 key, uint32 size, uint32 cmd, int32 err)
{
    LOG_ERROR("sock[%d] key[%d] data error! size[%d]! cmd[%u] err[%d]", sock, key, size, cmd, err);
}

void OnMsgIdle(void)
{
    theSysTimeMgr.Process();
}

void OnMsgDefaultListen( int32 sock, int32 key, wd::CStream& stream )
{
    //前面4字节为 tag_msg_head 协议体大小
    tag_msg_head* msg = (tag_msg_head*)&stream[4];

    switch ( key )
    {
    case local::outside:
        {
            //sock 在冷却中
            if ( sock != 0 && cool::is_cool( sock ) )
                break;

            //31位为1是 PR 协议, 不应该由客户端发送到服务器
            //不使用第 32位, 因为 lua 对第 32 位无法辨认
            if ( msg->msg_cmd & 0x40000000 )
                break;

            //检查用户数据包合法性
            if ( !user::check_session( msg->role_id, msg->session ) )
            {
                tag_msg_error msg_error;
                msg_error.err_no = 437223085; //kErrSystemSession;

                uint32 error_size = sizeof( tag_msg_head );

                wd::CStream error_stream;
                error_stream.write( &error_size, sizeof( error_size ) );
                error_stream.write( &msg_error, sizeof( tag_msg_error ) );

                tag_pack_head head;
                CPack::fill_pack_head( &head, &error_stream[0], error_stream.length() );

                theNet.Write( sock, &head, sizeof( tag_pack_head ) );
                theNet.Write( sock, &error_stream[0], error_stream.length() );
                break;
            }

            //如果 sock 为 0, 即为堆包重新执行的数据包, 原有 sock 已经不可靠, 这里不对原有 sock 进行处理
            if ( sock != 0 )
            {
                user::SData* user = user::find( msg->role_id );

                //用户不存在, 不太可能
                if ( user == NULL )
                    break;

                if ( user->sock != sock )
                {
                    if ( user->sock == 0 )
                    {
                        //用户之前为离线态
                        cache::online( msg->role_id );
                    }
                    else
                    {
                        //异地同 session 登录? 或断线重连成功, 旧 sock 没有正确被 close ?
                        cool::append( user->sock );
                    }

                    //更新用户 sock
                    user::update_sock( msg->role_id, sock );
                }
            }

            //顺序化数据包处理, 把类积的数据包进行转发至服务器
            uint32 client_order = user::pack_order_process( msg->role_id, msg->order );

            //client_order == 0 为用户不存在, 不作处理
            if ( client_order == 0 )
                break;

            //msg->order < client_order 重复发送的数据包, 不作处理
            if ( msg->order < client_order )
                break;

            //msg->order > client_order 用户发送的数据包有漏包, 回发补全请求
            if ( msg->order > client_order )
            {
                //压入缓存堆, 这里 sock 不再作透传, 因为堆包被执行后的 sock 可能已经无效, 或者不是原来用户的 sock
                user::pack_order_push( msg->role_id, msg->order, /*sock*/0, key, stream );

                //回发到用户
                tag_msg_order msg_order;
                msg_order.role_id = msg->role_id;
                msg_order.session = msg->session;
                msg_order.min = client_order;
                msg_order.max = msg->order - 1;

                uint32 order_size = sizeof( msg_order );

                wd::CStream order_stream;
                order_stream.write( &order_size, sizeof( order_size ) );
                order_stream.write( &msg_order, order_size );

                tag_pack_head head;
                CPack::fill_pack_head( &head, &order_stream[0], order_stream.length() );

                user::write( msg->role_id, 0, &head, sizeof( tag_pack_head ) );
                user::write( msg->role_id, 0, &order_stream[0], order_stream.length() );
                break;
            }

            //转发到game
            tag_pack_head head;
            CPack::fill_pack_head( &head, &stream[0], stream.length() );

            net::write( local::game, &head, sizeof( tag_pack_head ) );
            net::write( local::game, &stream[0], stream.length() );
        }
        break;
    case local::game:
        {
            //清空回发数据包 session, 避免 session 泄漏
            msg->session = 0;

            if ( msg->broad_cast != 0 )
            {
                uint64 broad_value = cache::channel_to_value( msg->broad_cast, msg->broad_type, msg->broad_id );
                cache::push( broad_value, stream );
                break;
            }

            uint32 target_id = msg->role_id;

            /*
            //存在广播 broad_id != 0 而且 broad_value == 0 的可能?
            if ( msg->broad_id != 0 )
                target_id = msg->broad_id;
            */

            //如果缺失目标用户id, 直接返回
            if ( target_id == 0 )
                break;

            user::SData* user = user::find( target_id );
            if ( user == NULL )
                break;

            //设置顺序索引
            msg->order = user->server_order++;

            //转发到用户
            tag_pack_head head;
            CPack::fill_pack_head( &head, &stream[0], stream.length() );

            user::write( target_id, msg->order, &head, sizeof( tag_pack_head ) );
            user::write( target_id, msg->order, stream );
        }
        break;
    }
}

void OnIntermitEvent( std::string ev )
{
    if ( ev == "reload" )
    {
        //暂停IO线程
        theNet.Pause();

        //重置逻辑SO
        theDynamicMgr.load( "logic" );

        //恢复IO线程
        theNet.Resume();
    }
}

/*****************CMaster*****************/
CMaster::CMaster()
{
}

CMaster::~CMaster()
{
}

void CMaster::Start(void)
{
    theSysTimeMgr.SetOnTime( timer_progress );

    //组包事务线程
    thePack.SetStreamHandler( OnPackStream );
    thePack.SetErrorHandler( OnPackError );
    thePack.StartThread();

    //消息事务线程
    theMsg.OnListenDefault = OnMsgDefaultListen;
    theMsg.OnIdle = OnMsgIdle;
    theMsg.OnIntermitEvent = OnIntermitEvent;
    theMsg.StartThread();

    //网络并发线程
    theNet.StartThread();
}

void CMaster::LoadData(void)
{
}

void CMaster::ReLoadData(void)
{
}

