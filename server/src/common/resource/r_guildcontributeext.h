#ifndef IMMORTAL_COMMON_RESOURCE_R_GUILDCONTRIBUTEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_GUILDCONTRIBUTEEXT_H_

#include "r_guildcontributedata.h"

class CGuildContributeExt : public CGuildContributeData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32GuildContributeMap::iterator iter = id_guildcontribute_map.begin();
            iter != id_guildcontribute_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theGuildContributeExt TSignleton<CGuildContributeExt>::Ref()
#endif
