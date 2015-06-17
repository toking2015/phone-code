#include "proto/transfrom/transfrom_reportpost.h"

#include "proto/reportpost/SReportPostInfo.h"
#include "proto/reportpost/CReportPostMap.h"
#include "proto/reportpost/PQReportPostInfo.h"
#include "proto/reportpost/PRReportPostInfo.h"
#include "proto/reportpost/PQReportPostMake.h"
#include "proto/reportpost/PRReportPostMake.h"
#include "proto/reportpost/PRReportPostBan.h"
#include "proto/reportpost/PQReportPostInfoLoad.h"
#include "proto/reportpost/PRReportPostInfoLoad.h"
#include "proto/reportpost/PQReportPostUpdate.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_reportpost::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 339976699 ] = std::make_pair( "PQReportPostInfo", msg_transfrom< PQReportPostInfo > );
    handles[ 1987315945 ] = std::make_pair( "PRReportPostInfo", msg_transfrom< PRReportPostInfo > );
    handles[ 411962653 ] = std::make_pair( "PQReportPostMake", msg_transfrom< PQReportPostMake > );
    handles[ 1560889071 ] = std::make_pair( "PRReportPostMake", msg_transfrom< PRReportPostMake > );
    handles[ 1913283098 ] = std::make_pair( "PRReportPostBan", msg_transfrom< PRReportPostBan > );
    handles[ 1063669705 ] = std::make_pair( "PQReportPostInfoLoad", msg_transfrom< PQReportPostInfoLoad > );
    handles[ 1596177775 ] = std::make_pair( "PRReportPostInfoLoad", msg_transfrom< PRReportPostInfoLoad > );
    handles[ 217565280 ] = std::make_pair( "PQReportPostUpdate", msg_transfrom< PQReportPostUpdate > );

    return handles;
}

