#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYOCCUEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYOCCUEXT_H_

#include "r_soldierqualityoccudata.h"

class CSoldierQualityOccuExt : public CSoldierQualityOccuData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierQualityOccuMap::iterator iter = id_soldierqualityoccu_map.begin();
            iter != id_soldierqualityoccu_map.end();
            ++iter )
        {
            for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
                jter != iter->second.end();
                ++jter )
            {
                if ( !call( jter->second ) )
                    break;
            }
        }
    }
};

#define theSoldierQualityOccuExt TSignleton<CSoldierQualityOccuExt>::Ref()
#endif
