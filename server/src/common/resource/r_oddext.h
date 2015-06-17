#ifndef IMMORTAL_COMMON_RESOURCE_R_ODDEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_ODDEXT_H_

#include "r_odddata.h"

class COddExt : public COddData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32OddMap::iterator iter = id_odd_map.begin();
            iter != id_odd_map.end();
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

#define theOddExt TSignleton<COddExt>::Ref()
#endif
