#include "misc.h"
#include "rank_imp.h"
#include "proto/rank.h"
#include "proto/constant.h"
#include "local.h"


MSG_FUNC( PQRankCopySave )
{
    rank::SaveRankCopy( msg.rank_type, msg.set_type, msg.list );
}

MSG_FUNC( PQRankLoad )
{
    switch ( msg.rank_attr )
    {
    case kRankAttrReal:
        rank::LoadRankReal( msg.rank_type );
        break;
    case kRankAttrCopy:
        rank::LoadRankCopy( msg.rank_type );
        break;
    }
}
