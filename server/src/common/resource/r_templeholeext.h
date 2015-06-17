#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEHOLEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEHOLEEXT_H_

#include "r_templeholedata.h"

class CTempleHoleExt : public CTempleHoleData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TempleHoleMap::iterator iter = id_templehole_map.begin();
            iter != id_templehole_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTempleHoleExt TSignleton<CTempleHoleExt>::Ref()
#endif
