#include "proto/transfrom/transfrom_formation.h"

#include "proto/formation/SUserFormation.h"
#include "proto/formation/PQFormationList.h"
#include "proto/formation/PRFormationList.h"
#include "proto/formation/PQFormationMove.h"
#include "proto/formation/PQFormationSet.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_formation::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 776361237 ] = std::make_pair( "PQFormationList", msg_transfrom< PQFormationList > );
    handles[ 1602266981 ] = std::make_pair( "PRFormationList", msg_transfrom< PRFormationList > );
    handles[ 75458213 ] = std::make_pair( "PQFormationMove", msg_transfrom< PQFormationMove > );
    handles[ 323879387 ] = std::make_pair( "PQFormationSet", msg_transfrom< PQFormationSet > );

    return handles;
}

