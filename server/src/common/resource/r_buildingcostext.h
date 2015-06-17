#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOSTEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOSTEXT_H_

#include "r_buildingcostdata.h"

class CBuildingCostExt : public CBuildingCostData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BuildingCostMap::iterator iter = id_buildingcost_map.begin();
            iter != id_buildingcost_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

public:

    uint32 GetMaxTimes();
};

#define theBuildingCostExt TSignleton<CBuildingCostExt>::Ref()
#endif
