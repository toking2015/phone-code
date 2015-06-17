#ifndef IMMORTAL_COMMON_RESOURCE_R_RANKCOPYEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_RANKCOPYEXT_H_

#include "r_rankcopydata.h"

class CRankCopyExt : public CRankCopyData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32RankCopyMap::iterator iter = id_rankcopy_map.begin();
            iter != id_rankcopy_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theRankCopyExt TSignleton<CRankCopyExt>::Ref()
#endif
