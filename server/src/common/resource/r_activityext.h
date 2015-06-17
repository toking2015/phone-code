#ifndef IMMORTAL_COMMON_RESOURCE_R_ACTIVITYEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ACTIVITYEXT_H_

#include "r_activitydata.h"

class CActivityExt : public CActivityData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32ActivityMap::iterator iter = id_activity_map.begin();
            iter != id_activity_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theActivityExt TSignleton<CActivityExt>::Ref()
#endif
