#include "master.h"
#include "settings.h"
#include "parammgr.h"
#include "signalmgr.h"
#include "dynamicmgr.h"
#include "log.h"
#include "netio.h"
#include "pack.h"
#include "msg.h"
#include "netsingle.h"
#include "misc.h"
#include <stdio.h>
#include <fstream>
#include "proto/constant.h"
#include "dataproxy.h"
#include "db.h"

void OnBreakDown(void)
{
    /*
    theMsg.FlushMsg();

    if ( !user_data_file.empty() )
        theUserMgr.SaveUserData( user_data_file.c_str() );
    */
}
void OnShutDown(void)
{
    //do nothing...
}
void OnCustom10(void)
{
    tag_msg_head msg;
    msg.msg_cmd = 1985312526;

    uint32 size = sizeof( msg );
    wd::CStream stream;

    stream.write( &size, 4 );
    stream.write( &msg, size );

    theMsg.Post( 0, 0, &stream[0], stream.length() );

    //结束线程
    theNet.EndThread();
    thePack.EndThread();
    theMsg.EndThread();
    theDB.EndThread();

    exit(0);
}

void OnCustom12(void)
{
    theMsg.Intermit( "reload" );
}

void OnDynamicLoaded(void)
{
    //加载时不作处理, 各系统数据模块实例在第一次被调用注册时自动恢复数据, 不作一次性恢复
}

void OnDynamicUnload(void)
{
    //将所有系统数据一次性保存至数据代理器
    CDataProxy::trans_to_stream_and_reset();
    (*theMaster._resource_reg_free)();
}

//加载日志配置
void ParamLog( std::vector< std::string > params )
{
    CLog4cxx::read( params[0].c_str() );
}
//加载程序配置
void ParamConfig( std::vector< std::string > params )
{
    if ( !settings::read( params[0].c_str() ) )
    {
        printf( "read setting wrong\n" );
        exit(-1);
    }

    //加载动态库
    theDynamicMgr.OnLoaded = OnDynamicLoaded;
    theDynamicMgr.OnUnload = OnDynamicUnload;
    theDynamicMgr.config_local_dir( settings::json()[ "local_dir" ].asString() );
    theDynamicMgr.config_so_name( "logic", settings::json()[ "so_path" ].asString() );
    theDynamicMgr.load( "logic" );

    //加载游戏资源
    theMaster.LoadData();
}

//捕获异常信号时产生 core.log 文件
void ParamMsgCoreLog( std::vector< std::string > params )
{
    theSignalMgr.SetCoreLog( params[0].c_str() );
}
void ParamDaemon( std::vector< std::string > params )
{
    if (-1 == daemon(1, 0))
        exit(-1);
}
//设置协议打印
void ParamMsgSave( std::vector< std::string > params )
{
    theMsg.SaveMsgLog( params[0].c_str() );
}

//不使用协议执行时间对齐
void ParamMsgDebug( std::vector< std::string > params )
{
    debug_msg( params[0].c_str(), false );

    //调试完后立即退出进程
    exit(0);
}

//NetSingal网络错误信息
void NetError( std::string msg )
{
    //sys_msg_mark( "GameNet: " + msg );
}
int main(int argc, char** argv)
{
    //处理程序信号异常
    theSignalMgr.Init( argv[0], OnBreakDown, OnShutDown, OnCustom10, OnCustom12 );

    //参数管理
    theParamMgr.bind( "-l", 1, ParamLog );                  //常用日志
    theParamMgr.bind( "-c", 1, ParamConfig );               //原 config.json 路径
    theParamMgr.bind( "-cl", 1, ParamMsgCoreLog );          //捕获异常信号时产生 core.log
    theParamMgr.bind( "-daemon", 0, ParamDaemon );          //开启后台进程
    theParamMgr.bind( "-p", 1, ParamMsgSave );              //保存通讯协议
    theParamMgr.bind( "-d", 1, ParamMsgDebug );             //非时间对齐 debug

    //执行参数
    std::string param_error;
    if ( !theParamMgr.run( argc, argv, param_error ) )
    {
        LOG_ERROR( param_error.c_str() );
        exit(0);
    }

    //启动事务线程
    theMaster.Start();

    //发起网络连接
    net::start( settings::json()[ "net_singal_hosts" ].asString(), "game", NetError );

    //主线程逻辑处理
    time_t save_time = time(NULL);
    char buff[ 1024 ] = {0};
    int32 posi = -1;
    for(;;)
    {
        std::ifstream input( settings::json()[ "inside_log" ].asString().c_str(), std::ios_base::in | std::ios_base::binary );

        if ( input.is_open() )
        {
            input.seekg( 0, std::ios_base::end );
            int32 size = (int32)input.tellg();

            if ( posi < 0 )
                posi = size;

            if ( size < posi )
                posi = 0;

            while ( size > posi )
            {
                input.seekg( posi );
                int32 len = ( size - posi < (int32)sizeof( buff ) - 1 ) ? ( size - posi ) : ( (int32)sizeof( buff ) - 1 );
                input.read( (char*)buff, len );

                buff[ len ] = '\0';

                /*
                SSystemQInsideLog msg;
                msg.content = buff;

                theMsg.Post( (SMsgHead*)msg.clone(), (void*)(int32)kNetGame );
                */

                save_time = time(NULL);
                posi += len;
            }

            input.close();
        }

        sleep( 3 );
    }

    exit(0);
}

