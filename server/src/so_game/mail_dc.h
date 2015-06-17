#ifndef _GAMESVR_MAIL_DC_H_
#define _GAMESVR_MAIL_DC_H_

#include "dc.h"
#include "proto/mail.h"

class CMailDC : public TDC< CMail >
{
public:
    CMailDC() : TDC< CMail >( "mail" )
    {
    }
};
#define theMailDC TSignleton< CMailDC >::Ref()

#endif

