#include "proto/transfrom/transfrom_top.h"

#include "proto/top/SUserTop.h"
#include "proto/top/PQTopSave.h"
#include "proto/top/PQTopData.h"
#include "proto/top/PRTopData.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_top::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 195577959 ] = std::make_pair( "PQTopSave", msg_transfrom< PQTopSave > );
    handles[ 766459091 ] = std::make_pair( "PQTopData", msg_transfrom< PQTopData > );
    handles[ 1986846505 ] = std::make_pair( "PRTopData", msg_transfrom< PRTopData > );

    return handles;
}

