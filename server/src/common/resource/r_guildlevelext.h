#ifndef IMMORTAL_COMMON_RESOURCE_R_GUILDLEVELEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_GUILDLEVELEXT_H_

#include "r_guildleveldata.h"

class CGuildLevelExt : public CGuildLevelData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32GuildLevelMap::iterator iter = id_guildlevel_map.begin();
            iter != id_guildlevel_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theGuildLevelExt TSignleton<CGuildLevelExt>::Ref()
#endif
