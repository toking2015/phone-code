#include "fight.h"
#include "user_dc.h"
#include "user_imp.h"
#include "formation_imp.h"
#include "resource/r_monsterext.h"
#include "fight_imp.h"
#include "fight_dc.h"
#include "monster_imp.h"
#include "local.h"
#include "luamgr.h"
#include "misc.h"

SFight* CFightPlayer::AddFightToPlayer( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeCommonPlayer;
    psfight->box_randomseed = (uint32)rand_r( thread_rand_seed() );
    psfight->fight_randomseed = (uint32)rand_r( thread_rand_seed() );

    user::SetFightId( puser, psfight->fight_id );
    psfight->ack_id = puser->guid;
    AddSoldier( psfight, puser->guid, kFightLeft );

    SUser *ptarget_user = theUserDC.find( target_id );
    if ( NULL == ptarget_user )
    {
        theFightDC.del(psfight->fight_id);
        return NULL;
    }
    psfight->def_id = target_id;
    AddSoldier( psfight, target_id, kFightRight );
    user::SetFightId( ptarget_user, psfight->fight_id );

    //初始化seqno_map
    psfight->seqno_map[puser->guid] = 0;
    psfight->seqno_map[ptarget_user->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

void CFightPlayer::ExtraProc( SFight *psfight, std::vector<S3UInt32>& coins )
{

}
