#include "master.h"
#include "log.h"
#include "netio.h"
#include "pack.h"
#include "msg.h"
#include "misc.h"
#include "systimemgr.h"
#include "dynamicmgr.h"
#include "proto/constant.h"
#include "remote.h"

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
    tag_msg_head* msg = (tag_msg_head*)&stream[4];
    LOG_WARN( "malformed protocol: type[%u]", msg->msg_cmd );
}

void OnIntermitEvent( std::string ev )
{
    if ( ev == "reload" )
    {
        //暂停IO线程
        theNet.Pause();

        //重置逻辑SO
        theDynamicMgr.load( "logic" );
        theMaster.ReLoadData();

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

    //在主程序中链接进来这个函数
    remote::link_outside_read(0,0,0,0);
}

void CMaster::LoadData(void)
{
}

void CMaster::ReLoadData(void)
{
}
