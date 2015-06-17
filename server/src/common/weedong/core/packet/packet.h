/*************************************************
  Description:      // 打包解包
  Class:            // 研发七部
  Name:             // 骆建伟
  Date:             // 2011-10-27
  Descript:
    提供数据打包和解包服务
*************************************************/

#ifndef _WEEDONG_CORE_PACKGE_H_INCLUDED
#define _WEEDONG_CORE_PACKGE_H_INCLUDED

#if defined LINUX
#include <unistd.h>
#include <stdarg.h>
#include <stddef.h>
#elif defined WIN32
#include <string.h>
#include <stdlib.h>
#endif

typedef struct _tagpacket_t
{
	char* buf;			// 缓冲区指针
	size_t write_offset;	// 当前已写位移
	size_t read_offset;		// 当前已读的位移
	size_t max_size;	// 缓冲区大小
}packet_t;

// 分配空间
packet_t* packet_alloc(size_t length);

// 加入新的包，返回-1表示失败，其他表示写入的数据长度
int packet_join(packet_t* p, const void* in_data, size_t in_max_size);

int packet_join_struct(packet_t* p, const void* in_data, size_t in_max_size);

// 从包中获取数据，返回-1表示失败，其他表示写入的数据长度
int packet_take(packet_t* p, void* out_data, size_t out_max_size);

int packet_take_struct(packet_t* p, void* out_data, size_t out_max_size);

// 回收packet
void packet_dispose(packet_t* p);

// 直接打包成大的数据
packet_t* packet_pack(const void* in_data, size_t in_max_size);

#endif	// _WEEDONG_CORE_PACKGE_H_INCLUDED