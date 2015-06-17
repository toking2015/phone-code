#include "proto/transfrom/transfrom_singlearena.h"

#include "proto/singlearena/SSingleArenaOpponent.h"
#include "proto/singlearena/SSingleArenaLog.h"
#include "proto/singlearena/SSingleArenaInfo.h"
#include "proto/singlearena/CSingleArenaMap.h"
#include "proto/singlearena/PQSingleArenaInfo.h"
#include "proto/singlearena/PRSingleArenaInfo.h"
#include "proto/singlearena/PQSingleArenaRefresh.h"
#include "proto/singlearena/PRSingleArenaRefresh.h"
#include "proto/singlearena/PQSingleArenaReplyCD.h"
#include "proto/singlearena/PRSingleArenaReplyCD.h"
#include "proto/singlearena/PQSingleArenaClearCD.h"
#include "proto/singlearena/PRSingleArenaClearCD.h"
#include "proto/singlearena/PQSingleArenaAddTimes.h"
#include "proto/singlearena/PRSingleArenaAddTimes.h"
#include "proto/singlearena/PQSingleArenaLog.h"
#include "proto/singlearena/PRSingleArenaLog.h"
#include "proto/singlearena/PQSingleArenaRank.h"
#include "proto/singlearena/PRSingleArenaRank.h"
#include "proto/singlearena/PRSingleBattleReply.h"
#include "proto/singlearena/PQSingleArenaMyRank.h"
#include "proto/singlearena/PRSingleArenaMyRank.h"
#include "proto/singlearena/PRSingleArenaBattleed.h"
#include "proto/singlearena/PRSingleArenaBattleEnd.h"
#include "proto/singlearena/PQUserSingleArenaPre.h"
#include "proto/singlearena/PRUserSingleArenaPre.h"
#include "proto/singlearena/PRSingleArenaCheck.h"
#include "proto/singlearena/PQSingleArenaSave.h"
#include "proto/singlearena/PQSingleArenaRankLoad.h"
#include "proto/singlearena/PRSingleArenaRankLoad.h"
#include "proto/singlearena/PQSingleArenaLogLoad.h"
#include "proto/singlearena/PRSingleArenaLogLoad.h"
#include "proto/singlearena/PQSingleArenaLogSave.h"
#include "proto/singlearena/PQSingleArenaGetFirstReward.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_singlearena::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 355315651 ] = std::make_pair( "PQSingleArenaInfo", msg_transfrom< PQSingleArenaInfo > );
    handles[ 1421308713 ] = std::make_pair( "PRSingleArenaInfo", msg_transfrom< PRSingleArenaInfo > );
    handles[ 616762807 ] = std::make_pair( "PQSingleArenaRefresh", msg_transfrom< PQSingleArenaRefresh > );
    handles[ 1936653648 ] = std::make_pair( "PRSingleArenaRefresh", msg_transfrom< PRSingleArenaRefresh > );
    handles[ 956089270 ] = std::make_pair( "PQSingleArenaReplyCD", msg_transfrom< PQSingleArenaReplyCD > );
    handles[ 1609156980 ] = std::make_pair( "PRSingleArenaReplyCD", msg_transfrom< PRSingleArenaReplyCD > );
    handles[ 2781945 ] = std::make_pair( "PQSingleArenaClearCD", msg_transfrom< PQSingleArenaClearCD > );
    handles[ 2133531346 ] = std::make_pair( "PRSingleArenaClearCD", msg_transfrom< PRSingleArenaClearCD > );
    handles[ 461113896 ] = std::make_pair( "PQSingleArenaAddTimes", msg_transfrom< PQSingleArenaAddTimes > );
    handles[ 1896427484 ] = std::make_pair( "PRSingleArenaAddTimes", msg_transfrom< PRSingleArenaAddTimes > );
    handles[ 506821747 ] = std::make_pair( "PQSingleArenaLog", msg_transfrom< PQSingleArenaLog > );
    handles[ 1355019612 ] = std::make_pair( "PRSingleArenaLog", msg_transfrom< PRSingleArenaLog > );
    handles[ 133216982 ] = std::make_pair( "PQSingleArenaRank", msg_transfrom< PQSingleArenaRank > );
    handles[ 1158409725 ] = std::make_pair( "PRSingleArenaRank", msg_transfrom< PRSingleArenaRank > );
    handles[ 1876563788 ] = std::make_pair( "PRSingleBattleReply", msg_transfrom< PRSingleBattleReply > );
    handles[ 309320719 ] = std::make_pair( "PQSingleArenaMyRank", msg_transfrom< PQSingleArenaMyRank > );
    handles[ 1122082782 ] = std::make_pair( "PRSingleArenaMyRank", msg_transfrom< PRSingleArenaMyRank > );
    handles[ 2093837737 ] = std::make_pair( "PRSingleArenaBattleed", msg_transfrom< PRSingleArenaBattleed > );
    handles[ 1539999730 ] = std::make_pair( "PRSingleArenaBattleEnd", msg_transfrom< PRSingleArenaBattleEnd > );
    handles[ 595760048 ] = std::make_pair( "PQUserSingleArenaPre", msg_transfrom< PQUserSingleArenaPre > );
    handles[ 1897770585 ] = std::make_pair( "PRUserSingleArenaPre", msg_transfrom< PRUserSingleArenaPre > );
    handles[ 1321816909 ] = std::make_pair( "PRSingleArenaCheck", msg_transfrom< PRSingleArenaCheck > );
    handles[ 985805389 ] = std::make_pair( "PQSingleArenaSave", msg_transfrom< PQSingleArenaSave > );
    handles[ 351363324 ] = std::make_pair( "PQSingleArenaRankLoad", msg_transfrom< PQSingleArenaRankLoad > );
    handles[ 2121841526 ] = std::make_pair( "PRSingleArenaRankLoad", msg_transfrom< PRSingleArenaRankLoad > );
    handles[ 862327907 ] = std::make_pair( "PQSingleArenaLogLoad", msg_transfrom< PQSingleArenaLogLoad > );
    handles[ 1482603583 ] = std::make_pair( "PRSingleArenaLogLoad", msg_transfrom< PRSingleArenaLogLoad > );
    handles[ 912156268 ] = std::make_pair( "PQSingleArenaLogSave", msg_transfrom< PQSingleArenaLogSave > );
    handles[ 327353176 ] = std::make_pair( "PQSingleArenaGetFirstReward", msg_transfrom< PQSingleArenaGetFirstReward > );

    return handles;
}

