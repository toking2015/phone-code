#include "misc.h"
#include "local.h"
#include "proto/user.h"
#include "proto/totem.h"
#include "proto/soldier.h"
#include "proto/formation.h"
#include "proto/constant.h"
#include "user_dc.h"
#include "user_imp.h"
#include "singlearena_imp.h"
#include "pro.h"

MSG_FUNC( PQUserData )
{
    QU_ON( user, msg.role_id );

    user::reply_data( user );
}

MSG_FUNC( PQUserSimple )
{
    QU_ON( puser, msg.role_id );
    QU_OFF( ptarget, msg.target_id );

    user::ReplyUserSimple( puser, ptarget );
}
MSG_FUNC(PQUserPanel)
{
    QU_ON( user, msg.role_id );
    QU_OFF( target, msg.target_id );

    PRUserPanel rep;
    bccopy( rep, user->ext );

    rep.target_id   = msg.target_id;
    rep.data.simple = target->data.simple;
    rep.data.info = target->data.info;

    local::write( local::access, rep );
}

MSG_FUNC(PQUserSingleArenaPanel)
{
    QU_ON( user, msg.role_id );
    QU_OFF( target, msg.target_id );

    PRUserSingleArenaPanel rep;
    bccopy( rep, user->ext );

    rep.target_id   = msg.target_id;
    rep.data.simple = target->data.simple;
    rep.data.info = target->data.info;
    rep.data.formation_map = target->data.formation_map[kFormationTypeSingleArenaDef];
    rep.data.soldier_map = target->data.soldier_map[kSoldierTypeCommon];
    rep.data.totem_info = target->data.totem_map[kTotemPacketNormal];

    local::write( local::access, rep );
}

MSG_FUNC(PQUserTombPanel)
{
    QU_ON( user, msg.role_id );
    QU_OFF( target, msg.target_id );

    PRUserTombPanel rep;
    bccopy( rep, user->ext );

    rep.target_id   = msg.target_id;
    rep.data.simple = target->data.simple;
    rep.data.info = target->data.info;

    if ( target->data.formation_map[kFormationTypeYesterday].empty() )
        singlearena::SaveYesterday( target );

    rep.data.formation_map = target->data.formation_map[kFormationTypeYesterday];
    rep.data.soldier_map = target->data.soldier_map[kSoldierTypeYesterday];
    rep.data.totem_info = target->data.totem_map[kTotemPacketYesterday];
    rep.data.fightextable_map = target->data.fightextable_map[kAttrSoldierYesterday];

    local::write( local::access, rep );
}

MSG_FUNC( PQUserActionSave )
{
    QU_ON( user, msg.role_id );

    user->data.other.last_action = msg.last_action;
}

