#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_singlearenadayrewardext.h"

void CSingleArenaDayRewardExt::GetReward( uint32 rank,std::vector<S3UInt32> &list)
{
    for( UInt32SingleArenaDayRewardMap::iterator iter = id_singlearenadayreward_map.begin();
    iter != id_singlearenadayreward_map.end();
    ++iter )
    {
        if( rank >= iter->second->rank.first && rank <= iter->second->rank.second )
        {
            list = iter->second->reward_;
            return;
        }
    }
}

