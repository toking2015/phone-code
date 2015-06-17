#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGUPGRADEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGUPGRADEEXT_H_

#include "r_buildingupgradedata.h"

class CBuildingUpgradeExt : public CBuildingUpgradeData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BuildingUpgradeMap::iterator iter = id_buildingupgrade_map.begin();
            iter != id_buildingupgrade_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theBuildingUpgradeExt TSignleton<CBuildingUpgradeExt>::Ref()
#endif
