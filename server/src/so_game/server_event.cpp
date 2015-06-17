#include "event.h"
#include "local.h"
#include "server.h"
#include "proto/server.h"
#include "server_event.h"
#include "link_event.h"
#include "resource/r_globalext.h"

EVENT_FUNC( server, SEventNetRealDB )
{
    //请求服务器变量(server_info)
    {
        PQServerInfoList msg;

        local::write( local::realdb, msg );
    }

    //请求所有名称数据
    {
        PQServerNameList msg;

        local::write( local::realdb, msg );
    }

    //请求所有等级大于friend_system_level_limit=15的玩家id
    {
        //PQServerFriendList msg;
        //msg.level = theGlobalExt.get<uint32>("friend_system_level_limit");

        //local::write( local::realdb, msg );
    }
}

EVENT_FUNC( server, SEventServerInfo )
{
    uint32 open_time = server::get< uint32 >( "open_time" );
    if ( open_time == 0 )
        open_time = server::local_time();

    server::set( "open_time", open_time );
}

