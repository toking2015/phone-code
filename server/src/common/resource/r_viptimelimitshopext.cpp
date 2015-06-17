#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_viptimelimitshopext.h"

uint32 CVipTimeLimitShopExt::FindMaxWeeks( )
{
    uint32 max = 0;
    UInt32VipTimeLimitShopMap::reverse_iterator iter = id_viptimelimitshop_map.rbegin();
    if( iter == id_viptimelimitshop_map.rend() )
        max = 0;
    else
    {
        for( std::map<uint32,SData*>::iterator jter = iter->second.begin(); jter != iter->second.end(); ++iter )
        {
            if( jter == iter->second.end() )
                max = 0;
            else
                max = (jter->second)->id;
        }
    }
    return max;
}

