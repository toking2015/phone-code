#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_taskext.h"

void CTaskExt::LoadData(void)
{
    CTaskData::LoadData();

    for ( UInt32TaskMap::iterator iter = id_task_map.begin();
        iter != id_task_map.end();
        ++iter )
    {
        CTaskData::SData* task = iter->second;
        if ( task->task_id <= 0 )
            continue;

        if ( task->team_level_min <= 0 )
            task->team_level_min = 1;

        if ( task->team_level_max <= 0 )
            task->team_level_max = 256;

        for ( int32 i = task->team_level_min; i < (int32)task->team_level_max; ++i )
            team_level_map[i].push_back( task );
    }
}
void CTaskExt::ClearData(void)
{
    team_level_map.clear();

    CTaskData::ClearData();
}

std::vector< CTaskData::SData* >& CTaskExt::FindLevel( uint32 level )
{
    return team_level_map[ level ];
}

