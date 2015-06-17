#ifndef IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDEXT_H_

#include "r_trialrewarddata.h"

class CTrialRewardExt : public CTrialRewardData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TrialRewardMap::iterator iter = id_trialreward_map.begin();
            iter != id_trialreward_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    std::vector<CTrialRewardData::SData*> GetRandomList(uint32 id, uint32 level);
};

#define theTrialRewardExt TSignleton<CTrialRewardExt>::Ref()
#endif
