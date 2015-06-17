#include "proto/transfrom/transfrom_vip.h"

#include "proto/vip/PQVipLevelUp.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_vip::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 599266307 ] = std::make_pair( "PQVipLevelUp", msg_transfrom< PQVipLevelUp > );

    return handles;
}

