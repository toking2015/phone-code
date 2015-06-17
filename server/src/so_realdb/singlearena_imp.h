#ifndef _IMMORTAL_SO_REALDB_SINGLEARENA_IMP_H_
#define _IMMORTAL_SO_REALDB_SINGLEARENA_IMP_H_

#include "proto/singlearena.h"
#include "common.h"

namespace singlearena
{
    uint32 SaveData( uint8 set_type, SSingleArenaOpponent& data);
    uint32 LoadData();
    uint32 SaveLog( uint32 target_id, std::vector< SSingleArenaLog >& list );
    uint32 LoadLog();

}// namespace singlearena

#endif

