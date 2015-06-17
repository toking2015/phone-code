#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPLEVELUPEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPLEVELUPEXT_H_

#include "r_templegrouplevelupdata.h"

class CTempleGroupLevelUpExt : public CTempleGroupLevelUpData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TempleGroupLevelUpMap::iterator iter = id_templegrouplevelup_map.begin();
            iter != id_templegrouplevelup_map.end();
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

    std::map<uint32, CTempleGroupLevelUpData::SData*> GetGroupLevelUp(uint32 id) { return id_templegrouplevelup_map[id]; }
};

#define theTempleGroupLevelUpExt TSignleton<CTempleGroupLevelUpExt>::Ref()
#endif
