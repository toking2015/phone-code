#include "proto/transfrom/transfrom_fightextable.h"

#include "proto/fightextable/SFightExtAbleInfo.h"
#include "proto/fightextable/PQFightExtAbleList.h"
#include "proto/fightextable/PRFightExtAbleList.h"
#include "proto/fightextable/PRFightExtAbleSet.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_fightextable::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 1006064479 ] = std::make_pair( "PQFightExtAbleList", msg_transfrom< PQFightExtAbleList > );
    handles[ 1830637631 ] = std::make_pair( "PRFightExtAbleList", msg_transfrom< PRFightExtAbleList > );
    handles[ 1763962368 ] = std::make_pair( "PRFightExtAbleSet", msg_transfrom< PRFightExtAbleSet > );

    return handles;
}

