#ifndef IMMORTAL_COMMON_RESOURCE_R_GUTEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_GUTEXT_H_

#include "r_gutdata.h"

class CGutExt : public CGutData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32GutMap::iterator iter = id_gut_map.begin();
            iter != id_gut_map.end();
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

#define theGutExt TSignleton<CGutExt>::Ref()
#endif
