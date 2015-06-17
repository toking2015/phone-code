#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGSPEEDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGSPEEDEXT_H_

#include "r_buildingspeeddata.h"

class CBuildingSpeedExt : public CBuildingSpeedData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BuildingSpeedMap::iterator iter = id_buildingspeed_map.begin();
            iter != id_buildingspeed_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theBuildingSpeedExt TSignleton<CBuildingSpeedExt>::Ref()
#endif
