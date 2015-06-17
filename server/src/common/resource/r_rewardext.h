#ifndef IMMORTAL_COMMON_RESOURCE_R_REWARDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_REWARDEXT_H_

#include "r_rewarddata.h"

class CRewardExt : public CRewardData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32RewardMap::iterator iter = id_reward_map.begin();
            iter != id_reward_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theRewardExt TSignleton<CRewardExt>::Ref()
#endif
