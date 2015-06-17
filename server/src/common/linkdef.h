#ifndef _COMMON_LINK_DEF_H_
#define _COMMON_LINK_DEF_H_

#include "common.h"

#include "netsingle.h"
#include "misc.h"
#include "pack.h"
#include "local.h"

/*
  access    --|
  auth      --|
                -- game[逻辑服] -[ remote 模块 ]- social[交互服] -- sharedb[类似realdb]
  fight     --|
  realdb    --|
*/
namespace local
{
    enum
    {
        self    = 0,
        outside = 1,
        game    = 2,
        access  = 3,
        auth    = 4,
        fight   = 5,
        realdb  = 6,

        social  = 101,      //交互服( game 可以使用 remote::write 发送到 social, 但不能直接到达 sharedb )
        sharedb = 102,      //共享数据库, 只有在 social 通过 local::write 发送到 sharedb

        robot   = 201,      //机器人
    };
} // namespace local

#define NET_SINGLE_READ(n)\
void _net_single_read_##n( int32, char*, int32 );\
SO_LOAD( _net_single_read_##n )\
{\
    net::set_net_read( #n, local::n, _net_single_read_##n );\
}\
void _net_single_read_##n( int32 sock, char* buff, int32 size )

#define NET_SINGLE_CONNECT(n)\
void _net_single_connect_##n(void);\
SO_LOAD( _net_single_connect_##n )\
{\
    net::set_net_connect( #n, local::n, _net_single_connect_##n );\
}\
void _net_single_connect_##n(void)

#endif

