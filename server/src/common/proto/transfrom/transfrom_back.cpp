#include "proto/transfrom/transfrom_back.h"

#include "proto/back/PQBackLog.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_back::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 883558710 ] = std::make_pair( "PQBackLog", msg_transfrom< PQBackLog > );

    return handles;
}

