#include "tomb_imp.h"
#include "proto/tomb.h"
#include "proto/constant.h"
#include "log.h"
#include "user_dc.h"
#include "misc.h"
#include "formation_imp.h"

/*****************阵型协议请求*****************/
MSG_FUNC(PQTombFight)
{
    QU_ON( puser, msg.role_id );
    STombTarget target = puser->data.tomb_target_list[msg.player_index];
    if ( target.attr == kAttrSoldier )
    {
        QU_OFF( ptarget_user, msg.player_guid);

        if ( puser->data.formation_map[kFormationTypeTombTarget].empty() )
        {
            puser->data.formation_map[kFormationTypeTombTarget] = ptarget_user->data.formation_map[kFormationTypeYesterday];
            formation::ReplyList(puser, kFormationTypeTombTarget);
        }
    }
    tomb::Fight(puser, msg.player_index, msg.player_guid, msg.formation_list);
}

MSG_FUNC(PQTombRewardGet)
{
    QU_ON( puser, msg.role_id );
    tomb::RewardGet(puser, msg.reward_index);
}

MSG_FUNC(PQTombReset)
{
    QU_ON( puser, msg.role_id );
    tomb::Reset(puser);
}

MSG_FUNC(PQTombPlayerReset)
{
    QU_ON( puser, msg.role_id );
    tomb::PlayerReset(puser, msg.player_index);
}

MSG_FUNC(PQTombMopUp)
{
    QU_ON( puser, msg.role_id );
    tomb::MopUp(puser);
}

MSG_FUNC(PQTombTargetList)
{
    QU_ON( puser, msg.role_id );
    tomb::ReplyList(puser);
}


/*****************阵型协议回复*****************/
