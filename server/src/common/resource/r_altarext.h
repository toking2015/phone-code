#ifndef IMMORTAL_COMMON_RESOURCE_R_ALTAREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ALTAREXT_H_

#include "r_altardata.h"

class CAltarExt : public CAltarData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32AltarMap::iterator iter = id_altar_map.begin();
            iter != id_altar_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    const CAltarData::UInt32AltarMap& GetAltarList() { return id_altar_map; }
};

#define theAltarExt TSignleton<CAltarExt>::Ref()
#endif
