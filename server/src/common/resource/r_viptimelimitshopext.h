#ifndef IMMORTAL_COMMON_RESOURCE_R_VIPTIMELIMITSHOPEXT_H_
#define IMMORTAL_COMMON_RESOURCE_R_VIPTIMELIMITSHOPEXT_H_

#include "r_viptimelimitshopdata.h"

class CVipTimeLimitShopExt : public CVipTimeLimitShopData
{
public:
    template< typename T >
    void Each( T call )
    {
        for ( UInt32VipTimeLimitShopMap::iterator iter = id_viptimelimitshop_map.begin();
            iter != id_viptimelimitshop_map.end();
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
    uint32 FindMaxWeeks( );
};

#define theVipTimeLimitShopExt TSignleton<CVipTimeLimitShopExt>::Ref()
#endif
