#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGCRITTIMESEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGCRITTIMESEXT_H_

#include "r_buildingcrittimesdata.h"

class CBuildingCritTimesExt : public CBuildingCritTimesData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BuildingCritTimesMap::iterator iter = id_buildingcrittimes_map.begin();
            iter != id_buildingcrittimes_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
    std::vector<S2UInt32> FindList( uint32 building_type );
};

#define theBuildingCritTimesExt TSignleton<CBuildingCritTimesExt>::Ref()
#endif
