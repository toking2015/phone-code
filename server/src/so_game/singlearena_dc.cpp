#include "singlearena_dc.h"
#include "singlearena_imp.h"
#include "formation_imp.h"
#include "fightextable_imp.h"
#include "rank_imp.h"
#include "server.h"
#include "log.h"
#include "proto/constant.h"
#include "back_imp.h"


SSingleArenaInfo*   CSingleArenaDC::find_info( uint32 target_id )
{
    std::map< uint32, SSingleArenaInfo >::iterator iter = db().singlearena_info_map.find( target_id );
    if ( iter == db().singlearena_info_map.end() )
        return NULL;

    SSingleArenaInfo* info = &(iter->second);
    return info;
}

void    CSingleArenaDC::del_info( uint32 target_id )
{
    std::map< uint32, SSingleArenaInfo >::iterator iter = db().singlearena_info_map.find( target_id );
    if ( iter == db().singlearena_info_map.end() )
        return;
    db().singlearena_info_map.erase(iter);
}


void    CSingleArenaDC::set_info_data( uint32 target_id, SSingleArenaInfo &info )
{
    db().singlearena_info_map[target_id] = info;
}


SSingleArenaOpponent*   CSingleArenaDC::find_rank( uint32 rank )
{
    std::map< uint32, SSingleArenaOpponent >::iterator iter = db().singlearena_rank_map.find( rank );
    if ( iter == db().singlearena_rank_map.end() )
        return NULL;

    SSingleArenaOpponent* opp = &(iter->second);
    return opp;
}

SSingleArenaOpponent*   CSingleArenaDC::find_rank_by_targetid( uint32 target_id )
{
    uint32 rank = get_rank_id( target_id );
    if( rank == 0 )
        return NULL;

    return find_rank( rank );
}


void    CSingleArenaDC::del_rank( uint32 rank )
{
    std::map< uint32, SSingleArenaOpponent >::iterator iter = db().singlearena_rank_map.find( rank );
    if ( iter == db().singlearena_rank_map.end() )
        return;
    db().singlearena_rank_map.erase(iter);
}


void    CSingleArenaDC::set_rank_data( uint32 rank, SSingleArenaOpponent &opp )
{
    db().singlearena_rank_map[rank] = opp;

    if( rank <= SHOW_RANK_COUNT )
        set_show_data( rank, opp );

    if( opp.target_id >= REAL_TARGET_GUID )
    {
        rank::UpdateSingleArena( opp.target_id, opp.avatar, opp.name, opp.team_level, rank );
    }
}

uint32  CSingleArenaDC::get_rank_data_count()
{
    return (uint32)db().singlearena_rank_map.size();
}

SSingleArenaOpponent*   CSingleArenaDC::find_show( uint32 rank )
{
    std::map< uint32, SSingleArenaOpponent >::iterator iter = db().singlearena_show_map.find( rank );
    if ( iter == db().singlearena_show_map.end() )
        return NULL;

    SSingleArenaOpponent* opp = &(iter->second);
    return opp;
}

void    CSingleArenaDC::set_show_data( uint32 rank, SSingleArenaOpponent &opp )
{
    db().singlearena_show_map[rank] = opp;
}

uint32  CSingleArenaDC::get_show_data_count()
{
    return (uint32)db().singlearena_show_map.size();
}


SSingleArenaOpponent*   CSingleArenaDC::find_opp( uint32 guid, uint32 target_id )
{
    std::map< uint32, SSingleArenaInfo >::iterator iter = db().singlearena_info_map.find( guid );
    if ( iter == db().singlearena_info_map.end() )
        return NULL;


    SSingleArenaInfo* info = &(iter->second);

    for( std::vector<SSingleArenaOpponent>::iterator iter = info->opponent_list.begin();
        iter != info->opponent_list.end();
        ++iter )
    {
        if ( iter->target_id == target_id )
            return &(*iter);
    }

    return NULL;
}

void    CSingleArenaDC::find_formation( uint32 guid, uint32 target_id, std::vector<SUserFormation> &formation_list )
{
    std::map< uint32, SSingleArenaInfo >::iterator iter = db().singlearena_info_map.find( guid );
    if ( iter == db().singlearena_info_map.end() )
        return;

    SSingleArenaInfo* info = &(iter->second);

    for( std::vector<SSingleArenaOpponent>::iterator iter = info->opponent_list.begin();
        iter != info->opponent_list.end();
        ++iter )
    {
        if ( iter->target_id == target_id )
        {
            formation_list = iter->formation_list;
            return;
        }
    }
}

void    CSingleArenaDC::list_rank( uint32 index, uint32 count, std::vector<SSingleArenaOpponent> &list )
{
    for( uint32 i = index; i < index + count; ++i )
    {
        std::map< uint32, SSingleArenaOpponent >::iterator iter = db().singlearena_show_map.find( i );
        if ( iter != db().singlearena_show_map.end() )
            list.push_back( iter->second );
    }
}


void    CSingleArenaDC::set_id_rank( uint32 target_id, uint32 rank )
{
    db().id_rank_map[target_id] = rank;
}

uint32  CSingleArenaDC::get_rank_id( uint32 target_id )
{
    std::map< uint32, uint32 >::iterator iter = db().id_rank_map.find( target_id );
    if( iter == db().id_rank_map.end() )
        return 0;

    return iter->second;
}

uint32  CSingleArenaDC::get_guid()
{
    db().target_guid += 1;
    if( db().target_guid == MAX_CREATE_OPPONENT + 1 )
        back::write( "singlearena.debug", "get_guid guid more then MAX_CREATE_OPPONENT %u ", db().target_guid );

    return db().target_guid;
}

void    CSingleArenaDC::InitGuid()
{
    db().target_guid = 0;
}

void    CSingleArenaDC::UpdateLevel( uint32 role_id, uint32 level )
{
    uint32 rank = 100;
    SSingleArenaOpponent * pData = find_rank_by_targetid( role_id );
    if( pData )
    {
        rank = pData->rank;
        pData->team_level = level;
        singlearena::SaveDataToDB( *pData, kSingleArenaObjectDel );
        singlearena::SaveDataToDB( *pData, kSingleArenaObjectAdd );
    }

    if( rank <= SHOW_RANK_COUNT )
    {
        pData = find_show( rank );
        if( pData )
            pData->team_level = level;
    }

}

void    CSingleArenaDC::UpdateAvatar( uint32 role_id, uint16 avatar )
{
    uint32 rank = 100;
    SSingleArenaOpponent * pData = find_rank_by_targetid( role_id );
    if( pData )
    {
        rank = pData->rank;
        pData->avatar = avatar;
        singlearena::SaveDataToDB( *pData, kSingleArenaObjectDel );
        singlearena::SaveDataToDB( *pData, kSingleArenaObjectAdd );
    }

    if( rank <= SHOW_RANK_COUNT )
    {
        pData = find_show( rank );
        if( pData )
            pData->avatar = avatar;
    }

}

void    CSingleArenaDC::UpdateName( uint32 role_id, std::string name )
{
    uint32 rank = 100;
    SSingleArenaOpponent * pData = find_rank_by_targetid( role_id );
    if( pData )
    {
        rank = pData->rank;
        pData->name = name;
        singlearena::SaveDataToDB( *pData, kSingleArenaObjectDel );
        singlearena::SaveDataToDB( *pData, kSingleArenaObjectAdd );
    }

    if( rank <= SHOW_RANK_COUNT )
    {
        pData = find_show( rank );
        if( pData )
            pData->name = name;
    }

}

void    CSingleArenaDC::UpdateFightValue( SUser* puser)
{
    uint32 rank = 100;
    uint32 fight_value =0;

    SSingleArenaOpponent * pData = find_rank_by_targetid( puser->guid);
    if( pData )
    {
        rank = pData->rank;
        fight_value = fightextable::GetFightValue( puser, kFormationTypeSingleArenaDef);
        pData->fight_value = fight_value;
        singlearena::SaveDataToDB( *pData, kSingleArenaObjectDel );
        singlearena::SaveDataToDB( *pData, kSingleArenaObjectAdd );
    }

    if( rank <= SHOW_RANK_COUNT )
    {
        pData = find_show( rank );
        if( pData )
            pData->fight_value = fight_value;
    }
}


void    CSingleArenaDC::InitLoadLog()
{
    db().load_log = 0;
}

bool    CSingleArenaDC::CheckLoadLog()
{
    return db().load_log == 2;
}

void    CSingleArenaDC::SetLoadLog()
{
    db().load_log += 1;
}

bool    CSingleArenaDC::check_rank( uint32 guid, uint32 target_id )
{
    std::map< uint32, SSingleArenaInfo >::iterator iter = db().singlearena_info_map.find( guid );
    if ( iter == db().singlearena_info_map.end() )
        return true;

    SSingleArenaInfo* info = &(iter->second);

    uint32  cur_rank  = 0;                                  //当时排名
    uint32  true_rank = get_rank_id( target_id );          //真实排名

    if ( true_rank == 0 )
        return true;

    for( std::vector<SSingleArenaOpponent>::iterator iter = info->opponent_list.begin();
        iter != info->opponent_list.end();
        ++iter )
    {
        {
            if ( iter->target_id == target_id )
            {
                cur_rank = iter->rank;
                break;
            }
        }
    }

    if( cur_rank != true_rank )
        return true;

    return false;
}


