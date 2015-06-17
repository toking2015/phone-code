#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERBASEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERBASEEXT_H_

#include "r_soldierbasedata.h"

class CSoldierBaseExt : public CSoldierBaseData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierBaseMap::iterator iter = id_soldierbase_map.begin();
            iter != id_soldierbase_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theSoldierBaseExt TSignleton<CSoldierBaseExt>::Ref()
#endif
