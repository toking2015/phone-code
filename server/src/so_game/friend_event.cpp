#include "event.h"
#include "team_event.h"
#include "user_event.h"
#include "friend_dc.h"
#include "resource/r_globalext.h"

EVENT_FUNC( frd, SEventTeamLevelUp )
{
    if( ev.user->data.simple.team_level >= theGlobalExt.get<uint32>("friend_system_level_limit") )
    {
        SFriendData* p_data = theFriendDC.FindFriendData( ev.user->guid );
        if( NULL == p_data )
        {
            SFriendData s_data;
            s_data.target_id        = ev.user->guid;
            s_data.target_avatar    = ev.user->data.simple.avatar;
            s_data.target_level     = ev.user->data.simple.team_level;
            s_data.target_name      = ev.user->data.simple.name;

            theFriendDC.SetFriendData( s_data.target_id, s_data );
        }
    }
}

EVENT_FUNC( frd, SEventUserLogined )
{
    if( ev.user->data.simple.team_level >= theGlobalExt.get<uint32>("friend_system_level_limit") )
    {
        SFriendData* p_data = theFriendDC.FindFriendData( ev.user->guid );
        if( NULL == p_data )
        {
            SFriendData s_data;
            s_data.target_id        = ev.user->guid;
            s_data.target_avatar    = ev.user->data.simple.avatar;
            s_data.target_level     = ev.user->data.simple.team_level;
            s_data.target_name      = ev.user->data.simple.name;

            theFriendDC.SetFriendData( s_data.target_id, s_data );
        }
    }

}

