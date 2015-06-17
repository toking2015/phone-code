#include "proto/transfrom/transfrom_server.h"

#include "proto/server/CServer.h"
#include "proto/server/PRServerOpen.h"
#include "proto/server/PRServerClose.h"
#include "proto/server/PQServerNameList.h"
#include "proto/server/PRServerNameList.h"
#include "proto/server/PQServerNotify.h"
#include "proto/server/PQServerInfoList.h"
#include "proto/server/PRServerInfoList.h"
#include "proto/server/PQServerFriendList.h"
#include "proto/server/PRServerFriendList.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_server::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 1555277531 ] = std::make_pair( "PRServerOpen", msg_transfrom< PRServerOpen > );
    handles[ 1985312526 ] = std::make_pair( "PRServerClose", msg_transfrom< PRServerClose > );
    handles[ 328709501 ] = std::make_pair( "PQServerNameList", msg_transfrom< PQServerNameList > );
    handles[ 1696743470 ] = std::make_pair( "PRServerNameList", msg_transfrom< PRServerNameList > );
    handles[ 311682074 ] = std::make_pair( "PQServerNotify", msg_transfrom< PQServerNotify > );
    handles[ 993184889 ] = std::make_pair( "PQServerInfoList", msg_transfrom< PQServerInfoList > );
    handles[ 1430484165 ] = std::make_pair( "PRServerInfoList", msg_transfrom< PRServerInfoList > );
    handles[ 1011284555 ] = std::make_pair( "PQServerFriendList", msg_transfrom< PQServerFriendList > );
    handles[ 1624405534 ] = std::make_pair( "PRServerFriendList", msg_transfrom< PRServerFriendList > );

    return handles;
}

