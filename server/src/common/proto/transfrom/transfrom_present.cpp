#include "proto/transfrom/transfrom_present.h"

#include "proto/present/PQPresentGlobalTake.h"
#include "proto/present/PRPresentGlobalTake.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_present::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 244129486 ] = std::make_pair( "PQPresentGlobalTake", msg_transfrom< PQPresentGlobalTake > );
    handles[ 1336200323 ] = std::make_pair( "PRPresentGlobalTake", msg_transfrom< PRPresentGlobalTake > );

    return handles;
}

