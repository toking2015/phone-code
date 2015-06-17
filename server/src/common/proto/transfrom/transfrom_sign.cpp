#include "proto/transfrom/transfrom_sign.h"

#include "proto/sign/SSign.h"
#include "proto/sign/SSignInfo.h"
#include "proto/sign/PQSignInfo.h"
#include "proto/sign/PRSignInfo.h"
#include "proto/sign/PQSign.h"
#include "proto/sign/PRSign.h"
#include "proto/sign/PQTakeSignSumReward.h"
#include "proto/sign/PRTakeSignSumReward.h"
#include "proto/sign/PQTakeHaohuaReward.h"
#include "proto/sign/PRTakeHaohuaReward.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_sign::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 35064835 ] = std::make_pair( "PQSignInfo", msg_transfrom< PQSignInfo > );
    handles[ 1494253166 ] = std::make_pair( "PRSignInfo", msg_transfrom< PRSignInfo > );
    handles[ 1005883788 ] = std::make_pair( "PQSign", msg_transfrom< PQSign > );
    handles[ 1149402159 ] = std::make_pair( "PRSign", msg_transfrom< PRSign > );
    handles[ 664307434 ] = std::make_pair( "PQTakeSignSumReward", msg_transfrom< PQTakeSignSumReward > );
    handles[ 1148020005 ] = std::make_pair( "PRTakeSignSumReward", msg_transfrom< PRTakeSignSumReward > );
    handles[ 977425689 ] = std::make_pair( "PQTakeHaohuaReward", msg_transfrom< PQTakeHaohuaReward > );
    handles[ 2024857271 ] = std::make_pair( "PRTakeHaohuaReward", msg_transfrom< PRTakeHaohuaReward > );

    return handles;
}

