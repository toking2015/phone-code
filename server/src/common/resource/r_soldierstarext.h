#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERSTAREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERSTAREXT_H_

#include "r_soldierstardata.h"

class CSoldierStarExt : public CSoldierStarData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierStarMap::iterator iter = id_soldierstar_map.begin();
            iter != id_soldierstar_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theSoldierStarExt TSignleton<CSoldierStarExt>::Ref()
#endif
