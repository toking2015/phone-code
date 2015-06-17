#ifndef IMMORTAL_COMMON_RESOURCE_R_BIASEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BIASEXT_H_

#include "r_biasdata.h"

class CBiasExt : public CBiasData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BiasMap::iterator iter = id_bias_map.begin();
            iter != id_bias_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theBiasExt TSignleton<CBiasExt>::Ref()
#endif
