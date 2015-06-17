#include "misc.h"
#include "reportpost_imp.h"
#include "reportpost_dc.h"
#include "proto/reportpost.h"
#include "proto/constant.h"
#include "user_dc.h"
#include "local.h"

MSG_FUNC( PRReportPostInfoLoad )
{
    theReportPostDC.OnLoadData( msg.info_map );
}

MSG_FUNC( PQReportPostMake )
{
    QU_ON( user, msg.role_id );

    QU_OFF( target, msg.target_id );

    reportpost::Report( user, target );
}

