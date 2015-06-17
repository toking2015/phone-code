#ifndef IMMORTAL_COMMON_RESOURCE_R_SIGNSUMEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_SIGNSUMEXT_H_

#include "r_signsumdata.h"

class CSignSumExt : public CSignSumData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32SignSumMap::iterator iter = id_signsum_map.begin();
            iter != id_signsum_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define theSignSumExt TSignleton<CSignSumExt>::Ref()
#endif
