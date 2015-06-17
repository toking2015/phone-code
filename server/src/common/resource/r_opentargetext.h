#ifndef IMMORTAL_COMMON_RESOURCE_R_OPENTARGETEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_OPENTARGETEXT_H_

#include "r_opentargetdata.h"

class COpenTargetExt : public COpenTargetData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32OpenTargetMap::iterator iter = id_opentarget_map.begin();
            iter != id_opentarget_map.end();
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

    void    FindList( uint32 day, std::vector< COpenTargetData::SData* > &list );
};

#define theOpenTargetExt TSignleton<COpenTargetExt>::Ref()
#endif
