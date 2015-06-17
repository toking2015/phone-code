#ifndef IMMORTAL_COMMON_RESOURCE_R_FORMATIONINDEXEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_FORMATIONINDEXEXT_H_

#include "r_formationindexdata.h"

class CFormationIndexExt : public CFormationIndexData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32FormationIndexMap::iterator iter = id_formationindex_map.begin();
            iter != id_formationindex_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theFormationIndexExt TSignleton<CFormationIndexExt>::Ref()
#endif
