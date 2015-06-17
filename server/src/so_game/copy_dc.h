#ifndef _GAMESVR_COPY_DC_H_
#define _GAMESVR_COPY_DC_H_

#include "dc.h"
#include "proto/copy.h"

class CCopyDC : public TDC< CCopy >
{
public:
    CCopyDC() : TDC< CCopy >( "copy" )
    {
    }

    void set_boss_fight( uint32 role_id, SCopyBossFight& data );
    void del_boss_fight( uint32 role_id );
    SCopyBossFight get_boss_fight( uint32 role_id );
    void set_copyfight_log( std::map< uint32, std::vector<SCopyFightLog> > &list );
    void get_copyfight_log( uint32 copy_id, std::vector<SCopyFightLog> &list );
    void add_copyfight_log( uint32 copy_id, SCopyFightLog &data );
    void QuestLogList();
    void SaveLogList( uint32 copy_id );
};
#define theCopyDC TSignleton< CCopyDC >::Ref()

#endif

