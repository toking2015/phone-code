#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGVIEWEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGVIEWEXT_H_

#include "r_buildingviewdata.h"

class CBuildingViewExt : public CBuildingViewData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BuildingViewMap::iterator iter = id_buildingview_map.begin();
            iter != id_buildingview_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theBuildingViewExt TSignleton<CBuildingViewExt>::Ref()
#endif
