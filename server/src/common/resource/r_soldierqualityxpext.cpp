#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_soldierqualityxpext.h"

CSoldierQualityXpData::SData* CSoldierQualityXpExt::Find( S3UInt32 &coin )
{
    for( UInt32SoldierQualityXpMap::iterator iter = id_soldierqualityxp_map.begin();
        iter != id_soldierqualityxp_map.end();
        ++iter )
    {
        if( coin.cate == iter->second->coin.cate && coin.objid == iter->second->coin.objid )
            return iter->second;
    }
    return NULL;
}

