#ifndef IMMORTAL_COMMON_RESOURCE_R_VIPPRIVILEGEEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_VIPPRIVILEGEEXT_H_

#include "r_vipprivilegedata.h"

class CVipPrivilegeExt : public CVipPrivilegeData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32VipPrivilegeMap::iterator iter = id_vipprivilege_map.begin();
            iter != id_vipprivilege_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theVipPrivilegeExt TSignleton<CVipPrivilegeExt>::Ref()
#endif
