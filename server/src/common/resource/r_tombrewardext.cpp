#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_tombrewardext.h"

std::vector<CTombRewardData::SData*> CTombRewardExt::GetRandomList( uint32 quality, uint32 level)
{
    std::vector<CTombRewardData::SData*> list;
    for( UInt32TombRewardMap::iterator iter = id_tombreward_map.begin();
        iter != id_tombreward_map.end();
        ++iter )
    {
        if ( iter->second->quality != quality )
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
