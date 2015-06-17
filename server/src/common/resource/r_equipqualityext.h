#ifndef IMMORTAL_COMMON_RESOURCE_R_EQUIPQUALITYEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_EQUIPQUALITYEXT_H_

#include "r_equipqualitydata.h"

class CEquipQualityExt : public CEquipQualityData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32EquipQualityMap::iterator iter = id_equipquality_map.begin();
            iter != id_equipquality_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    uint32 FactorToQuality(uint32 main_factor);
};

#define theEquipQualityExt TSignleton<CEquipQualityExt>::Ref()
#endif
