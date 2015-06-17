#ifndef IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYXPEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SOLDIERQUALITYXPEXT_H_

#include "r_soldierqualityxpdata.h"

class CSoldierQualityXpExt : public CSoldierQualityXpData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SoldierQualityXpMap::iterator iter = id_soldierqualityxp_map.begin();
            iter != id_soldierqualityxp_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    CSoldierQualityXpData::SData* Find( S3UInt32 &coin );
};

#define theSoldierQualityXpExt TSignleton<CSoldierQualityXpExt>::Ref()
#endif
