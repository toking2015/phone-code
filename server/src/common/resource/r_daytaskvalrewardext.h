#ifndef IMMORTAL_COMMON_RESOURCE_R_DAYTASKVALREWARDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_DAYTASKVALREWARDEXT_H_

#include "r_daytaskvalrewarddata.h"

class CDayTaskValRewardExt : public CDayTaskValRewardData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32DayTaskValRewardMap::iterator iter = id_daytaskvalreward_map.begin();
            iter != id_daytaskvalreward_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theDayTaskValRewardExt TSignleton<CDayTaskValRewardExt>::Ref()
#endif
