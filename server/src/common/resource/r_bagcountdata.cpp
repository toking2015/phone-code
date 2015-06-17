#include "jsonconfig.h"
#include "r_bagcountdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBagCountData::CBagCountData()
{
}

CBagCountData::~CBagCountData()
{
    resource_clear(id_bagcount_map);
}

void CBagCountData::LoadData(void)
{
    CJson jc = CJson::Load( "BagCount" );

    theResDataMgr.insert(this);
    resource_clear(id_bagcount_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbagcount                     = new SData;
        pbagcount->bag_type                        = to_uint(aj[i]["bag_type"]);
        pbagcount->bag_init                        = to_uint(aj[i]["bag_init"]);

        Add(pbagcount);
        ++count;
        LOG_DEBUG("bag_type:%u,bag_init:%u,", pbagcount->bag_type, pbagcount->bag_init);
    }
    LOG_INFO("BagCount.xls:%d", count);
}

void CBagCountData::ClearData(void)
{
    for( UInt32BagCountMap::iterator iter = id_bagcount_map.begin();
        iter != id_bagcount_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_bagcount_map.clear();
}

CBagCountData::SData* CBagCountData::Find( uint32 bag_type )
{
    UInt32BagCountMap::iterator iter = id_bagcount_map.find(bag_type);
    if ( iter != id_bagcount_map.end() )
        return iter->second;
    return NULL;
}

void CBagCountData::Add(SData* pbagcount)
{
    id_bagcount_map[pbagcount->bag_type] = pbagcount;
}
