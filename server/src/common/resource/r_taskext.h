#ifndef IMMORTAL_COMMON_RESOURCE_R_TASKEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TASKEXT_H_

#include "r_taskdata.h"

class CTaskExt : public CTaskData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TaskMap::iterator iter = id_task_map.begin();
            iter != id_task_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    //< level, < task > >
    std::map< uint32, std::vector< CTaskData::SData* > > team_level_map;

    std::vector< CTaskData::SData* >& FindLevel( uint32 level );

    void LoadData(void);
    void ClearData(void);
};

#define theTaskExt TSignleton<CTaskExt>::Ref()
#endif
