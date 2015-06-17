#include "proto/transfrom/transfrom_broadcast.h"

#include "proto/broadcast/SUserChannel.h"
#include "proto/broadcast/PQBroadCastList.h"
#include "proto/broadcast/PRBroadCastList.h"
#include "proto/broadcast/PQBroadCastSet.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_broadcast::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 100870329 ] = std::make_pair( "PQBroadCastList", msg_transfrom< PQBroadCastList > );
    handles[ 1558437242 ] = std::make_pair( "PRBroadCastList", msg_transfrom< PRBroadCastList > );
    handles[ 884232017 ] = std::make_pair( "PQBroadCastSet", msg_transfrom< PQBroadCastSet > );

    return handles;
}

