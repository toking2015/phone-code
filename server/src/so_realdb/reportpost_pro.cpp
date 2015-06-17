#include "reportpost_imp.h"
#include "proto/reportpost.h"
#include "misc.h"
#include "local.h"


MSG_FUNC( PQReportPostUpdate )
{
    reportpost::UpdateData( msg.set_type, msg.target_id, msg.report_id, msg.report_time );
}

MSG_FUNC( PQReportPostInfoLoad )
{
    reportpost::LoadData();
}

