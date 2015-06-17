#ifndef IMMORTAL_COMMON_RESOURCE_R_TOMBMONSTERLVEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TOMBMONSTERLVEXT_H_

#include "r_tombmonsterlvdata.h"

class CTombMonsterLvExt : public CTombMonsterLvData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TombMonsterLvMap::iterator iter = id_tombmonsterlv_map.begin();
            iter != id_tombmonsterlv_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theTombMonsterLvExt TSignleton<CTombMonsterLvExt>::Ref()
#endif
