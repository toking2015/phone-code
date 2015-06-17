#ifndef _GAME_USER_EVENT_H_
#define _GAME_USER_EVENT_H_

#include "event.h"

//新用户第一次登录数据初始化( 用于处理加模块新用户数据初始化 )
struct SEventUserInit : public SEvent
{
    SEventUserInit( SUser* u, uint32 p ) : SEvent(u, p) {}
};

//用户从数据库中加载数据成功后调用
//手游网络不稳定会重复调用 Login 事件, Loaded 只会在用户cache加载成功后调用
//对用户数据加载后处理请使用本事件
struct SEventUserLoaded : public SEvent
{
    SEventUserLoaded( SUser* u, uint32 p ) : SEvent(u, p) {}
};

//用户重新连接网络后登录调用事件, 请注意和 SEventUserLoad 的区别, 登入前, 尽量使用下面事件
struct SEventUserLogin : public SEvent
{
    SEventUserLogin( SUser* u, uint32 p ) : SEvent(u, p) {}
};

//用户重新连接网络后登录调用事件, 请注意和 SEventUserLoad 的区别, 登入后, 尽量使用 Logined
struct SEventUserLogined : public SEvent
{
    SEventUserLogined( SUser* u, uint32 p ) : SEvent(u, p) {}
};

//在线用户 06:00:00 被执行, 离线用户上线后被执行, 每天只会执行一次, 隔天的会被跳过
struct SEventUserTimeLimit : public SEvent
{
    SEventUserTimeLimit( SUser* u, uint32 p ) : SEvent(u, p) {}
};

//用户数据被访问时触发( theUserDC.find 接口, QU_ON, QU_OFF ), 用于修正被动触发数据, 如: 体力恢复(不跑定时器)
struct SEventUserMeet : public SEvent
{
    SEventUserMeet( SUser* u, uint32 p ) : SEvent(u, p) {}
};

//用户数据保存时触发
struct SEventUserSave : public SEvent
{
    std::string value;
    bool saved;

    SEventUserSave( SUser* u, std::string v, bool s ) : SEvent(u, 0), value(v), saved(s) {}
};

#endif //_GAME_USER_EVENT_H_
