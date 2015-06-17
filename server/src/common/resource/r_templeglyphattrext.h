#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHATTREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEGLYPHATTREXT_H_

#include "r_templeglyphattrdata.h"

class CTempleGlyphAttrExt : public CTempleGlyphAttrData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TempleGlyphAttrMap::iterator iter = id_templeglyphattr_map.begin();
            iter != id_templeglyphattr_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    std::map<uint32, CTempleGlyphAttrData::SData*> GetGlyphAttrs(uint32 id) { return id_templeglyphattr_map[id]; }
};

#define theTempleGlyphAttrExt TSignleton<CTempleGlyphAttrExt>::Ref()
#endif
