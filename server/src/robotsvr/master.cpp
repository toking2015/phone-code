#include "master.h"
#include "log.h"
#include "netio.h"
#include "pack.h"
#include "msg.h"
#include "misc.h"
#include "systimemgr.h"
#include "dynamicmgr.h"
#include "proto/constant.h"
#include "proto/transfrom.h"
#include "test.h"

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
    //theSysTimeMgr.Process();
    theTest.Check();
}

void OnMsgDefaultListen( int32 sock, int32 key, wd::CStream& stream )
{
    tag_msg_head* msg = (tag_msg_head*)&stream[4];
    LOG_WARN( "malformed protocol: type[%u]", msg->msg_cmd );
}

void OnIntermitEvent( std::string ev )
{
    if ( ev == "reload" )
    {
        //重置逻辑与数据库线程互斥
        theDynamicMgr.load( "logic" );
    }
}

/*****************CMaster*****************/
CMaster::CMaster()
{
}

CMaster::~CMaster()
{
}

void OnMsgRelease(SMsgHead* msg)
{
    delete msg;
}

void OnMsgListenPre(SMsgHead* msg)
{
    //server::local_time((uint32)time(NULL));
}

void CMaster::Start()
{
    theSysTimeMgr.SetOnTime( timer_progress );

    //组包事务线程
    thePack.SetStreamHandler(OnPackStream);
    thePack.SetErrorHandler(OnPackError);
    thePack.StartThread();

    //消息事务线程
    theMsg.msg_trans_map = class_transfrom::get_handles();
    theMsg.OnMsgRelease  = OnMsgRelease;
    theMsg.OnListenPre   = OnMsgListenPre;
    //server::local_time((uint32)time(NULL));

    theMsg.OnListenDefault = OnMsgDefaultListen;
    theMsg.OnIntermitEvent = OnIntermitEvent;
    theMsg.OnIdle          = OnMsgIdle;
    theMsg.StartThread();

    //网络并发线程
    theNet.StartThread();
}
