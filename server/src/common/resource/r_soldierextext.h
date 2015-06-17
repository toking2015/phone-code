#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIEREXTEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIEREXTEXT_H_

#include "r_soldierextdata.h"

class CSoldierExtExt : public CSoldierExtData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierExtMap::iterator iter = id_soldierext_map.begin();
            iter != id_soldierext_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

public:
    uint32 GetMaxLevel( std::vector< uint32 >& list );
    uint32 GetSumFighting( std::vector< uint32 >& list );
};

#define theSoldierExtExt TSignleton<CSoldierExtExt>::Ref()
#endif
