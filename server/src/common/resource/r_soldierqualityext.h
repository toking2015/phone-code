#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYEXT_H_

#include "r_soldierqualitydata.h"

class CSoldierQualityExt : public CSoldierQualityData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierQualityMap::iterator iter = id_soldierquality_map.begin();
            iter != id_soldierquality_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    std::map<uint32,uint32> CheckXpUp( uint32 lv, uint32 xp, uint32 target_lv );
};

#define theSoldierQualityExt TSignleton<CSoldierQualityExt>::Ref()
#endif
