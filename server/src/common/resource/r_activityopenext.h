#ifndef IMMORTAL_COMMON_RESOURCE_R_ACTIVITYOPENEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ACTIVITYOPENEXT_H_

#include "r_activityopendata.h"

class CActivityOpenExt : public CActivityOpenData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32ActivityOpenMap::iterator iter = id_activityopen_map.begin();
            iter != id_activityopen_map.end();
            ++iter )
        {
            for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
                jter != iter->second.end();
                ++jter )
            {
                if ( !call( jter->second ) )
                    break;
            }
        }
    }
};

#define theActivityOpenExt TSignleton<CActivityOpenExt>::Ref()
#endif
