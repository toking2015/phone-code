#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_levelext.h"

uint32 CLevelExt::GetVipLevel( uint32 xp )
{
    uint32 level = 0;
    for(  UInt32LevelMap::iterator iter = id_level_map.begin();
        iter != id_level_map.end();
        ++iter )
    {
        if( 0 == iter->second->level || 0 == iter->second->vip_xp )
            continue;

        if( xp < iter->second->vip_xp )
            return level;

        level = iter->second->level;
    }

    return level;
}
