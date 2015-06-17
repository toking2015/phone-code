#include "proto/transfrom/transfrom_notify.h"

#include "proto/notify/PRNotifyCoin.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_notify::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 1746730510 ] = std::make_pair( "PRNotifyCoin", msg_transfrom< PRNotifyCoin > );

    return handles;
}

