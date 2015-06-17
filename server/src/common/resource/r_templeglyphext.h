#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHEXT_H_

#include "r_templeglyphdata.h"

class CTempleGlyphExt : public CTempleGlyphData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TempleGlyphMap::iterator iter = id_templeglyph_map.begin();
            iter != id_templeglyph_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTempleGlyphExt TSignleton<CTempleGlyphExt>::Ref()
#endif
