#include "guild_event.h"
#include "link_event.h"
#include "util.h"
#include "guild_dc.h"
#include "proto/guild.h"
#include "local.h"

EVENT_FUNC( guild, SEventGuildJoin )
{
    //扩播新用户加入公会?
    for ( std::vector< SGuildMember >::iterator iter = ev.guild->data.member_list.end();
        iter != ev.guild->data.member_list.end();
        ++iter )
    {
        //do something ...
    }

    //排序公会索引
    theGuildDC.sort();
}

EVENT_FUNC( guild, SEventNetRealDB )
{
    //请求公会基本列表数据
    PQGuildSimpleList msg;

    local::write( local::realdb, msg );
}
