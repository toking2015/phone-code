#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERLVEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERLVEXT_H_

#include "r_soldierlvdata.h"

class CSoldierLvExt : public CSoldierLvData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierLvMap::iterator iter = id_soldierlv_map.begin();
            iter != id_soldierlv_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theSoldierLvExt TSignleton<CSoldierLvExt>::Ref()
#endif
