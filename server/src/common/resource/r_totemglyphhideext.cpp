#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_totemglyphhideext.h"

S2UInt32 CTotemGlyphHideExt::RandAttr()
{
    uint32 rand = TRand((uint32)0, (uint32)id_totemglyphhide_map.size());
    for(UInt32TotemGlyphHideMap::iterator iter = id_totemglyphhide_map.begin(); iter != id_totemglyphhide_map.end(); ++iter)
    {
        if(rand == 0)
        {
            return iter->second->attr;
        }
        else
        {
            --rand;
        }
    }

    S2UInt32 s;
    return s;
}
