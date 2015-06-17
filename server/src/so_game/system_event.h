#ifndef _GAME_SYSTEM_EVENT_H_
#define _GAME_SYSTEM_EVENT_H_

#include "event.h"

//Json数据加载成功, 每次动态更新该事件会重复调用
//这个最好别用 有加载顺序的问题
struct SEventJsonLoaded
{
};

#endif //_GAME_SYSTEM_EVENT_H_
