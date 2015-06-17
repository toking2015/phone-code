#include "user_event.h"
#include "var_imp.h"
#include "name_imp.h"
#include "user_dc.h"
#include "util.h"
#include "misc.h"
#include "local.h"
#include "server.h"
#include "soldier_imp.h"
#include "resource/r_globalext.h"

EVENT_FUNC( user, SEventUserInit )
{
    std::string name;
    uint32 target_id = 0;

    //3次随机, 如有冲突即加 id 号
    for ( int32 i = 0; i < 3; ++i )
    {
        name = name::random_name();

        target_id = theUserDC.find_id( name );

        if ( target_id == 0 )
            break;
    }

    if ( target_id != 0 )
        name = strprintf( "%s-%u", name.c_str(), ev.user->guid );

    ev.user->data.simple.name = name;
    ev.user->data.simple.team_level = 1;

    uint32 soldier_id = theGlobalExt.get<uint32>("first_load_soldier_id");
    soldier::Add( ev.user, soldier_id, ev.path );

    theUserDC.db().user_name_id[ name ] = ev.user->guid;
    theUserDC.db().user_id_name[ ev.user->guid ] = name;
}

EVENT_FUNC( user, SEventUserLoaded )
{
    SUser* user = ev.user;

    uint32 user_time_limit = var::get( user, "user_time_limit" );
    uint32 local_6_time = server::local_6_time(0);

    if ( user_time_limit < local_6_time )
    {
        //连续登录
        if (local_6_time - user_time_limit > 86400)
        {
            var::set( user, "login_continuous_day", 1 );
        }
        else
        {
            uint32 day = var::get( user, "login_continuous_day" );
            var::set( user, "login_continuous_day", day + 1 );
        }

        var::set( user, "user_time_limit", local_6_time );

        event::dispatch( SEventUserTimeLimit( user, kPathUserEveryDay ) );

        //发送时间截协议
        PRUserTimeLimit rep;
        bccopy( rep, user->ext );

        local::write( local::access, rep );
    }
}

EVENT_FUNC( user, SEventUserTimeLimit )
{
    SUser* user = ev.user;

    uint32 user_time_limit = var::get( user, "user_time_limit" );
    uint32 local_6_time = server::local_6_time(0);

    if ( user_time_limit < local_6_time )
    {
        //连续登录
        if (local_6_time - user_time_limit > 86400)
        {
            var::set( user, "login_continuous_day", 1 );
        }
        else
        {
            uint32 day = var::get( user, "login_continuous_day" );
            var::set( user, "login_continuous_day", day + 1 );
        }

        var::set( user, "user_time_limit", local_6_time );

    }
}

EVENT_FUNC( user, SEventUserSave )
{
    if ( ev.saved )
        theUserDC.save_file( ev.user->guid, ev.user->data );
}

