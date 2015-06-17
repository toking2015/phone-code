#ifndef IMMORTAL_COMMON_RESOURCE_R_COPYREWARDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_COPYREWARDEXT_H_

#include "r_copyrewarddata.h"

class CCopyRewardExt : public CCopyRewardData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32CopyRewardMap::iterator iter = id_copyreward_map.begin();
            iter != id_copyreward_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theCopyRewardExt TSignleton<CCopyRewardExt>::Ref()
#endif
