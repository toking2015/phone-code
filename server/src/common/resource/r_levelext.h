#ifndef IMMORTAL_COMMON_RESOURCE_R_LEVELEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_LEVELEXT_H_

#include "r_leveldata.h"

class CLevelExt : public CLevelData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32LevelMap::iterator iter = id_level_map.begin();
            iter != id_level_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    uint32 GetVipLevel( uint32 xp );
};

#define theLevelExt TSignleton<CLevelExt>::Ref()
#endif
