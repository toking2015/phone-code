#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_itemopenext.h"

std::vector<CItemOpenData::SData*> CItemOpenExt::GetRandomList(uint32 id, uint32 level)
{
    std::vector<CItemOpenData::SData*> list;
    for( UInt32ItemOpenMap::iterator iter = id_itemopen_map.begin();
        iter != id_itemopen_map.end();
        ++iter )
    {
        if ( iter->second->open_id != id )
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
