#include "call_pro.h"
#include "call_imp.h"
#include "netio.h"
#include "log.h"
#include "sockcoolmgr.h"
#include "local.h"
#include "server.h"
#include "proto/mail.h"
#include "proto/system.h"
#include "proto/pay.h"
#include "proto/chat.h"
#include "proto/activity.h"
#include "proto/broadcast.h"

//终止接口定时执行
JSON_FUNC( sys_runtime_terminate )
{
    JSON_PARAM_CHECK( guid );

    json::Terminate( to_uint( json[ "guid" ] ) );

    theNet.Write( sock, "ok", 2 );
}

//登录
JSON_FUNC( sys_auth )
{
    JSON_PARAM_CHECK( rid );

    PQSystemAuth msg;
    msg.outside_sock = sock;

    msg.role_id = to_uint( json["rid"] );

    local::write( local::game, msg );
}

//充值
JSON_FUNC( sys_pay )
{
    JSON_PARAM_CHECK( rid );
    JSON_PARAM_CHECK( uid );
    JSON_PARAM_CHECK( coin );
    JSON_PARAM_CHECK( time );
    JSON_PARAM_CHECK( order );

    PQPayNotice msg;

    msg.target_id = to_uint( json["rid"] );

    local::write( local::game, msg );

    theNet.Write( sock, "ok", 2 );
}

//踢人
JSON_FUNC( sys_kick )
{
    JSON_PARAM_CHECK( rid );

    PQSystemKick msg;

    msg.role_id = to_uint( json["rid"] );

    local::write( local::game, msg );

    theNet.Write( sock, "ok", 2 );
}

//服务器状态
JSON_FUNC( sys_msg )
{
}

//封禁逻辑协议
JSON_FUNC( sys_block_protocol )
{
}

//聊天屏弊
JSON_FUNC( chat_ban )
{
    JSON_PARAM_CHECK( rid );
    JSON_PARAM_CHECK( seconds );

    PQChatBan msg;
    msg.role_id = to_uint( json["rid"] );
    msg.end_time = server::local_time() + to_uint( json["seconds"] );

    local::write( local::game, msg );

    theNet.Write( sock, "ok", 2 );
}

//系统邮件
JSON_FUNC( mail_send )
{
    JSON_PARAM_CHECK( subject );
    JSON_PARAM_CHECK( body );
    JSON_PARAM_CHECK( type );

    //接拼附件
    std::vector< S3UInt32 > coins;
    if ( json[ "coins" ].type() == Json::arrayValue )
    {
        S3UInt32 coin;
        const Json::Value aj = json[ "coins" ];
        for ( uint32 i = 0; i < aj.size(); ++i )
        {
            if ( aj[i][ "cate" ].type() == Json::nullValue )
            {
                LOG_ERROR( "json param [mail_send.coins[%d].%s] not found!", i, "cate" );
                return;
            }
            if ( aj[i][ "objid" ].type() == Json::nullValue )
            {
                LOG_ERROR( "json param [mail_send.coins[%d].%s] not found!", i, "objid" );
                return;
            }
            if ( aj[i][ "val" ].type() == Json::nullValue )
            {
                LOG_ERROR( "json param [mail_send.coins[%d].%s] not found!", i, "val" );
                return;
            }

            coin.cate = to_uint( aj[i][ "cate" ] );
            coin.objid = to_uint( aj[i][ "objid" ] );
            coin.val = to_uint( aj[i][ "val" ] );

            coins.push_back( coin );
        }
    }

    uint32 type = to_uint( json[ "type" ] );

    switch ( type )
    {
    case kMailTypePlayer:
        {
            PQMailWrite msg;

            msg.target_id   = to_uint( json[ "target_id" ] );
            if ( msg.target_id == 0 )
            {
                LOG_ERROR( "json param [mail_send.target_id == 0] not found!" );
                return;
            }

            msg.subject     = to_str( json[ "subject" ] );
            msg.body        = to_str( json[ "body" ] );
            msg.coins       = coins;

            local::write( local::game, msg );
        }
        break;

    case kMailTypeAll:
        {
            PQMailSave msg;

            msg.data.flag           = kMailFlagSystem;
            msg.data.path           = kPathSystemAuto;
            msg.data.deliver_time   = server::local_time();
            msg.data.sender_name    = "系统邮件";
            msg.data.subject        = to_str( json[ "subject" ] );
            msg.data.body           = to_str( json[ "body" ] );
            msg.data.coins          = coins;

            local::write( local::realdb, msg );
        }
        break;

    case kMailTypeOnline:
        {
            PQMailWrite msg;

            msg.subject     = to_str( json[ "subject" ] );
            msg.body        = to_str( json[ "body" ] );
            msg.coins       = coins;

            local::write( local::game, msg );
        }
        break;
    }

    theNet.Write( sock, "ok", 2 );
}

//加载activity_open
JSON_FUNC( sys_activity_open )
{
    PQActivityOpenLoad msg;

    local::write( local::game, msg );

    theNet.Write( sock, "ok", 2 );
}

//加载activity_data
JSON_FUNC( sys_activity_data )
{
    PQActivityDataLoad msg;

    local::write( local::game, msg );

    theNet.Write( sock, "ok", 2 );
}

//加载activity_factor
JSON_FUNC( sys_activity_factor )
{
    PQActivityFactorLoad msg;

    local::write( local::game, msg );

    theNet.Write( sock, "ok", 2 );
}

//加载activity_reward
JSON_FUNC( sys_activity_reward )
{
    PQActivityRewardLoad msg;

    local::write( local::game, msg );

    theNet.Write( sock, "ok", 2 );
}

JSON_FUNC( sys_placard )
{
    JSON_PARAM_CHECK( order );
    JSON_PARAM_CHECK( flag );
    JSON_PARAM_CHECK( text );

    PQSystemPlacard msg;

    msg.broad_cast  = kCastServer;
    msg.broad_type  = 0;
    msg.broad_id    = 0;

    msg.order       = to_uint( json["order"] );
    msg.flag        = to_uint( json["flag"] );
    msg.text        = to_str( json["text"] );

    local::write( local::game, msg );

    theNet.Write( sock, "ok", 2 );
}

#define MACRO_CHECK( k )\
{\
    if ( key != k || theSockCoolMgr.InCooling( msg.outside_sock ) )\
    return;\
}

//==================这里开始处理返回协议=================

#undef MACRO_CHECK

