#ifndef IMMORTAL_COMMON_RESOURCE_R_COPYMATERIALEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_COPYMATERIALEXT_H_

#include "r_copymaterialdata.h"

class CCopyMaterialExt : public CCopyMaterialData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32CopyMaterialMap::iterator iter = id_copymaterial_map.begin();
            iter != id_copymaterial_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theCopyMaterialExt TSignleton<CCopyMaterialExt>::Ref()
#endif
