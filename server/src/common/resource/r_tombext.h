#ifndef IMMORTAL_COMMON_RESOURCE_R_TOMBEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOMBEXT_H_

#include "r_tombdata.h"

class CTombExt : public CTombData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TombMap::iterator iter = id_tomb_map.begin();
            iter != id_tomb_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTombExt TSignleton<CTombExt>::Ref()
#endif
