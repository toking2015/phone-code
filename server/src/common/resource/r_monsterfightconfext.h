#ifndef IMMORTAL_COMMON_RESOURCE_R_MONSTERFIGHTCONFEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_MONSTERFIGHTCONFEXT_H_

#include "r_monsterfightconfdata.h"

class CMonsterFightConfExt : public CMonsterFightConfData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32MonsterFightConfMap::iterator iter = id_monsterfightconf_map.begin();
            iter != id_monsterfightconf_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theMonsterFightConfExt TSignleton<CMonsterFightConfExt>::Ref()
#endif
