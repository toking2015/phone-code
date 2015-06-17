#ifndef _IMMORTAL_SO_REALDB_REPORTPOST_IMP_H_
#define _IMMORTAL_SO_REALDB_REPORTPOST_IMP_H_

#include "proto/reportpost.h"
#include "common.h"

namespace reportpost
{
    uint32 UpdateData( uint8 set_type, uint32 target_id, uint32 report_id, uint32 report_time );
    uint32 LoadData();

}// namespace reportpost

#endif

