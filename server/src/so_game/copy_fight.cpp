#include "fight.h"
#include "user_dc.h"
#include "user_imp.h"
#include "formation_imp.h"
#include "resource/r_monsterext.h"
#include "fight_imp.h"
#include "copy_imp.h"
#include "fight_dc.h"
#include "monster_imp.h"
#include "local.h"
#include "luamgr.h"
#include "misc.h"

SFight* CFightCopy::AddFightToMonster( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    //7天超时
    SFight *psfight = theFightDC.add( 86400 * 7 );
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeCopy;
    psfight->box_randomseed = (uint32)rand_r( thread_rand_seed() );
    psfight->fight_randomseed = (uint32)rand_r( thread_rand_seed() );

    //user::SetFightId( puser, psfight->fight_id );

    psfight->ack_id = puser->guid;
    AddSoldier( psfight, puser->guid, kFightLeft );

    CMonsterData::SData *pmonster = theMonsterExt.Find( target_id );
    if ( NULL == pmonster )
    {
        theFightDC.del( psfight->fight_id );
        return NULL;
    }

    uint32 copy_id = (target_id-1)/100+1;

    psfight->def_id = target_id;

    for( std::vector<uint32>::iterator jter = pmonster->fight_monster.begin();
        jter != pmonster->fight_monster.end();
        ++jter )
    {
        AddMonster( psfight, *jter, kFightRight );
    }

    //需要判断是不是已经打通
    SCopyLog copy_log = copy::get_copy_log( puser, copy_id );
    if ( copy_log.copy_id == 0 )
        psfight->help_monster = pmonster->help_monster;

    //初始化seqno_map
    psfight->seqno_map[puser->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

