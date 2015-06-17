#ifndef IMMORTAL_COMMON_RESOURCE_R_SIGNDAYEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SIGNDAYEXT_H_

#include "r_signdaydata.h"

class CSignDayExt : public CSignDayData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SignDayMap::iterator iter = id_signday_map.begin();
            iter != id_signday_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theSignDayExt TSignleton<CSignDayExt>::Ref()
#endif
