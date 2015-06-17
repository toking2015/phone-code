#ifndef IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDBASEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOMBREWARDBASEEXT_H_

#include "r_tombrewardbasedata.h"

class CTombRewardBaseExt : public CTombRewardBaseData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TombRewardBaseMap::iterator iter = id_tombrewardbase_map.begin();
            iter != id_tombrewardbase_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTombRewardBaseExt TSignleton<CTombRewardBaseExt>::Ref()
#endif
