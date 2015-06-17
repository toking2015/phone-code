#include "proto/transfrom/transfrom_strength.h"

#include "proto/strength/PQStrengthBuy.h"
#include "proto/strength/PRStrengthBuy.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_strength::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 1063403861 ] = std::make_pair( "PQStrengthBuy", msg_transfrom< PQStrengthBuy > );
    handles[ 1814060550 ] = std::make_pair( "PRStrengthBuy", msg_transfrom< PRStrengthBuy > );

    return handles;
}

