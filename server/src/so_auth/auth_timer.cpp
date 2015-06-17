#include "timer.h"
#include "call_imp.h"
#include "local.h"
#include "proto/constant.h"
#include "proto/auth.h"
#include "auth_dc.h"
#include "back_imp.h"
#include "util.h"
#include "output.h"

TIMER( auth_outside_run_time )
{
    CJson json = CJson::LoadString( param );

    uint32 guid = to_uint( json[ "runtime_guid" ] );

    std::map< uint32, SAuthRunData >::iterator iter = theAuthDC.db().loop_map.find( guid );
    if ( !theSysTimeMgr.Valid( iter->second.loop_id ) )
    {
        theAuthDC.db().loop_map.erase( iter );

        PQAuthRunTimeSet req;

        req.set_type = kObjectDel;
        req.run_time.guid = guid;

        local::write( local::realdb, req );
    }

    json::RunCall( 0, param );
}

SO_LOAD( _auth_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "auth_online_time_log",
        "",
        "23:59:59",
        NULL,
        CSysTimeMgr::Day,
        1,
        0
    );
}
TIMER( auth_online_time_log )
{
    int32 file = output::open( "online_time.txt", time_sec );

    //记录当天在线用户的使用时长
    for ( std::map< uint32, uint32 >::iterator iter = theAuthDC.db().online_data.begin();
        iter != theAuthDC.db().online_data.end();
        ++iter )
    {
        std::string text = strprintf( "%u\t%u\n", iter->first, iter->second );
        write( file, text.c_str(), text.size() );
    }

    //清空数据
    theAuthDC.db().online_data.clear();
}

