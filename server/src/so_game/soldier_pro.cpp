#include "soldier_imp.h"
#include "proto/soldier.h"
#include "proto/constant.h"
#include "log.h"
#include "user_dc.h"
#include "misc.h"

/*****************武将协议请求*****************/
MSG_FUNC(PQSoldierList )
{
    QU_ON( puser, msg.role_id );

    soldier::ReplyList(puser,msg.soldier_type);
}

//这个协议废弃
MSG_FUNC(PQSoldierAdd)
{
    QU_ON( puser, msg.role_id );

    //soldier::Add(puser, msg.soldier_id, kPathSoldierAdd );
}

MSG_FUNC(PQSoldierDel )
{
    QU_ON( puser, msg.role_id );

    soldier::TakeGuid(puser, msg.soldier, kPathSoldierDel );
}

MSG_FUNC(PQSoldierMove )
{
    QU_ON( puser, msg.role_id );
    soldier::Move( puser, msg.soldier, msg.index, kPathSoldierMove );
}

MSG_FUNC(PQSoldierLvUp)
{
    QU_ON( puser, msg.role_id );
    soldier::LvUp( puser, msg.soldier );
}

MSG_FUNC(PQSoldierQualityAddXp)
{
    QU_ON( puser, msg.role_id );
    soldier::AddQualityXp( puser, msg.soldier, msg.coin_list );
}

MSG_FUNC(PQSoldierQualityUp)
{
    QU_ON( puser, msg.role_id );
    soldier::QualityUp( puser, msg.soldier );
}

MSG_FUNC(PQSoldierStarUp)
{
    QU_ON( puser, msg.role_id );
    soldier::StarUp( puser, msg.soldier );
}

MSG_FUNC(PQSoldierRecruit)
{
    QU_ON( puser, msg.role_id );
    soldier::Recruit( puser, msg.id );
}

MSG_FUNC(PQSoldierEquip)
{
    QU_ON( puser, msg.role_id );
    soldier::Equip( puser, msg.soldier, msg.item);
}

MSG_FUNC(PQSoldierSkillReset)
{
    QU_ON( puser, msg.role_id );
    soldier::SkillReset( puser, msg.soldier );
}

MSG_FUNC(PQSoldierSkillLvUp)
{
    QU_ON( puser, msg.role_id );
    soldier::SkillLvUp( puser, msg.soldier, msg.skill_id );
}

MSG_FUNC(PQSoldierEquipExt)
{
    QU_ON( puser, msg.role_id );
    soldier::ReplySoldierEquipExt( puser, msg.soldier );
}

/*****************武将协议回复*****************/

