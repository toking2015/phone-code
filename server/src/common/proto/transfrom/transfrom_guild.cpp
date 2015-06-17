#include "proto/transfrom/transfrom_guild.h"

#include "proto/guild/SGuildSimple.h"
#include "proto/guild/SGuildLog.h"
#include "proto/guild/SGuildInfo.h"
#include "proto/guild/SGuildProtect.h"
#include "proto/guild/SGuildPanel.h"
#include "proto/guild/SGuildMember.h"
#include "proto/guild/SGuildData.h"
#include "proto/guild/SGuildExt.h"
#include "proto/guild/SGuild.h"
#include "proto/guild/CGuildMap.h"
#include "proto/guild/PQGuildSimple.h"
#include "proto/guild/PRGuildSimple.h"
#include "proto/guild/PQGuildPanel.h"
#include "proto/guild/PRGuildPanel.h"
#include "proto/guild/PQGuildMemberList.h"
#include "proto/guild/PRGuildMemberList.h"
#include "proto/guild/PQGuildList.h"
#include "proto/guild/PRGuildList.h"
#include "proto/guild/PQGuildSimpleList.h"
#include "proto/guild/PRGuildSimpleList.h"
#include "proto/guild/PQGuildCreate.h"
#include "proto/guild/PRGuildCreate.h"
#include "proto/guild/PQGuildInvite.h"
#include "proto/guild/PQGuildApply.h"
#include "proto/guild/PRGuildApplySet.h"
#include "proto/guild/PRGuildApply.h"
#include "proto/guild/PQGuildApprove.h"
#include "proto/guild/PQGuildQuit.h"
#include "proto/guild/PQGuildKick.h"
#include "proto/guild/PQGuildSetJob.h"
#include "proto/guild/PRGuildMemberSet.h"
#include "proto/guild/PQGuildContribute.h"
#include "proto/guild/PQGuildLevelup.h"
#include "proto/guild/PRGuildLevel.h"
#include "proto/guild/PQGuildPost.h"
#include "proto/guild/PRGuildPost.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_guild::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 285286939 ] = std::make_pair( "PQGuildSimple", msg_transfrom< PQGuildSimple > );
    handles[ 1548333934 ] = std::make_pair( "PRGuildSimple", msg_transfrom< PRGuildSimple > );
    handles[ 886617734 ] = std::make_pair( "PQGuildPanel", msg_transfrom< PQGuildPanel > );
    handles[ 1350056808 ] = std::make_pair( "PRGuildPanel", msg_transfrom< PRGuildPanel > );
    handles[ 761414498 ] = std::make_pair( "PQGuildMemberList", msg_transfrom< PQGuildMemberList > );
    handles[ 1797061462 ] = std::make_pair( "PRGuildMemberList", msg_transfrom< PRGuildMemberList > );
    handles[ 660873787 ] = std::make_pair( "PQGuildList", msg_transfrom< PQGuildList > );
    handles[ 1358762892 ] = std::make_pair( "PRGuildList", msg_transfrom< PRGuildList > );
    handles[ 433483323 ] = std::make_pair( "PQGuildSimpleList", msg_transfrom< PQGuildSimpleList > );
    handles[ 1305794030 ] = std::make_pair( "PRGuildSimpleList", msg_transfrom< PRGuildSimpleList > );
    handles[ 217782399 ] = std::make_pair( "PQGuildCreate", msg_transfrom< PQGuildCreate > );
    handles[ 1833501751 ] = std::make_pair( "PRGuildCreate", msg_transfrom< PRGuildCreate > );
    handles[ 785871036 ] = std::make_pair( "PQGuildInvite", msg_transfrom< PQGuildInvite > );
    handles[ 747175929 ] = std::make_pair( "PQGuildApply", msg_transfrom< PQGuildApply > );
    handles[ 1471431520 ] = std::make_pair( "PRGuildApplySet", msg_transfrom< PRGuildApplySet > );
    handles[ 1972373836 ] = std::make_pair( "PRGuildApply", msg_transfrom< PRGuildApply > );
    handles[ 148826004 ] = std::make_pair( "PQGuildApprove", msg_transfrom< PQGuildApprove > );
    handles[ 128922739 ] = std::make_pair( "PQGuildQuit", msg_transfrom< PQGuildQuit > );
    handles[ 271473681 ] = std::make_pair( "PQGuildKick", msg_transfrom< PQGuildKick > );
    handles[ 992226334 ] = std::make_pair( "PQGuildSetJob", msg_transfrom< PQGuildSetJob > );
    handles[ 1816172323 ] = std::make_pair( "PRGuildMemberSet", msg_transfrom< PRGuildMemberSet > );
    handles[ 886345701 ] = std::make_pair( "PQGuildContribute", msg_transfrom< PQGuildContribute > );
    handles[ 253962101 ] = std::make_pair( "PQGuildLevelup", msg_transfrom< PQGuildLevelup > );
    handles[ 1322202085 ] = std::make_pair( "PRGuildLevel", msg_transfrom< PRGuildLevel > );
    handles[ 573031854 ] = std::make_pair( "PQGuildPost", msg_transfrom< PQGuildPost > );
    handles[ 1300943509 ] = std::make_pair( "PRGuildPost", msg_transfrom< PRGuildPost > );

    return handles;
}

