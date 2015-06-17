#include "proto/transfrom/transfrom_tomb.h"

#include "proto/tomb/STombTarget.h"
#include "proto/tomb/SUserKillInfo.h"
#include "proto/tomb/SUserTomb.h"
#include "proto/tomb/PQTombFight.h"
#include "proto/tomb/PQTombRewardGet.h"
#include "proto/tomb/PRTombRewardGet.h"
#include "proto/tomb/PQTombPlayerReset.h"
#include "proto/tomb/PRTombPlayerReset.h"
#include "proto/tomb/PQTombReset.h"
#include "proto/tomb/PRTombReset.h"
#include "proto/tomb/PQTombMopUp.h"
#include "proto/tomb/PRTombMopUp.h"
#include "proto/tomb/PQTombInfo.h"
#include "proto/tomb/PRTombInfo.h"
#include "proto/tomb/PQTombTargetList.h"
#include "proto/tomb/PRTombTargetList.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_tomb::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 934860173 ] = std::make_pair( "PQTombFight", msg_transfrom< PQTombFight > );
    handles[ 1060724092 ] = std::make_pair( "PQTombRewardGet", msg_transfrom< PQTombRewardGet > );
    handles[ 1318917084 ] = std::make_pair( "PRTombRewardGet", msg_transfrom< PRTombRewardGet > );
    handles[ 663519283 ] = std::make_pair( "PQTombPlayerReset", msg_transfrom< PQTombPlayerReset > );
    handles[ 1853519620 ] = std::make_pair( "PRTombPlayerReset", msg_transfrom< PRTombPlayerReset > );
    handles[ 45751435 ] = std::make_pair( "PQTombReset", msg_transfrom< PQTombReset > );
    handles[ 1929444106 ] = std::make_pair( "PRTombReset", msg_transfrom< PRTombReset > );
    handles[ 122187354 ] = std::make_pair( "PQTombMopUp", msg_transfrom< PQTombMopUp > );
    handles[ 1828509994 ] = std::make_pair( "PRTombMopUp", msg_transfrom< PRTombMopUp > );
    handles[ 141353931 ] = std::make_pair( "PQTombInfo", msg_transfrom< PQTombInfo > );
    handles[ 1945453920 ] = std::make_pair( "PRTombInfo", msg_transfrom< PRTombInfo > );
    handles[ 300678455 ] = std::make_pair( "PQTombTargetList", msg_transfrom< PQTombTargetList > );
    handles[ 1420666319 ] = std::make_pair( "PRTombTargetList", msg_transfrom< PRTombTargetList > );

    return handles;
}

