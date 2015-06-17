#ifndef _PUBLIC_LOCAL_H_
#define _PUBLIC_LOCAL_H_

#include "proto/common.h"
#include "misc.h"
#include "linkdef.h"

namespace local
{

void post( int32 key, SMsgHead& msg );
void send( int32 key, SMsgHead& msg );

//单点发送数据
void write( int32 local_id, SMsgHead& msg );

//所有服务器广播数据
void broadcast( SMsgHead& msg );

}// namespace local

#endif

