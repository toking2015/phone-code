#ifndef IMMORTAL_COMMON_RESOURCE_R_PAPERCREATEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_PAPERCREATEEXT_H_

#include "r_papercreatedata.h"

class CPaperCreateExt : public CPaperCreateData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32PaperCreateMap::iterator iter = id_papercreate_map.begin();
            iter != id_papercreate_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define thePaperCreateExt TSignleton<CPaperCreateExt>::Ref()
#endif
