#ifndef IMMORTAL_COMMON_RESOURCE_R_TRIALEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TRIALEXT_H_

#include "r_trialdata.h"

class CTrialExt : public CTrialData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TrialMap::iterator iter = id_trial_map.begin();
            iter != id_trial_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTrialExt TSignleton<CTrialExt>::Ref()
#endif
