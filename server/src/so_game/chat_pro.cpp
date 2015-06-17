#include "misc.h"
#include "proto/chat.h"
#include "proto/broadcast.h"
#include "proto/reportpost.h"
#include "local.h"
#include "server.h"
#include "user_dc.h"
#include "command_imp.h"
#include "settings.h"
#include "log.h"
#include "resource/r_globalext.h"
#include "var_imp.h"
#include "chat_imp.h"
#include "chat_event.h"
#include "totem_imp.h"
#include "equip_imp.h"
#include "soldier_imp.h"
#include "fightextable_imp.h"
#include "proto/constant.h"

MSG_FUNC( PQChatContent )
{
    QU_ON( user, msg.role_id );

    uint32 time_now = server::local_time();

    if ( user->data.other.chat_ban_endtime > time_now )
    {
        PRReportPostBan rep;
        bccopy( rep, msg );
        local::write( local::access, rep );
        return;
    }

    //检查
    switch ( msg.broad_cast )
    {
    case kCastUni:
        break;
    case kCastServer:
        {
            //世界频道15秒发一次
            uint32 time_limit = theGlobalExt.get<uint32>("chat_server_time_limit");
            uint32 get_time = var::get( user, "chat_server_time_limit");

            if( time_now < time_limit + get_time )
                return;

            //更新最新发言时间
            var::set( user, "chat_server_time_limit", time_now );

        }
        break;
    case kCastGuild:
        break;
    }

    int32 debug_mode = settings::json()[ "debug_mode" ].asInt();
    if( debug_mode && command::Parse( user, msg.text ) )
    {
        LOG_ERROR( "Command[%u]:%s", msg.role_id, msg.text.c_str() );
        return;
    }


    PRChatContent rep;
    bccopy( rep, msg );

    rep.broad_cast = msg.broad_cast;
    rep.broad_type = msg.broad_type;
    rep.broad_id = msg.broad_id;

    rep.name = user->data.simple.name;
    rep.level = user->data.simple.team_level;

    rep.avater = msg.avater;
    rep.text = msg.text;
    rep.text_ext = msg.text_ext;

    rep.sound_length = msg.sound_length;
    rep.sound_index = msg.sound_index;
    if ( rep.sound_index > 0 )
    {
        chat::cache_sound( msg.role_id, msg.sound_index, msg.sound_data );
    }

    local::write( local::access, rep );

    event::dispatch( SEventChat( user, msg.text, msg.broad_cast, msg.broad_type, msg.broad_id ) );
}

MSG_FUNC( PQChatSound )
{
    QU_ON( user, msg.role_id );

    PRChatSound rep;
    bccopy( rep, msg );

    rep.target_id   = msg.target_id;
    rep.sound_index = msg.sound_index;

    wd::CStream* bytes = chat::find_sound( msg.target_id, msg.sound_index );
    if ( bytes == NULL )
        rep.result = kErrChatSoundNotExist;
    else
        rep.sound_data  = *bytes;

    local::write( local::access, rep );
}

MSG_FUNC( PQChatBan )
{
    QU_OFF( user, msg.role_id );

    user->data.other.chat_ban_endtime = msg.end_time;
}

MSG_FUNC( PQChatGetTotem )
{
    QU_ON( user, msg.role_id );
    QU_OFF( target, msg.target_id );

    STotem  data;
    if( totem::GetTotem( target, msg.totem_guid, data ) )
    {
        PRChatGetTotem rep;
        bccopy( rep, msg );

        rep.target_id   = msg.target_id;
        rep.totem_data  = data;
        local::write( local::access, rep );
    }
}


MSG_FUNC( PQChatGetSoldier )
{
    QU_ON( user, msg.role_id );
    QU_OFF( target, msg.target_id );

    SUserSoldier    data;
    if( soldier::GetSoldier( target, msg.soldier_guid, data ) )
    {
        SFightExtAble   ext_able;

        if( fightextable::GetFightExtAble( target, msg.soldier_guid, kAttrSoldier, ext_able ) )
        {

            PRChatGetSoldier rep;
            bccopy( rep, msg );

            rep.target_id       = msg.target_id;
            rep.soldier_data    = data;
            rep.ext_able        = ext_able;
            local::write( local::access, rep );
        }
    }
}

MSG_FUNC( PQChatGetEquip )
{
    QU_ON( user, msg.role_id );
    QU_OFF( target, msg.target_id );

    std::vector<SUserItem> list;
    equip::GetEquipSuit( target, msg.equip_type, msg.equip_level, list );
    PRChatGetEquip rep;
    bccopy( rep, msg );

    rep.target_id   = msg.target_id;
    rep.equip_type  = msg.equip_type;
    rep.equip_level = msg.equip_level;
    rep.item_list   = list;
    local::write( local::access, rep );
}

