#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGEXT_H_

#include "r_buildingdata.h"

class CBuildingExt : public CBuildingData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BuildingMap::iterator iter = id_building_map.begin();
            iter != id_building_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theBuildingExt TSignleton<CBuildingExt>::Ref()
#endif
