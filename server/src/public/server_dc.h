#ifndef _IMMORTAL_PUBLIC_SERVER_DC_H_
#define _IMMORTAL_PUBLIC_SERVER_DC_H_

#include "common.h"
#include "proto/server.h"

#include "dc.h"

class CServerDC : public TDC< CServer >
{
public:
    CServerDC() : TDC< CServer >( "server" )
    {
    }

    ~CServerDC()
    {
    }
};
#define theServerDC TSignleton< CServerDC >::Ref()

#endif

