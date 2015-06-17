#include "proto/transfrom/transfrom_trial.h"

#include "proto/trial/SUserTrialReward.h"
#include "proto/trial/SUserTrial.h"
#include "proto/trial/PQTrialEnter.h"
#include "proto/trial/PQTrialRewardList.h"
#include "proto/trial/PRTrialRewardList.h"
#include "proto/trial/PQTrialRewardGet.h"
#include "proto/trial/PRTrialRewardGet.h"
#include "proto/trial/PQTrialRewardEnd.h"
#include "proto/trial/PRTrialRewardEnd.h"
#include "proto/trial/PQTrialUpdate.h"
#include "proto/trial/PRTrialUpdate.h"
#include "proto/trial/PQTrialMopUp.h"
#include "proto/trial/PRTrialMopUp.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_trial::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 189825132 ] = std::make_pair( "PQTrialEnter", msg_transfrom< PQTrialEnter > );
    handles[ 644273634 ] = std::make_pair( "PQTrialRewardList", msg_transfrom< PQTrialRewardList > );
    handles[ 1679379448 ] = std::make_pair( "PRTrialRewardList", msg_transfrom< PRTrialRewardList > );
    handles[ 745746844 ] = std::make_pair( "PQTrialRewardGet", msg_transfrom< PQTrialRewardGet > );
    handles[ 1462254479 ] = std::make_pair( "PRTrialRewardGet", msg_transfrom< PRTrialRewardGet > );
    handles[ 84089290 ] = std::make_pair( "PQTrialRewardEnd", msg_transfrom< PQTrialRewardEnd > );
    handles[ 1907887097 ] = std::make_pair( "PRTrialRewardEnd", msg_transfrom< PRTrialRewardEnd > );
    handles[ 898503924 ] = std::make_pair( "PQTrialUpdate", msg_transfrom< PQTrialUpdate > );
    handles[ 1768293067 ] = std::make_pair( "PRTrialUpdate", msg_transfrom< PRTrialUpdate > );
    handles[ 634559810 ] = std::make_pair( "PQTrialMopUp", msg_transfrom< PQTrialMopUp > );
    handles[ 1409767765 ] = std::make_pair( "PRTrialMopUp", msg_transfrom< PRTrialMopUp > );

    return handles;
}

