#ifndef _IMMORTAL_ACCESSSVR_IOMGR_H_
#define _IMMORTAL_ACCESSSVR_IOMGR_H_

#include "common.h"

class CIOMgr
{
private:
    wd::CMutex mutex;

public:
    void AddSock( int32 sock );
    void DelSock( int32 sock );

private:
    static void OnRead( void* param, int32 sock, char* buff, int32 size );
};

#define theIOMgr TSignleton< CIOMgr >::Ref()

#endif

