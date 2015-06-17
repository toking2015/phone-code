#include "master.h"
#include "log.h"
#include "netio.h"
#include "pack.h"
#include "msg.h"
#include "db.h"
#include "misc.h"
#include "settings.h"
#include "systimemgr.h"
#include "dynamicmgr.h"
#include "proto/constant.h"
#include "proto/common/SMsgHead.h"
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

        //重新加载 settings 数据
        settings::read( NULL );

        //重置逻辑与数据库线程互斥
        {
            wd::CGuard< wd::CMutex > safe( &theDB.reload_mutex );

            theDynamicMgr.load( "logic" );
            theMaster.ReLoadData();
        }

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

    //数据库处理线程
    theDB.StartThread();

    //网络并发线程
    theNet.StartThread();

    //主程序中需要以下数据和函数
    //so中使用相应数据和函数的时候会拿主程序的地址
    theDynamicMgr;
    remote::OnRemoteRead(0,0,0,0);
}

void CMaster::LoadData(void)
{
    /*
    std::string lua_path = settings::json()[ "lua_path" ].asString();
    std::string trans_path = settings::json()[ "trans_path" ].asString();
    theLuaMgr.InitLua(lua_path.c_str());
    theLuaMgr.AddPathLua(trans_path.c_str());
    lua::LuaInterfaceInit( theLuaMgr.Lua() );
    theLuaMgr.LoadLua("SvrConfig.lua");
    theLuaMgr.LoadLua("BattleLogic.lua");
    return;
    */
}

void CMaster::ReLoadData(void)
{
    //std::string lua_path = settings::json()[ "lua_path" ].asString();
    //std::string trans_path = settings::json()[ "trans_path" ].asString();
    //theLuaMgr.InitLua(lua_path.c_str());
    //theLuaMgr.AddPathLua(trans_path.c_str());
    //lua::LuaInterfaceInit( theLuaMgr.Lua() );
    //theLuaMgr.LoadLua("SvrConfig.lua");
    //theLuaMgr.LoadLua("BattleLogic.lua");
    //return;
}

