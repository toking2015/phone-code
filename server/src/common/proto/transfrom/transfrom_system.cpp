#include "proto/transfrom/transfrom_system.h"

#include "proto/system/CSystem.h"
#include "proto/system/PQSystemTest.h"
#include "proto/system/PRSystemTest.h"
#include "proto/system/PQSystemPing.h"
#include "proto/system/PRSystemPing.h"
#include "proto/system/PQSystemOnline.h"
#include "proto/system/PQSystemResend.h"
#include "proto/system/PRSystemResend.h"
#include "proto/system/PRSystemNetConnected.h"
#include "proto/system/PRSystemNetDisconnected.h"
#include "proto/system/PQSystemSessionCheck.h"
#include "proto/system/PRSystemSessionCheck.h"
#include "proto/system/PQSystemAuth.h"
#include "proto/system/PRSystemAuth.h"
#include "proto/system/PQSystemLogin.h"
#include "proto/system/PRSystemLogin.h"
#include "proto/system/PRSystemUserLoad.h"
#include "proto/system/PRSystemGuildLoad.h"
#include "proto/system/PRSystemUserUpdateSession.h"
#include "proto/system/PRSystemErrCode.h"
#include "proto/system/PQSystemOrder.h"
#include "proto/system/PRSystemOrder.h"
#include "proto/system/PQSystemKick.h"
#include "proto/system/PRSystemKick.h"
#include "proto/system/PQSystemPlacard.h"
#include "proto/system/PRSystemPlacard.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_system::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 62312086 ] = std::make_pair( "PQSystemTest", msg_transfrom< PQSystemTest > );
    handles[ 2094876465 ] = std::make_pair( "PRSystemTest", msg_transfrom< PRSystemTest > );
    handles[ 660488974 ] = std::make_pair( "PQSystemPing", msg_transfrom< PQSystemPing > );
    handles[ 1271524422 ] = std::make_pair( "PRSystemPing", msg_transfrom< PRSystemPing > );
    handles[ 374822355 ] = std::make_pair( "PQSystemOnline", msg_transfrom< PQSystemOnline > );
    handles[ 513134002 ] = std::make_pair( "PQSystemResend", msg_transfrom< PQSystemResend > );
    handles[ 1554760060 ] = std::make_pair( "PRSystemResend", msg_transfrom< PRSystemResend > );
    handles[ 1761556093 ] = std::make_pair( "PRSystemNetConnected", msg_transfrom< PRSystemNetConnected > );
    handles[ 1462459954 ] = std::make_pair( "PRSystemNetDisconnected", msg_transfrom< PRSystemNetDisconnected > );
    handles[ 788199199 ] = std::make_pair( "PQSystemSessionCheck", msg_transfrom< PQSystemSessionCheck > );
    handles[ 1098350912 ] = std::make_pair( "PRSystemSessionCheck", msg_transfrom< PRSystemSessionCheck > );
    handles[ 143043716 ] = std::make_pair( "PQSystemAuth", msg_transfrom< PQSystemAuth > );
    handles[ 1935943368 ] = std::make_pair( "PRSystemAuth", msg_transfrom< PRSystemAuth > );
    handles[ 27628880 ] = std::make_pair( "PQSystemLogin", msg_transfrom< PQSystemLogin > );
    handles[ 2063899790 ] = std::make_pair( "PRSystemLogin", msg_transfrom< PRSystemLogin > );
    handles[ 1461797166 ] = std::make_pair( "PRSystemUserLoad", msg_transfrom< PRSystemUserLoad > );
    handles[ 1175337528 ] = std::make_pair( "PRSystemGuildLoad", msg_transfrom< PRSystemGuildLoad > );
    handles[ 1340090719 ] = std::make_pair( "PRSystemUserUpdateSession", msg_transfrom< PRSystemUserUpdateSession > );
    handles[ 1465167678 ] = std::make_pair( "PRSystemErrCode", msg_transfrom< PRSystemErrCode > );
    handles[ 123883356 ] = std::make_pair( "PQSystemOrder", msg_transfrom< PQSystemOrder > );
    handles[ 1801311003 ] = std::make_pair( "PRSystemOrder", msg_transfrom< PRSystemOrder > );
    handles[ 14859210 ] = std::make_pair( "PQSystemKick", msg_transfrom< PQSystemKick > );
    handles[ 1542389995 ] = std::make_pair( "PRSystemKick", msg_transfrom< PRSystemKick > );
    handles[ 394623921 ] = std::make_pair( "PQSystemPlacard", msg_transfrom< PQSystemPlacard > );
    handles[ 1396856249 ] = std::make_pair( "PRSystemPlacard", msg_transfrom< PRSystemPlacard > );

    return handles;
}

