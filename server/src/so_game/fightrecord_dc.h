#ifndef _GAMESVR_FIGHTRECORD_DC_H_
#define _GAMESVR_FIGHTRECORD_DC_H_

#include "common.h"
#include "proto/fight.h"
#include "dc.h"

class CFightRecordDC : public TDC< CFightRecordMap >
{
public:
    CFightRecordDC() : TDC< CFightRecordMap >( "fightrecord" )
    {
    }

    ~CFightRecordDC()
    {
    }


    void set(uint32 id);
    uint32 get();
};
#define theFightRecordDC TSignleton< CFightRecordDC >::Ref()

#endif

