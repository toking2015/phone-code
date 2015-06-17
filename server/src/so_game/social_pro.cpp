#include "pro.h"
#include "proto/social.h"
#include "social_dc.h"
#include "server.h"

MSG_FUNC( PRSocialServerPing )
{
    theSocialDC.db().last_recv_time = server::local_time();
}

