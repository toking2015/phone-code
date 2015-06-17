#ifndef _GAMESVR_SOCIAL_DC_H_
#define _GAMESVR_SOCIAL_DC_H_

#include "dc.h"
#include "proto/social.h"

class CSocialDC : public TDC< CSocial >
{
public:
    CSocialDC() : TDC< CSocial >( "social" )
    {
    }

    void init_data( std::vector< SSocialRole >& list );
};
#define theSocialDC TSignleton< CSocialDC >::Ref()

#endif

