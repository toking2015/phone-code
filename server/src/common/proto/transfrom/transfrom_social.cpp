#include "proto/transfrom/transfrom_social.h"

#include "proto/social/SSocialRole.h"
#include "proto/social/CSocial.h"
#include "proto/social/PQSocialServerPing.h"
#include "proto/social/PRSocialServerPing.h"
#include "proto/social/PQSocialServerRoleList.h"
#include "proto/social/PRSocialServerRoleList.h"
#include "proto/social/PQSocialServerBind.h"
#include "proto/social/PQSocialServerRole.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_social::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 513725054 ] = std::make_pair( "PQSocialServerPing", msg_transfrom< PQSocialServerPing > );
    handles[ 1770462687 ] = std::make_pair( "PRSocialServerPing", msg_transfrom< PRSocialServerPing > );
    handles[ 30914989 ] = std::make_pair( "PQSocialServerRoleList", msg_transfrom< PQSocialServerRoleList > );
    handles[ 1129914150 ] = std::make_pair( "PRSocialServerRoleList", msg_transfrom< PRSocialServerRoleList > );
    handles[ 941776562 ] = std::make_pair( "PQSocialServerBind", msg_transfrom< PQSocialServerBind > );
    handles[ 283687696 ] = std::make_pair( "PQSocialServerRole", msg_transfrom< PQSocialServerRole > );

    return handles;
}

