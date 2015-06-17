#include "pro.h"
#include "misc.h"
#include "msg.h"
#include "local.h"
#include "log.h"
#include "proto/transfrom.h"
#include "proto/system.h"
#include "server.h"
#include "user_dc.h"

void OnMsgRelease( SMsgHead* msg )
{
    delete msg;
}

void OnMsgListenPre( SMsgHead* msg )
{
    server::local_time( (uint32)time(NULL) );

    //记录全局行为号
    global_action = msg->action;
}

SO_LOAD( pro_proto_transfrom_init )
{
    theMsg.msg_trans_map = class_transfrom::get_handles();
    theMsg.OnMsgRelease = OnMsgRelease;

    theMsg.OnListenPre = OnMsgListenPre;

    server::local_time( (uint32)time(NULL) );
}

void HandleErrCode(SUser* user, uint32 err_no, uint32 err_desc)
{
    PRSystemErrCode     rep;
    bccopy(rep, user->ext);
    rep.err_no          = err_no;
    rep.err_desc        = err_desc;
    local::write( local::access, rep );
}

void HandleErrCode(SMsgHead& msg, uint32 err_no, uint32 err_desc)
{
    PRSystemErrCode     rep;
    bccopy(rep, msg);
    rep.err_no          = err_no;
    rep.err_desc        = err_desc;
    local::write( local::access, rep );
}

void OnMsgErrorListen( SMsgHead* msg )
{
    LOG_ERROR( "error protocol: type[%u]", msg->msg_cmd );

    //强制下线, 保护玩家数据
    if ( msg->role_id != 0 )
        theUserDC.quit_force( msg->role_id, kErrSystemUnusualError );
}

SO_LOAD( msg_error_listen )
{
    theMsg.OnListenError = OnMsgErrorListen;
}

