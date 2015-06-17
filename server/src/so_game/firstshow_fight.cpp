#include "fight.h"
#include "user_dc.h"
#include "user_imp.h"
#include "resource/r_monsterext.h"
#include "resource/r_globalext.h"
#include "fight_imp.h"
#include "fight_dc.h"
#include "monster_imp.h"
#include "totem_imp.h"
#include "local.h"
#include "luamgr.h"
#include "misc.h"

SFight* CFightFirstShow::AddFightToMonster( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeFirstShow;
    psfight->box_randomseed = (uint32)rand_r( thread_rand_seed() );
    psfight->fight_randomseed = (uint32)rand_r( thread_rand_seed() );

    user::SetFightId( puser, psfight->fight_id );

    psfight->ack_id = puser->guid;
    AddSoldier( psfight, puser->guid, kFightLeft );

    uint32 first = theGlobalExt.get<uint32>("first_show_fight_monster1");
    uint32 second = theGlobalExt.get<uint32>("first_show_fight_monster2");

    CMonsterData::SData *pmonster_r = theMonsterExt.Find( first );
    if ( NULL == pmonster_r )
    {
        theFightDC.del( psfight->fight_id );
        return NULL;
    }

    CMonsterData::SData *pmonster_s = theMonsterExt.Find( second );
    if ( NULL == pmonster_s )
    {
        theFightDC.del( psfight->fight_id );
        return NULL;
    }

    for( std::vector<uint32>::iterator jter = pmonster_r->fight_monster.begin();
        jter != pmonster_r->fight_monster.end();
        ++jter )
    {
        AddMonster( psfight, *jter, kFightLeft );
    }

    for( std::vector<uint32>::iterator jter = pmonster_s->fight_monster.begin();
        jter != pmonster_s->fight_monster.end();
        ++jter )
    {
        AddMonster( psfight, *jter, kFightRight );
    }

    //初始化seqno_map
    psfight->seqno_map[puser->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

void CFightFirstShow::SetFightInfo( SFight *psfight )
{
    uint32 guid = 0;
    //怪物属性
    for ( std::vector< SSoldier >::iterator iter = psfight->monster_list.begin();
        iter != psfight->monster_list.end();
        ++iter )
    {
        SFightPlayerInfo play_info;
        play_info.guid = ++guid;
        play_info.camp = iter->camp;
        play_info.attr = kAttrMonster;

        fight::SetMonster(iter->role_id, play_info, guid );
        //添加图腾BUFF
        totem::AddTotemBuff( iter->role_id, play_info, kTotemPacketNormal );
        psfight->fight_info_list.push_back( play_info );
    }
}

bool CFightFirstShow::NeedCheck( SFight *psfight )
{
    return false;
}
