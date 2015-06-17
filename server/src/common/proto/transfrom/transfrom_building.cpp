#include "proto/transfrom/transfrom_building.h"

#include "proto/building/SBuildingBase.h"
#include "proto/building/SBuildingExt.h"
#include "proto/building/SUserBuilding.h"
#include "proto/building/PQBuildingList.h"
#include "proto/building/PQBuildingAdd.h"
#include "proto/building/PQBuildingUpgrade.h"
#include "proto/building/PQBuildingMove.h"
#include "proto/building/PQBuildingQuery.h"
#include "proto/building/PQBuildingGetOutput.h"
#include "proto/building/PQBuildingSpeedOutput.h"
#include "proto/building/PRBuildingList.h"
#include "proto/building/PRBuildingSet.h"
#include "proto/building/PRBuildingQuery.h"
#include "proto/building/PRBuildingSpeedOutput.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_building::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 600622277 ] = std::make_pair( "PQBuildingList", msg_transfrom< PQBuildingList > );
    handles[ 462722994 ] = std::make_pair( "PQBuildingAdd", msg_transfrom< PQBuildingAdd > );
    handles[ 600117215 ] = std::make_pair( "PQBuildingUpgrade", msg_transfrom< PQBuildingUpgrade > );
    handles[ 346561621 ] = std::make_pair( "PQBuildingMove", msg_transfrom< PQBuildingMove > );
    handles[ 989836134 ] = std::make_pair( "PQBuildingQuery", msg_transfrom< PQBuildingQuery > );
    handles[ 493876112 ] = std::make_pair( "PQBuildingGetOutput", msg_transfrom< PQBuildingGetOutput > );
    handles[ 549718019 ] = std::make_pair( "PQBuildingSpeedOutput", msg_transfrom< PQBuildingSpeedOutput > );
    handles[ 1774802370 ] = std::make_pair( "PRBuildingList", msg_transfrom< PRBuildingList > );
    handles[ 1484773370 ] = std::make_pair( "PRBuildingSet", msg_transfrom< PRBuildingSet > );
    handles[ 1318423735 ] = std::make_pair( "PRBuildingQuery", msg_transfrom< PRBuildingQuery > );
    handles[ 1539609863 ] = std::make_pair( "PRBuildingSpeedOutput", msg_transfrom< PRBuildingSpeedOutput > );

    return handles;
}

