#ifndef _COMMON_REMOTE_H_
#define _COMMON_REMOTE_H_

#include "linkdef.h"
#include "proto/common.h"
#include "common.h"

class CRemote
{
public:
    std::map<int32, int32> remote_map;
};


#define theRemoteMgr TSignleton< CRemote >::Ref()

namespace remote
{

bool valid( int32 remote_id );
void clear( int32 remote_id );

void link_outside_read( void* param, int32 sock, char* buff, int32 size );
void OnRemoteRead( void* p, int32 sock, char* buff, int32 size );
void deposit( int32 remote_id, int32 sock );

void write( int32 remote_id, SMsgHead& msg );
void write_to_socket( int32 sock, SMsgHead& msg );

} // namespace remote

#endif

