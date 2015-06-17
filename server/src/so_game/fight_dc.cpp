#include "fight_dc.h"
#include "fight_imp.h"
#include "server.h"

void CFightDC::trans_to_stream( wd::CStream& stream )
{
    fight::GetFightData();
    stream << *dc_data;
}

SFight* CFightDC::find( uint32 fight_id )
{
    std::map< uint32, SFight >::iterator iter = db().fight_map.find( fight_id );
    if ( iter == db().fight_map.end() )
        return NULL;

    SFight* fight = &(iter->second);
    return fight;
}

SFight* CFightDC::add(uint32 gc_time)
{
    uint32 &fight_id = db().fight_id;
    SFight& fight = db().fight_map[ ++fight_id ];
    fight.fight_id = fight_id;
    fight.seqno = 1;
    fight.create_time = server::local_time();
    fight.gc_time = fight.create_time + gc_time;

    return &fight;
}

void CFightDC::del( uint32 fight_id )
{
    std::map< uint32, SFight >::iterator iter = db().fight_map.find( fight_id );
    if ( iter == db().fight_map.end() )
        return;
    db().fight_map.erase(iter);
}


bool CFightDC::set_seqno( uint32 fight_id, uint32 user_guid, uint32 seqno )
{
    std::map< uint32, SFight >::iterator iter = db().fight_map.find( fight_id );
    if ( iter == db().fight_map.end() )
        return false;

    SFight &fight = iter->second;

    std::map<uint32, uint32>::iterator jter = fight.seqno_map.find( user_guid );
    if ( jter == fight.seqno_map.end() )
        return false;

    if ( fight.seqno != seqno )
        return false;

    jter->second = seqno;

    for( std::map<uint32, uint32>::iterator jter = fight.seqno_map.begin();
        jter != fight.seqno_map.end();
        ++jter )
    {
        if ( jter->second != fight.seqno )
            return false;
    }

    return true;
}

uint32 CFightDC::get_seqno( uint32 fight_id )
{
    std::map< uint32, SFight >::iterator iter = db().fight_map.find( fight_id );
    if ( iter == db().fight_map.end() )
        return 0;

    SFight &fight = iter->second;

    return fight.seqno;
}

void CFightDC::set_fight_data( std::map<uint32, CFightData> &data )
{
    db().fight_lua_map = data;
}

void CFightDC::get_fight_data( std::map<uint32, CFightData> &data )
{
    data = db().fight_lua_map;
}

void CFightDC::gc()
{
    uint32 now_time = server::local_time();
    for( std::map< uint32, SFight >::iterator iter = db().fight_map.begin();
        iter != db().fight_map.end();
       )
    {
        if ( now_time > iter->second.gc_time )
        {
            db().fight_map.erase(iter++);
        }
        else
        {
            ++iter;
        }
    }
}
