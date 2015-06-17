#include "proto/transfrom/transfrom_access.h"

#include "proto/access/PQAccessEvent.h"
#include "proto/access/PQAccessBroadCastList.h"
#include "proto/access/PRAccessBroadCasetList.h"
#include "proto/access/PQAccessBroadCastSet.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_access::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 1001173331 ] = std::make_pair( "PQAccessEvent", msg_transfrom< PQAccessEvent > );
    handles[ 102430714 ] = std::make_pair( "PQAccessBroadCastList", msg_transfrom< PQAccessBroadCastList > );
    handles[ 1700262094 ] = std::make_pair( "PRAccessBroadCasetList", msg_transfrom< PRAccessBroadCasetList > );
    handles[ 195628525 ] = std::make_pair( "PQAccessBroadCastSet", msg_transfrom< PQAccessBroadCastSet > );

    return handles;
}

