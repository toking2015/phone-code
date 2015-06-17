#ifndef _IMMORTAL_SO_REALDB_COPY_IMP_H_
#define _IMMORTAL_SO_REALDB_COPY_IMP_H_

#include "proto/copy.h"
#include "common.h"

namespace copy
{
    uint32 SaveLog( uint32 copy_id , std::vector< SCopyFightLog >& list );
    uint32 LoadLog();

}// namespace copy

#endif

