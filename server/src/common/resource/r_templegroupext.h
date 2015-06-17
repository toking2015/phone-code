#ifndef IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_TEMPLEGROUPEXT_H_

#include "r_templegroupdata.h"

class CTempleGroupExt : public CTempleGroupData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32TempleGroupMap::iterator iter = id_templegroup_map.begin();
            iter != id_templegroup_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }

    UInt32TempleGroupMap& GetGroups() { return id_templegroup_map; }
};

#define theTempleGroupExt TSignleton<CTempleGroupExt>::Ref()
#endif
