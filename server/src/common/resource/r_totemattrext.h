#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMATTREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMATTREXT_H_

#include "r_totemattrdata.h"

class CTotemAttrExt : public CTotemAttrData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TotemAttrMap::iterator iter = id_totemattr_map.begin();
            iter != id_totemattr_map.end();
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

#define theTotemAttrExt TSignleton<CTotemAttrExt>::Ref()
#endif
