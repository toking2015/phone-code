#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_trialrewardext.h"

std::vector<CTrialRewardData::SData*> CTrialRewardExt::GetRandomList(uint32 id, uint32 level)
{
    std::vector<CTrialRewardData::SData*> list;
    for( UInt32TrialRewardMap::iterator iter = id_trialreward_map.begin();
        iter != id_trialreward_map.end();
        ++iter )
    {
        if ( iter->second->trial_id != id )
            continue;

        if ( 0 != iter->second->level_rand.first || 0 != iter->second->level_rand.second )
        {
            if ( level < iter->second->level_rand.first || level > iter->second->level_rand.second )
                continue;
        }

        list.push_back(iter->second);
    }

    return list;
}
