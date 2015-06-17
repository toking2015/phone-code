#ifndef IMMORTAL_COMMON_RESOURCE_R_MONSTEREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_MONSTEREXT_H_

#include "r_monsterdata.h"

class CMonsterExt : public CMonsterData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32MonsterMap::iterator iter = id_monster_map.begin();
            iter != id_monster_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theMonsterExt TSignleton<CMonsterExt>::Ref()
#endif
