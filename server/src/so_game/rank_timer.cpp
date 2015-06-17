#include "timer.h"
#include "jsonconfig.h"
#include "log.h"
#include "rank_imp.h"

TIMER( rank_copy_rule )
{
    CJson json = CJson::LoadString( param );

    uint32 rank_type = to_uint( json[ "rank_type" ] );
    rank::CopyRank( rank_type );
}

