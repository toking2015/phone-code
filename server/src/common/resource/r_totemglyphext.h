#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMGLYPHEXT_H_

#include "r_totemglyphdata.h"

class CTotemGlyphExt : public CTotemGlyphData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TotemGlyphMap::iterator iter = id_totemglyph_map.begin();
            iter != id_totemglyph_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTotemGlyphExt TSignleton<CTotemGlyphExt>::Ref()
#endif
