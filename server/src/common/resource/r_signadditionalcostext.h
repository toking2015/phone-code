#ifndef IMMORTAL_COMMON_RESOURCE_R_SIGNADDITIONALCOSTEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SIGNADDITIONALCOSTEXT_H_

#include "r_signadditionalcostdata.h"

class CSignAdditionalCostExt : public CSignAdditionalCostData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SignAdditionalCostMap::iterator iter = id_signadditionalcost_map.begin();
            iter != id_signadditionalcost_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theSignAdditionalCostExt TSignleton<CSignAdditionalCostExt>::Ref()
#endif
