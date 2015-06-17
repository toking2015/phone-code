#ifndef _AUTHSVR_AUTH_DC_H_
#define _AUTHSVR_AUTH_DC_H_

#include "dc.h"
#include "proto/auth.h"

class CAuthDC : public TDC< CAuth >
{
public:
    CAuthDC();

    void online( uint32 rid );
};
#define theAuthDC TSignleton< CAuthDC >::Ref()

#endif

