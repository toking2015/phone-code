#include "proto/transfrom/transfrom_activity.h"

#include "proto/activity/SActivityOpen.h"
#include "proto/activity/SActivityData.h"
#include "proto/activity/SActivityFactor.h"
#include "proto/activity/SActivityReward.h"
#include "proto/activity/SActivityInfo.h"
#include "proto/activity/CActivity.h"
#include "proto/activity/PQActivityOpenLoad.h"
#include "proto/activity/PRActivityOpenLoad.h"
#include "proto/activity/PQActivityDataLoad.h"
#include "proto/activity/PRActivityDataLoad.h"
#include "proto/activity/PQActivityFactorLoad.h"
#include "proto/activity/PRActivityFactorLoad.h"
#include "proto/activity/PQActivityRewardLoad.h"
#include "proto/activity/PRActivityRewardLoad.h"
#include "proto/activity/PQActivityList.h"
#include "proto/activity/PRActivityList.h"
#include "proto/activity/PQActivityInfoList.h"
#include "proto/activity/PRActivityInfoList.h"
#include "proto/activity/PQActivityTakeReward.h"
#include "proto/activity/PRActivityTakeReward.h"

std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > >
class_transfrom_activity::get_handles(void)
{
    std::map< uint32, std::pair< std::string, SMsgHead*(*)(wd::CStream&) > > handles;

    handles[ 812917395 ] = std::make_pair( "PQActivityOpenLoad", msg_transfrom< PQActivityOpenLoad > );
    handles[ 2080405480 ] = std::make_pair( "PRActivityOpenLoad", msg_transfrom< PRActivityOpenLoad > );
    handles[ 441874233 ] = std::make_pair( "PQActivityDataLoad", msg_transfrom< PQActivityDataLoad > );
    handles[ 1519164061 ] = std::make_pair( "PRActivityDataLoad", msg_transfrom< PRActivityDataLoad > );
    handles[ 244536826 ] = std::make_pair( "PQActivityFactorLoad", msg_transfrom< PQActivityFactorLoad > );
    handles[ 1405068803 ] = std::make_pair( "PRActivityFactorLoad", msg_transfrom< PRActivityFactorLoad > );
    handles[ 173095659 ] = std::make_pair( "PQActivityRewardLoad", msg_transfrom< PQActivityRewardLoad > );
    handles[ 1427341341 ] = std::make_pair( "PRActivityRewardLoad", msg_transfrom< PRActivityRewardLoad > );
    handles[ 255414195 ] = std::make_pair( "PQActivityList", msg_transfrom< PQActivityList > );
    handles[ 1239021585 ] = std::make_pair( "PRActivityList", msg_transfrom< PRActivityList > );
    handles[ 707651935 ] = std::make_pair( "PQActivityInfoList", msg_transfrom< PQActivityInfoList > );
    handles[ 1390946469 ] = std::make_pair( "PRActivityInfoList", msg_transfrom< PRActivityInfoList > );
    handles[ 378704425 ] = std::make_pair( "PQActivityTakeReward", msg_transfrom< PQActivityTakeReward > );
    handles[ 1687101483 ] = std::make_pair( "PRActivityTakeReward", msg_transfrom< PRActivityTakeReward > );

    return handles;
}

