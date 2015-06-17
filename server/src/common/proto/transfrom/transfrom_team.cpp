#include "proto/transfrom/transfrom_team.h"

#include "proto/team/STeamInfo.h"
#include "proto/team/PQTeamLevelUp.h"
#include "proto/team/PRTeamLevelUp.h"
#include "proto/team/PQTeamChangeName.h"
#include "proto/team/PRTeamChangeName.h"
#include "proto/team/PQTeamChangeAvatar.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_team::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 239622908 ] = std::make_pair( "PQTeamLevelUp", msg_transfrom< PQTeamLevelUp > );
    handles[ 1901312684 ] = std::make_pair( "PRTeamLevelUp", msg_transfrom< PRTeamLevelUp > );
    handles[ 57344587 ] = std::make_pair( "PQTeamChangeName", msg_transfrom< PQTeamChangeName > );
    handles[ 1105012732 ] = std::make_pair( "PRTeamChangeName", msg_transfrom< PRTeamChangeName > );
    handles[ 374520175 ] = std::make_pair( "PQTeamChangeAvatar", msg_transfrom< PQTeamChangeAvatar > );

    return handles;
}

