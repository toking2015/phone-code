#include "timer.h"
#include "social_dc.h"
#include "settings.h"
#include "netio.h"
#include "pack.h"
#include "remote.h"
#include "server.h"
#include "log.h"
#include "link_event.h"

SO_LOAD( social_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "social_keep_online",
        "",
        "",
        NULL,
        CSysTimeMgr::Second,
        10,
        0
    );
}

void OnSocialConnected( void* p, int32 sock )
{
    if ( sock <= 0 )
        return;

    theSocialDC.db().last_recv_time = server::local_time();

    remote::deposit( local::social, sock );

    //发关绑定协议
    PQSocialServerBind msg;

    const Json::Value unite = settings::json()[ "unite" ];
    for ( uint32 i = 0; i < unite.size(); ++i )
    {
        msg.sid = unite[i].asUInt();

        remote::write( local::social, msg );
    }

    //连接事件
    event::dispatch( SEventLinkSocial() );
}
TIMER( social_keep_online )
{
    if ( server::local_time() > theSocialDC.db().last_recv_time + 20 )
    {
        remote::clear( local::social );

        theNet.Connect( settings::json()[ "social_addr" ].asString().c_str(), OnSocialConnected, NULL );

        LOG_INFO( "social connect: %s", settings::json()[ "social_addr" ].asString().c_str() );
        return;
    }

    //发送ping 包保持连接
    PQSocialServerPing msg;

    remote::write( local::social, msg );
}

