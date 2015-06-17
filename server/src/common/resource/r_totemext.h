#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMEXT_H_

#include "r_totemdata.h"

class CTotemExt : public CTotemData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TotemMap::iterator iter = id_totem_map.begin();
            iter != id_totem_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTotemExt TSignleton<CTotemExt>::Ref()
#endif
