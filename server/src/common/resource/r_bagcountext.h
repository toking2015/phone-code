#ifndef IMMORTAL_COMMON_RESOURCE_R_BAGCOUNTEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_BAGCOUNTEXT_H_

#include "r_bagcountdata.h"

class CBagCountExt : public CBagCountData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32BagCountMap::iterator iter = id_bagcount_map.begin();
            iter != id_bagcount_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theBagCountExt TSignleton<CBagCountExt>::Ref()
#endif
