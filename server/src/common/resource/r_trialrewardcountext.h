#ifndef IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDCOUNTEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TRIALREWARDCOUNTEXT_H_

#include "r_trialrewardcountdata.h"

class CTrialRewardCountExt : public CTrialRewardCountData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TrialRewardCountMap::iterator iter = id_trialrewardcount_map.begin();
            iter != id_trialrewardcount_map.end();
            ++iter )
        {
            for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
                jter != iter->second.end();
                ++jter )
            {
                if ( !call( jter->second ) )
                    break;
            }
        }
    }
};

#define theTrialRewardCountExt TSignleton<CTrialRewardCountExt>::Ref()
#endif
