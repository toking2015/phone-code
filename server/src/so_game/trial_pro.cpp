#include "trial_imp.h"
#include "proto/trial.h"
#include "proto/constant.h"
#include "log.h"
#include "user_dc.h"
#include "misc.h"

/*****************阵型协议请求*****************/
MSG_FUNC(PQTrialEnter)
{
    QU_ON( puser, msg.role_id );
    trial::Enter(puser, msg.id, msg.formation_list);
}

MSG_FUNC(PQTrialRewardList)
{
    QU_ON( puser, msg.role_id );
    trial::ReplyRewardList(puser, msg.id);
}

MSG_FUNC(PQTrialRewardGet)
{
    QU_ON( puser, msg.role_id );
    trial::RewardGet(puser, msg.id, msg.index);
}

MSG_FUNC(PQTrialRewardEnd)
{
    QU_ON( puser, msg.role_id );
    trial::RewardEnd(puser, msg.id);
}

MSG_FUNC(PQTrialUpdate)
{
    QU_ON( puser, msg.role_id );
    for( uint32 i = kTrialSurvival; i <= kTrialIntelligence; ++i )
    {
        trial::ReplyTrial(puser,i);
        trial::ReplyRewardList(puser,i);
    }
}

MSG_FUNC(PQTrialMopUp)
{
    QU_ON( puser, msg.role_id );
    trial::MopUp(puser, msg.id );
}

/*****************阵型协议回复*****************/
