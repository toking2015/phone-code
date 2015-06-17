#ifndef IMMORTAL_COMMON_RESOURCE_R_ITEMTYPEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ITEMTYPEEXT_H_

#include "r_itemtypedata.h"

class CItemTypeExt : public CItemTypeData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32ItemTypeMap::iterator iter = id_itemtype_map.begin();
            iter != id_itemtype_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theItemTypeExt TSignleton<CItemTypeExt>::Ref()
#endif
