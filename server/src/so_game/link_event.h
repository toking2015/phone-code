#ifndef _GAME_LINK_EVENT_H_
#define _GAME_LINK_EVENT_H_

#include "event.h"

//所有网络连接事件都存在二次调用可能性
//当网络断开并重连成功时, 事件会被重新调用
struct SEventNetAccess
{
};
struct SEventNetRealDB
{
};
struct SEventNetFight
{
};
struct SEventNetAuth
{
};

//外部连接事件, 断线后重连后仍然会收到事件( 会被触发多次 )
struct SEventLinkSocial
{
};

#endif //_GAME_LINK_EVENT_H_
