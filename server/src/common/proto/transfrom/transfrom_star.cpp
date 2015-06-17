#include "proto/transfrom/transfrom_star.h"

#include "proto/star/SUserStar.h"
#include "proto/star/PRStarData.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_star::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 1096302338 ] = std::make_pair( "PRStarData", msg_transfrom< PRStarData > );

    return handles;
}

