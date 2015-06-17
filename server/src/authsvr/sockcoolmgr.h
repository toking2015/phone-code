#ifndef _IMMORTAL_AUTHSVR_SOCKCOOLMGR_H_
#define _IMMORTAL_AUTHSVR_SOCKCOOLMGR_H_

#include "common.h"

class CSockCoolMgr
{
private:
    std::map< int32, uint32 > sock_release_map;
    wd::CMutex mutex;

public:
    void release( int32 sock );
    bool InCooling( int32 sock );

    void process(void);
};
#define theSockCoolMgr TSignleton< CSockCoolMgr >::Ref()

#endif

