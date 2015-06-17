#ifndef _GAMESVR_FIGHT_DC_H_
#define _GAMESVR_FIGHT_DC_H_

#include "common.h"
#include "proto/fight.h"
#include "dc.h"

class CFightDC : public TDC< CFightMap >
{
public:
    CFightDC() : TDC< CFightMap >( "fight" )
    {
    }

    ~CFightDC()
    {
    }

    void trans_to_stream( wd::CStream& stream );

    SFight* find( uint32 fight_id );
    SFight* add(uint32 gc_time = 24*3600);
    void del( uint32 fight_id );
    bool set_seqno( uint32 fight_id, uint32 user_guid, uint32 seqno );
    uint32 get_seqno( uint32 fight_id );
    void set_fight_data( std::map<uint32, CFightData> &data );
    void get_fight_data( std::map<uint32, CFightData> &data );
    void gc();
};
#define theFightDC TSignleton< CFightDC >::Ref()

#endif

