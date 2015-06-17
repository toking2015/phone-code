#include "event.h"
#include "link_event.h"
#include "fightrecord_dc.h"
#include "proto/fight.h"
#include "local.h"

EVENT_FUNC( fightrecord, SEventNetFight )
{
    PQFightRecordID rep;
    local::write(local::fight, rep);
}

