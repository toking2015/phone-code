#include "formation_imp.h"
#include "proto/formation.h"
#include "proto/constant.h"
#include "log.h"
#include "user_dc.h"
#include "misc.h"

/*****************阵型协议请求*****************/
MSG_FUNC(PQFormationList )
{
    QU_ON( puser, msg.role_id );

    formation::ReplyList(puser, msg.formation_type);
}

MSG_FUNC(PQFormationSet)
{
    QU_ON( puser, msg.role_id );
    formation::Set(puser, msg.formation_list, msg.formation_type);
}

/*****************阵型协议回复*****************/
