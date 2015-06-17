#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLESCOREREWARDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLESCOREREWARDEXT_H_

#include "r_templescorerewarddata.h"

class CTempleScoreRewardExt : public CTempleScoreRewardData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TempleScoreRewardMap::iterator iter = id_templescorereward_map.begin();
            iter != id_templescorereward_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTempleScoreRewardExt TSignleton<CTempleScoreRewardExt>::Ref()
#endif
