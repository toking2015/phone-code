#include "fight.h"
#include "user_dc.h"
#include "user_imp.h"
#include "formation_imp.h"
#include "resource/r_monsterext.h"
#include "fight_imp.h"
#include "totem_imp.h"
#include "fight_dc.h"
#include "monster_imp.h"
#include "local.h"
#include "luamgr.h"
#include "misc.h"
#include "pro.h"

SFight* CFightFriend::AddFightToPlayer( SUser *puser, uint32 target_id )
{
    if ( NULL == puser )
        return NULL;

    std::map< uint32, SUserFriend >::iterator iter = puser->data.friend_map.find( target_id );

    if( iter == puser->data.friend_map.end() )
        return NULL;


    SFight *psfight = theFightDC.add();
    if ( NULL == psfight )
        return NULL;

    psfight->fight_type = kFightTypeFriend;
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
    //user::SetFightId( ptarget_user, psfight->fight_id );

    //初始化seqno_map
    psfight->seqno_map[puser->guid] = 0;

    SetFightInfo( psfight );
    return psfight;
}

void CFightFriend::SetFightInfo( SFight *psfight )
{
    uint32 guid = 0;
    for ( std::vector< SSoldier >::iterator iter = psfight->soldier_list.begin();
        iter != psfight->soldier_list.end();
        ++iter )
    {
        SSoldier &soldier = *iter;
        SUser *puser = theUserDC.find( soldier.role_id );
        if ( NULL == puser )
            return;

        SFightPlayerInfo play_info;
        play_info.guid = ++guid;
        play_info.player_guid = puser->guid;
        play_info.camp = iter->camp;
        play_info.attr = kAttrPlayer;

        if ( play_info.camp == kFightRight )
            play_info.isAutoFight = 1;

        std::vector<SUserFormation> formation_list;
        uint32   formationtype = kFormationTypeSingleArenaAct;

        if ( psfight->ack_id != puser->guid )
            formationtype = kFormationTypeSingleArenaDef;

        formation::GetFormation( puser, formationtype, formation_list );


        if ( formation_list.empty() )
            continue;

        for ( std::vector<SUserFormation>::iterator iter = formation_list.begin();
            iter != formation_list.end();
            ++iter )
        {
            SUserFormation &formation = *iter;
            SFightSoldier fight_soldier;
            fight_soldier.guid = ++guid;
            fight::SetSoldier( puser, formation, fight_soldier );
            play_info.soldier_list.push_back( fight_soldier );
        }

        //添加图腾BUFF
        totem::AddTotemBuff( soldier.role_id, play_info, kTotemPacketNormal );
        psfight->fight_info_list.push_back( play_info );
    }
}

