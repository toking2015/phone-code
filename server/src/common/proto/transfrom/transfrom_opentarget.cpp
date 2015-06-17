#include "proto/transfrom/transfrom_opentarget.h"

#include "proto/opentarget/PQOpenTargetTake.h"
#include "proto/opentarget/PROpenTargetTake.h"
#include "proto/opentarget/PQOpenTargetBuy.h"
#include "proto/opentarget/PROpenTargetBuy.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_opentarget::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 989782867 ] = std::make_pair( "PQOpenTargetTake", msg_transfrom< PQOpenTargetTake > );
    handles[ 1126082129 ] = std::make_pair( "PROpenTargetTake", msg_transfrom< PROpenTargetTake > );
    handles[ 605587023 ] = std::make_pair( "PQOpenTargetBuy", msg_transfrom< PQOpenTargetBuy > );
    handles[ 1092130525 ] = std::make_pair( "PROpenTargetBuy", msg_transfrom< PROpenTargetBuy > );

    return handles;
}

