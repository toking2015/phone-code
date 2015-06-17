#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_soldierqualityext.h"

std::map<uint32,uint32> CSoldierQualityExt::CheckXpUp( uint32 lv, uint32 xp, uint32 target_lv )
{
    std::map<uint32,uint32> xp_map;
    for ( UInt32SoldierQualityMap::iterator iter = id_soldierquality_map.begin();
        iter != id_soldierquality_map.end();
        ++iter )
    {
        if ( iter->second->lv > target_lv )
            break;

        if ( iter->second->lv < lv )
            continue;

        if ( iter->second->lv == lv && xp < iter->second->xp )
            xp_map[iter->second->lv] = iter->second->xp - xp;
        else if ( iter->second->lv > lv )
            xp_map[iter->second->lv] = iter->second->xp;
    }

    return xp_map;
}
