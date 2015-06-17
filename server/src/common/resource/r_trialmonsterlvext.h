#ifndef IMMORTAL_COMMON_RESOURCE_R_TRIALMONSTERLVEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TRIALMONSTERLVEXT_H_

#include "r_trialmonsterlvdata.h"

class CTrialMonsterLvExt : public CTrialMonsterLvData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TrialMonsterLvMap::iterator iter = id_trialmonsterlv_map.begin();
            iter != id_trialmonsterlv_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTrialMonsterLvExt TSignleton<CTrialMonsterLvExt>::Ref()
#endif
