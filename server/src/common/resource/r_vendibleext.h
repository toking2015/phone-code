#ifndef IMMORTAL_COMMON_RESOURCE_R_VENDIBLEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_VENDIBLEEXT_H_

#include "r_vendibledata.h"

class CVendibleExt : public CVendibleData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32VendibleMap::iterator iter = id_vendible_map.begin();
            iter != id_vendible_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theVendibleExt TSignleton<CVendibleExt>::Ref()
#endif
