#include "fight_dc.h"
#include "timer.h"
#include "jsonconfig.h"
#include "log.h"
#include "fight_event.h"
#include "fight_imp.h"
#include "var_imp.h"
#include "server.h"
#include "luamgr.h"

SO_LOAD( fight_timer_reg )
{
    theSysTimeMgr.AddLoop
    (
        "fight_save_timer",
        "",
        NULL,
        NULL,
        CSysTimeMgr::Minute,
        1,
        0
    );
}

//定时保存
TIMER( fight_save_timer )
{
    theFightDC.gc();
    theLuaMgr.GC();
    //theLuaMgr.GCCount();
}

TIMER( fight_delay_skill )
{
    CJson json = CJson::LoadString( param );
    fight::RoundDelaySkill( to_uint( json["fight_id"]), to_uint( json["seqno"] ) );
}
