#ifndef IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOINEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BUILDINGCOINEXT_H_

#include "r_buildingcoindata.h"

class CBuildingCoinExt : public CBuildingCoinData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BuildingCoinMap::iterator iter = id_buildingcoin_map.begin();
            iter != id_buildingcoin_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theBuildingCoinExt TSignleton<CBuildingCoinExt>::Ref()
#endif
