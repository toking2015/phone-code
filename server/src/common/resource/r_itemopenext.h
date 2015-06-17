#ifndef IMMORTAL_COMMON_RESOURCE_R_ITEMOPENEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ITEMOPENEXT_H_

#include "r_itemopendata.h"

class CItemOpenExt : public CItemOpenData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32ItemOpenMap::iterator iter = id_itemopen_map.begin();
            iter != id_itemopen_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
    std::vector<CItemOpenData::SData*> GetRandomList(uint32 id, uint32 level);
};

#define theItemOpenExt TSignleton<CItemOpenExt>::Ref()
#endif
