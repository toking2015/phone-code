#ifndef IMMORTAL_COMMON_RESOURCE_R_ITEMEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ITEMEXT_H_

#include "r_itemdata.h"

class CItemExt : public CItemData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32ItemMap::iterator iter = id_item_map.begin();
            iter != id_item_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theItemExt TSignleton<CItemExt>::Ref()
#endif
