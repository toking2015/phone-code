#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLESUITATTREXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLESUITATTREXT_H_

#include "r_templesuitattrdata.h"

class CTempleSuitAttrExt : public CTempleSuitAttrData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TempleSuitAttrMap::iterator iter = id_templesuitattr_map.begin();
            iter != id_templesuitattr_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    UInt32TempleSuitAttrMap GetAllList() { return id_templesuitattr_map; }
};

#define theTempleSuitAttrExt TSignleton<CTempleSuitAttrExt>::Ref()
#endif
