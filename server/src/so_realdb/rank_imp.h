#ifndef _IMMORTAL_SO_REALDB_RAnk_IMP_H_
#define _IMMORTAL_SO_REALDB_RANK_IMP_H_

#include "proto/rank.h"
#include "common.h"

namespace rank
{
    //统一保存和读取记录排行榜数据(不需要进行扩展)
    uint32 SaveRankCopy( uint8 rank_type, uint8 set_type, std::vector< SRankData >& rank_list );
    uint32 LoadRankCopy( uint8 rank_type );

    //对排即时排行榜数据进行读取
    uint32 LoadRankReal( uint8 rank_type );

    int32 rank_parse_level_limit( uint32 level );

    void rank_real_load_singlearena( PRRankLoad& rep );
    void rank_real_load_soldier( PRRankLoad& rep );
    void rank_real_load_totem( PRRankLoad& rep );
    void rank_real_load_copy( PRRankLoad& rep );
    void rank_real_load_market( PRRankLoad& rep );
    void rank_real_load_equip( PRRankLoad& rep );
}// namespace rank

#endif

