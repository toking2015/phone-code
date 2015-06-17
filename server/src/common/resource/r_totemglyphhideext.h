#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHHIDEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHHIDEEXT_H_

#include "r_totemglyphhidedata.h"

class CTotemGlyphHideExt : public CTotemGlyphHideData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TotemGlyphHideMap::iterator iter = id_totemglyphhide_map.begin();
            iter != id_totemglyphhide_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    S2UInt32 RandAttr();
};

#define theTotemGlyphHideExt TSignleton<CTotemGlyphHideExt>::Ref()
#endif
