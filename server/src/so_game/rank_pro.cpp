#include "misc.h"
#include "rank_imp.h"
#include "proto/rank.h"
#include "proto/constant.h"
#include "user_dc.h"
#include "local.h"

#include "resource/r_rankcopyext.h"

SO_LOAD( rank_type_reg )
{
    //注册排序
    rank::Register( kRankingTypeSingleArena, rank::rank_compare_asc );
    rank::Register( kRankingTypeSoldier, rank::rank_compare_desc );
    rank::Register( kRankingTypeTotem, rank::rank_compare_desc );
    rank::Register( kRankingTypeCopy, rank::rank_compare_desc );
    rank::Register( kRankingTypeMarket, rank::rank_compare_market );
    rank::Register( kRankingTypeEquip, rank::rank_compare_desc );
    rank::Register( kRankingTypeTeamLevel, rank::rank_compare_desc );
    rank::Register( kRankingTypeTemple, rank::rank_compare_desc );
}

MSG_FUNC( PRRankLoad )
{
    rank::LoadData( msg.rank_type, msg.list, msg.rank_attr );
}

MSG_FUNC( PQRankIndex )
{
    QU_ON( user, msg.role_id );

    if ( msg.target_id == 0 )
        msg.target_id = msg.role_id;

    uint32 rank_attr = msg.rank_attr;//theRankCopyExt.Find( msg.rank_type ) ? kRankAttrCopy : kRankAttrReal;

    PRRankIndex rep;
    bccopy( rep, user->ext);

    rep.rank_type = msg.rank_type;
    rep.rank_attr = rank_attr;
    rep.target_id = msg.target_id;
    rep.limit = msg.limit;
    rep.index = rank::FindIndex( msg.rank_type, msg.target_id, rank_attr, msg.limit );
    rank::GetData( msg.rank_type, rep.index, rank_attr, msg.limit, rep.data );


    local::write( local::access, rep );
}

MSG_FUNC( PQRankList )
{
    QU_ON( user, msg.role_id );

    uint32 rank_attr = theRankCopyExt.Find( msg.rank_type ) ? kRankAttrCopy : kRankAttrReal;

    PRRankList rep;
    bccopy( rep, user->ext );

    rep.rank_type = msg.rank_type;
    rep.index = msg.index;
    rep.sum = rank::GetCount( msg.rank_type, rank_attr, msg.limit );
    rep.limit = msg.limit;

    rank::GetRank( msg.rank_type, msg.index, msg.count, rank_attr, rep.limit, rep.list );


    local::write( local::access, rep );
}

MSG_FUNC( PQRankListType )
{
    QU_ON( user, msg.role_id );

    uint32 rank_attr = msg.data_type;

    PRRankList rep;
    bccopy( rep, user->ext );

    rep.rank_type = msg.rank_type;
    rep.index = msg.index;
    rep.sum = rank::GetCount( msg.rank_type, rank_attr, msg.limit );
    rep.limit = msg.limit;

    rank::GetRank( msg.rank_type, msg.index, msg.count, rank_attr, rep.limit, rep.list );

    local::write( local::access, rep );
}
