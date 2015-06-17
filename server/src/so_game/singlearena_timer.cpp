#include "singlearena_dc.h"
#include "singlearena_imp.h"
#include "user_dc.h"
#include "timer.h"
#include "server.h"
#include "util.h"

SO_LOAD(singlearena_timer_reg)
{
    theSysTimeMgr.AddLoop
    (
        "singlearena_send_reward",
        "",
        "22:00:00",
        NULL,
        CSysTimeMgr::Day,
        1,
        0
    );
}

static void singlearena_player_save(std::pair< const uint32, SSingleArenaOpponent > &pair)
{
    SSingleArenaOpponent *p_opp = &pair.second;
    SUser *puser = theUserDC.find( p_opp->target_id );
    if ( NULL != puser )
        singlearena::SaveYesterday(puser);
}

static void singlearena_send_reward(std::pair< const uint32, SSingleArenaOpponent >& pair)
{
    SSingleArenaOpponent *p_opp = &pair.second;
    singlearena::SendDayReward( p_opp );
}

TIMER(singlearena_send_reward)
{
    dc::safe_each( theSingleArenaDC.db().singlearena_rank_map, singlearena_send_reward);
    dc::safe_each( theSingleArenaDC.db().singlearena_rank_map, singlearena_player_save);
}
