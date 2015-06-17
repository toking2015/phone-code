#include "proto/transfrom/transfrom_gut.h"

#include "proto/gut/SGutInfo.h"
#include "proto/gut/PQGutInfo.h"
#include "proto/gut/PRGutInfo.h"
#include "proto/gut/PQGutCommitEvent.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_gut::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 364170231 ] = std::make_pair( "PQGutInfo", msg_transfrom< PQGutInfo > );
    handles[ 1993357244 ] = std::make_pair( "PRGutInfo", msg_transfrom< PRGutInfo > );
    handles[ 813604863 ] = std::make_pair( "PQGutCommitEvent", msg_transfrom< PQGutCommitEvent > );

    return handles;
}

