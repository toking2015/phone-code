#include "fightrecord_dc.h"

void CFightRecordDC::set( uint32 id )
{
    db().fight_record_id = id;
}

uint32 CFightRecordDC::get()
{
    return db().fight_record_id;
}
