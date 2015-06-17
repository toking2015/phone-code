#include "link_event.h"
#include "user_event.h"
#include "proto/reportpost.h"
#include "local.h"
#include "reportpost_dc.h"
#include "reportpost_imp.h"

EVENT_FUNC( reportpost, SEventNetRealDB )
{
    theReportPostDC.clear_all();
    //发送数据加载请求
    PQReportPostInfoLoad msg;
    local::write( local::realdb, msg );
}

EVENT_FUNC( reportpost, SEventUserLoaded )
{
    reportpost::UserLoaded( ev.user );
}

EVENT_FUNC( reportpost, SEventUserTimeLimit )
{
    reportpost::TimeLimit( ev.user );
}

