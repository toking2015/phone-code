#include "timer.h"
#include "user_dc.h"
#include "server.h"
#include "back_imp.h"
#include "util.h"

SO_LOAD( back_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "back_onlines_timer",
        "",
        "00:00:00",
        NULL,
        CSysTimeMgr::Minute,
        1,
        0
    );
}

TIMER( back_onlines_timer )
{
    uint32 count = 0;
    std::map< std::string, uint32 > platform_count;
    for ( std::map< uint32, SUser >::iterator iter = theUserDC.db().user_map.begin();
        iter != theUserDC.db().user_map.end();
        ++iter )
    {
        SUser* user = &iter->second;

        //10分钟内有操作算在线
        if ( user->ext.operate_time > time_sec - 60 * 3 )
        {
            ++count;

            platform_count[ user->data.simple.platform ]++;
        }
    }

    //每5分钟写入一次 onlines.txt
    if ( time_sec % 300 == 0 )
        back::write( "onlines.txt", "%u\t%s", count, time2str( ( time_sec / 300 ) * 300 ).c_str() );

    //每分钟写入一次 platform_onlines.txt
    for ( std::map< std::string, uint32 >::iterator iter = platform_count.begin();
        iter != platform_count.end();
        ++iter )
    {
        back::write( "platform_onlines.txt", "%u\t%s\t%s",
            iter->second, time2str( ( time_sec / 60 ) * 60 ).c_str(), iter->first.c_str() );
    }
}

