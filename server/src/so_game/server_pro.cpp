#include "server.h"
#include "misc.h"
#include "local.h"
#include "proto/server.h"
#include "user_dc.h"
#include "guild_dc.h"
#include "server_event.h"
#include "server_dc.h"
#include "jsonconfig.h"
#include "settings.h"
#include "friend_dc.h"

MSG_FUNC( PRServerOpen )
{
    if ( key != local::self )
        return;

    const Json::Value unite = settings::json()[ "unite" ];
    if ( unite.size() <= 0 )
    {
        LOG_ERROR( "server unite empty!" );
        return;
    }

    for ( uint32 i = 0; i < unite.size(); ++i )
    {
        uint32 sid = unite[i].asUInt();

        theServerDC.db().server_ids.push_back( sid );
    }
}

MSG_FUNC( PRServerClose )
{
    if ( key != local::self )
        return;

    theUserDC.each_save(3);
}

MSG_FUNC( PQServerNotify )
{
    //不接受从网关发送的服务器变量通知
    if ( key == local::access )
        return;

    server::data_map()[ msg.key ] = msg.value;
}

MSG_FUNC( PRServerInfoList )
{
    server::data_map() = msg.key_value;

    event::dispatch( SEventServerInfo() );

    //自抛开服协议
    PRServerOpen rep;
    local::write( local::self, rep );
}

MSG_FUNC( PRServerNameList )
{
    //构建id_name映射
    for ( std::map< std::string, uint32 >::iterator iter = msg.user_name_id.begin();
        iter != msg.user_name_id.end();
        ++iter )
    {
        theUserDC.db().user_name_id[ iter->first ] = iter->second;
        theUserDC.db().user_id_name[ iter->second ] = iter->first;
    }

    for ( std::map< std::string, uint32 >::iterator iter = msg.guild_name_id.begin();
        iter != msg.guild_name_id.end();
        ++iter )
    {
        theGuildDC.db().guild_name_id[ iter->first ] = iter->second;
        theGuildDC.db().guild_id_name[ iter->second ] = iter->first;
    }
}

MSG_FUNC( PRServerFriendList )
{
    for ( std::map< uint32, SFriendData >::iterator iter = msg.user_id_friend.begin();
        iter != msg.user_id_friend.end();
        ++iter )
    {
        theFriendDC.db().user_id_friend[ iter->first ] = iter->second;
    }
}

