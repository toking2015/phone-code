#include "local.h"
#include "fightrecord_imp.h"
#include "fightrecord_dc.h"
#include "proto/constant.h"
#include "misc.h"

namespace fightrecord
{

uint32 Save( SFight *psfight )
{
    PQFightRecordSave rep;
    rep.fight_record = psfight->fight_record;
    rep.fight_record.guid = theFightRecordDC.get();
    theFightRecordDC.set(rep.fight_record.guid+1);

    local::write(local::fight, rep);

    return rep.fight_record.guid;
}


}// namespace fightrecord


