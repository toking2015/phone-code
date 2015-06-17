#include "misc.h"
#include "singlearena_imp.h"
#include "singlearena_dc.h"
#include "formation_imp.h"
#include "building_imp.h"
#include "soldier_imp.h"
#include "totem_imp.h"
#include "proto/singlearena.h"
#include "proto/constant.h"
#include "user_dc.h"
#include "local.h"

MSG_FUNC( PRSingleArenaRankLoad )
{
    singlearena::LoadData( msg.list );
}

MSG_FUNC( PRSingleArenaLogLoad )
{
    singlearena::LoadLog( msg.list );
}

MSG_FUNC( PQSingleArenaInfo )
{

    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );

    if( !singlearena::IsOpenSingleArena( user ) )
        return;

    singlearena::ReplyInfo( user );
}

MSG_FUNC( PQSingleArenaRefresh )
{
    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );


    if( !singlearena::IsOpenSingleArena( user ) )
        return;

    if( singlearena::CheckRefresh( user ) )
        singlearena::Refresh( user );
}

MSG_FUNC( PQSingleArenaClearCD )
{
    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );


    if( !singlearena::IsOpenSingleArena( user ) )
        return;

    singlearena::ClearCD( user );
}

MSG_FUNC( PQSingleArenaReplyCD )
{
    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );


    if( !singlearena::IsOpenSingleArena( user ) )
        return;

    singlearena::ReplyCD( user );
}

MSG_FUNC( PQSingleArenaAddTimes )
{
    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );


    if( !singlearena::IsOpenSingleArena( user ) )
        return;

    singlearena::AddTimes( user );
}

MSG_FUNC( PQSingleArenaLog )
{
    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );

    if( !singlearena::IsOpenSingleArena( user ) )
        return;

    singlearena::ReplyLog( user );
}

MSG_FUNC( PQSingleArenaRank)
{
    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );


    if( !singlearena::IsOpenSingleArena( user ) )
        return;

    singlearena::ReplyRank( user, msg.index, msg.count );
}

MSG_FUNC( PQSingleArenaMyRank)
{
    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );


    if( !singlearena::IsOpenSingleArena( user ) )
        return;

    singlearena::ReplyMyRank( user );
}

MSG_FUNC(PQUserSingleArenaPre)
{
    if( !theSingleArenaDC.CheckLoadLog() )
        return;

    QU_ON( user, msg.role_id );

    std::vector< S2UInt32 > s_list;
    std::vector< S2UInt32 > t_list;

    SUserSoldier soldier;
    STotem       totem;

    SSingleArenaInfo *info = theSingleArenaDC.find_info( user->guid );
    if( NULL == info )
        return;

    std::vector<SSingleArenaOpponent> &list = info->opponent_list;

    if( list.empty() )
        return;

    PRUserSingleArenaPre  rep;
    bccopy( rep, user->ext );

    S2UInt32 temp;

    for( std::vector< SSingleArenaOpponent>::iterator iter = list.begin();
        iter != list.end();
        ++ iter )
    {
        if( iter->target_id < 1000000 )
            continue;

        QU_OFF( target, iter->target_id );

        if( target )
        {
            s_list.clear();
            t_list.clear();
            std::map< uint32, std::vector< SUserFormation > >::iterator i_iter = target->data.formation_map.find( kFormationTypeSingleArenaDef );
            if( i_iter == target->data.formation_map.end() )
                continue;
            for( std::vector< SUserFormation >::iterator ii_iter = i_iter->second.begin();
                ii_iter != i_iter->second.end();
                ++ii_iter )
            {
                if( ii_iter->attr == kAttrSoldier )
                {
                    if( soldier::GetSoldier( target, ii_iter->guid, soldier ) )
                    {
                        temp.first  = soldier.soldier_id;
                        temp.second = soldier.level;
                        s_list.push_back( temp );
                    }
                }
                else
                {
                    if( totem::GetTotem( target, ii_iter->guid, totem ) )
                    {
                        temp.first  =   totem.id;
                        temp.second =   totem.level;
                        t_list.push_back( temp );
                    }
                }
            }

            if( !s_list.empty() )
                rep.s_map[target->guid] = s_list;

            if( !t_list.empty() )
                rep.t_map[target->guid] = t_list;

        }
    }


    local::write(local::access, rep);
}

//废除
MSG_FUNC(PQSingleArenaGetFirstReward)
{
    //QU_ON( user, msg.role_id );

    //singlearena::GetFirstReward( user );
}

