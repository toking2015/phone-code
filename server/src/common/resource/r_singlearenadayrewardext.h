#ifndef IMMORTAL_COMMON_RESOURCE_R_SINGLEARENADAYREWARDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SINGLEARENADAYREWARDEXT_H_

#include "r_singlearenadayrewarddata.h"

class CSingleArenaDayRewardExt : public CSingleArenaDayRewardData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SingleArenaDayRewardMap::iterator iter = id_singlearenadayreward_map.begin();
            iter != id_singlearenadayreward_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
    void GetReward( uint32 rank,std::vector<S3UInt32> &list);
};

#define theSingleArenaDayRewardExt TSignleton<CSingleArenaDayRewardExt>::Ref()
#endif
