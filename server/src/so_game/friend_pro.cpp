#include "misc.h"
#include "proto/friend.h"
#include "proto/reportpost.h"

#include "netsingle.h"

#include "user_dc.h"
#include "friend_dc.h"
#include "friend_imp.h"
#include "user_imp.h"
#include "settings.h"
#include "log.h"
#include "command_imp.h"
#include "local.h"
#include "server.h"

#include "resource/r_globalext.h"

struct friend_each
{
    void operator()( SUserFriend& data )
    {
        return;
    }
};

MSG_FUNC( PQFriendList )
{
    QU_ON( user, msg.role_id );

    frd::ReplyFriendList( user );
}

MSG_FUNC( PQFriendLimitList )
{
    QU_ON( user, msg.role_id );

    frd::ReplyFriendLimitList( user );
}

MSG_FUNC( PQFriendMake )
{
    QU_ON( user, msg.role_id );

    frd::MakeFriend( user, msg.target_id );
}

MSG_FUNC( PQFriendMakeByName )
{
    QU_ON( user, msg.role_id );

    frd::MakeFriendByName( user, msg.target_name );
}

MSG_FUNC( PQFriendMakeAll )
{
    QU_ON( user, msg.role_id );

    for( std::vector<uint32>::iterator iter = msg.target_id_list.begin();
        iter != msg.target_id_list.end();
        ++iter )
    {
        frd::MakeFriend( user, *iter );
    }
}

MSG_FUNC( PQFriendRequest )
{
    //QU_ON( user, msg.role_id );

    //QU_ON( target, msg.target_id );

    //frd::Request( user, target );
}

MSG_FUNC( PQFriendOK )
{
    QU_ON( user, msg.role_id );

    frd::AddFriend( user, msg.target_id );
}

MSG_FUNC( PQFriendBlack )
{
    QU_ON( user, msg.role_id );

    QU_OFF( target, msg.target_id );

    frd::AddBlack( user, msg.target_id );
}

MSG_FUNC( PQFriendBlackByName )
{
    QU_ON( user, msg.role_id );

    uint32 target_id = theUserDC.find_id( msg.target_name );

    QU_OFF( target, target_id );

    frd::AddBlack( user, target_id );
}

MSG_FUNC( PQFriendUpdate )
{
    QU_ON( user, msg.role_id );

    QU_OFF( target, msg.target_id );

    frd::UpdateFriend( user, msg.target_id, msg.set_type, msg.group );
}

MSG_FUNC( PQFriendMsg )
{
    //QU_ON( user, msg.role_id );

    //QU_ON( target, msg.target_id );

    //frd::SendMsg( user, target, msg.msg );

}

MSG_FUNC( PQSFriendRecommend )
{
    QU_ON( user, msg.role_id );

    frd::Recommend( user );
}

MSG_FUNC( PQFriendGive )
{
    QU_ON( user, msg.role_id );

    QU_OFF( target, msg.friend_id );

    frd::Give( user, target, msg.give_type, msg.active_score, msg.item_list );
}

MSG_FUNC( PQFriendChatContent )
{
    QU_ON( user, msg.role_id );

    if ( user->data.other.chat_ban_endtime > server::local_time() )
    {
        PRReportPostBan rep;
        bccopy( rep, msg );
        local::write( local::access, rep );
        return;
    }

    QU_ON( target, msg.friend_id );

    static int32 debug_mode = settings::json()[ "debug_mode" ].asInt();
    if( debug_mode && command::Parse( user, msg.text ) )
    {
        LOG_ERROR( "Command[%u]:%s", msg.role_id, msg.text.c_str() );
        return;
    }

    uint32 limit_level = theGlobalExt.get<uint32>("friend_system_level_limit");

    std::map< uint32, SUserFriend >::iterator iter = user->data.friend_map.find( msg.friend_id );
    if( iter == user->data.friend_map.end() )
    {
        if( user->data.simple.team_level < limit_level )
            return;

        frd::AddStranger( user, msg.friend_id );
    }

    iter = target->data.friend_map.find( user->guid );

    //黑名单
    if( iter != target->data.friend_map.end() && iter->second.friend_group == kFriendGroupBlack )
        return;

    if( iter == target->data.friend_map.end() )
    {
        if( target->data.simple.team_level >= limit_level )
            frd::AddStranger( target, user->guid );
    }


    PRFriendChatContent rep;
    bccopy( rep, msg );

    rep.target_id   = user->guid;
    rep.avater      = msg.avater;

    rep.broad_cast  = msg.broad_cast;
    rep.broad_type  = msg.broad_type;
    rep.broad_id    = msg.broad_id;

    rep.name = user->data.simple.name;
    rep.level = user->data.simple.team_level;

    rep.text   = msg.text;
    rep.sound  = msg.sound;
    rep.length = msg.length;
    rep.text_ext = msg.text_ext;

    bccopy( rep, target->ext );
    local::write( local::access, rep );
}

