#include "copy_dc.h"
#include "proto/copy.h"
#include "local.h"

//log优先排序
bool copy_fightlog_sort( const SCopyFightLog& fightlog1, const SCopyFightLog& fightlog2)
{
    if ( fightlog1.star > fightlog2.star )
        return true;

    if ( fightlog1.star < fightlog2.star )
        return false;

    if ( fightlog1.fight_value < fightlog2.fight_value  )
        return true;

    return false;
}

void CCopyDC::set_boss_fight( uint32 role_id, SCopyBossFight& data )
{
    db().boss_fight[ role_id ] = data;
}

void CCopyDC::del_boss_fight( uint32 role_id )
{
    std::map< uint32, SCopyBossFight >::iterator iter = db().boss_fight.find( role_id );
    if ( iter != db().boss_fight.end() )
        db().boss_fight.erase( iter );
}

SCopyBossFight CCopyDC::get_boss_fight( uint32 role_id )
{
    std::map< uint32, SCopyBossFight >::iterator iter = db().boss_fight.find( role_id );
    if ( iter == db().boss_fight.end() )
        return SCopyBossFight();

    return iter->second;
}

void CCopyDC::set_copyfight_log( std::map< uint32, std::vector<SCopyFightLog> > &list )
{
    db().copy_log_map = list;
    db().is_load_copyfight_log = 1;
}

void CCopyDC::get_copyfight_log( uint32 copy_id, std::vector<SCopyFightLog> &list )
{
    list = db().copy_log_map[copy_id];
}

void CCopyDC::add_copyfight_log( uint32 copy_id, SCopyFightLog &data )
{
    std::vector< SCopyFightLog > &list = db().copy_log_map[copy_id];

    //首先检查是否是自己
    for( std::vector<SCopyFightLog>::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
        if ( iter->ack_id == data.ack_id )
        {
            if ( ( data.star > iter->star ) ||
                ( data.star == iter->star && data.fight_value < iter->fight_value ) )
            {
                *iter = data;

                std::sort( list.begin(), list.end(), copy_fightlog_sort );
                SaveLogList( copy_id );
            }

            return;
        }
    }

    if ( list.size() < kCopyFightLogMaxCount )
    {
        list.push_back( data );

        std::sort(list.begin(), list.end(), copy_fightlog_sort );
    }
    else
    {
        SCopyFightLog &last = list[kCopyFightLogMaxCount-1];
        if ( (data.star > last.star) ||
            (data.star == last.star && data.fight_value < last.fight_value ) )
        {
            list[ kCopyFightLogMaxCount-1 ] = data;

            std::sort( list.begin(), list.end(), copy_fightlog_sort );
        }
    }

    SaveLogList(copy_id);
}

void CCopyDC::SaveLogList( uint32 copy_id )
{
    PQCopyFightLogSave req;

    req.copy_id = copy_id;
    req.list = db().copy_log_map[ copy_id ];

    local::write(local::realdb, req);
}

void CCopyDC::QuestLogList()
{
    if ( 0 == db().is_load_copyfight_log )
    {
        PQCopyFightLog req;
        local::write(local::realdb, req);
    }
}
