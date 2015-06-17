#ifndef _GAMESVR_SYSTEM_DC_H_
#define _GAMESVR_SYSTEM_DC_H_

#include "dc.h"
#include "proto/system.h"

class CSystemDC : public TDC< CSystem >
{
public:
    CSystemDC();

    uint32 create( uint32 role_id );
    uint32 get_session( uint32 role_id );
};
#define theSystemDC TSignleton< CSystemDC >::Ref()

#endif

