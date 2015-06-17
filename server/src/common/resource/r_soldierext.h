#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIEREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIEREXT_H_

#include "r_soldierdata.h"

class CSoldierExt : public CSoldierData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierMap::iterator iter = id_soldier_map.begin();
            iter != id_soldier_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theSoldierExt TSignleton<CSoldierExt>::Ref()
#endif
