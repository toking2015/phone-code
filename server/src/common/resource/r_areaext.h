#ifndef IMMORTAL_COMMON_RESOURCE_R_AREAEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_AREAEXT_H_

#include "r_areadata.h"

class CAreaExt : public CAreaData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32AreaMap::iterator iter = id_area_map.begin();
            iter != id_area_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theAreaExt TSignleton<CAreaExt>::Ref()
#endif
