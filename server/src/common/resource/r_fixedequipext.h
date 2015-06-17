#ifndef IMMORTAL_COMMON_RESOURCE_R_FIXEDEQUIPEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_FIXEDEQUIPEXT_H_

#include "r_fixedequipdata.h"

class CFixedEquipExt : public CFixedEquipData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32FixedEquipMap::iterator iter = id_fixedequip_map.begin();
            iter != id_fixedequip_map.end();
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

#define theFixedEquipExt TSignleton<CFixedEquipExt>::Ref()
#endif
