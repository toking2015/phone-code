#ifndef IMMORTAL_COMMON_RESOURCE_R_TOTEMEXTEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOTEMEXTEXT_H_

#include "r_totemextdata.h"

class CTotemExtExt : public CTotemExtData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TotemExtMap::iterator iter = id_totemext_map.begin();
            iter != id_totemext_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTotemExtExt TSignleton<CTotemExtExt>::Ref()
#endif
