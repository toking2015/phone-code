#ifndef IMMORTAL_COMMON_RESOURCE_R_ITEMMERGEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ITEMMERGEEXT_H_

#include "r_itemmergedata.h"

class CItemMergeExt : public CItemMergeData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32ItemMergeMap::iterator iter = id_itemmerge_map.begin();
            iter != id_itemmerge_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theItemMergeExt TSignleton<CItemMergeExt>::Ref()
#endif
