#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERRECRUITEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERRECRUITEXT_H_

#include "r_soldierrecruitdata.h"

class CSoldierRecruitExt : public CSoldierRecruitData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierRecruitMap::iterator iter = id_soldierrecruit_map.begin();
            iter != id_soldierrecruit_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theSoldierRecruitExt TSignleton<CSoldierRecruitExt>::Ref()
#endif
