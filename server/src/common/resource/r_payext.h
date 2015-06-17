#ifndef IMMORTAL_COMMON_RESOURCE_R_PAYEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_PAYEXT_H_

#include "r_paydata.h"

class CPayExt : public CPayData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32PayMap::iterator iter = id_pay_map.begin();
            iter != id_pay_map.end();
            ++iter )
        {
            if ( !call( *iter ) )
                break;
        }
    }
};

#define thePayExt TSignleton<CPayExt>::Ref()
#endif
