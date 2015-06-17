#include "proto/transfrom/transfrom_var.h"

#include "proto/var/SUserVar.h"
#include "proto/var/PQVarMap.h"
#include "proto/var/PRVarMap.h"
#include "proto/var/PQVarSet.h"
#include "proto/var/PRVarSet.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_var::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 308805923 ] = std::make_pair( "PQVarMap", msg_transfrom< PQVarMap > );
    handles[ 1399214952 ] = std::make_pair( "PRVarMap", msg_transfrom< PRVarMap > );
    handles[ 280247880 ] = std::make_pair( "PQVarSet", msg_transfrom< PQVarSet > );
    handles[ 1608044845 ] = std::make_pair( "PRVarSet", msg_transfrom< PRVarSet > );

    return handles;
}

