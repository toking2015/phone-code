#include "jsonconfig.h"
#include "r_mysteryshopdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CMysteryShopData::CMysteryShopData()
{
}

CMysteryShopData::~CMysteryShopData()
{
    resource_clear(id_mysteryshop_map);
}

void CMysteryShopData::LoadData(void)
{
    CJson jc = CJson::Load( "MysteryShop" );

    theResDataMgr.insert(this);
    resource_clear(id_mysteryshop_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pmysteryshop                  = new SData;
        pmysteryshop->id                              = to_uint(aj[i]["id"]);
        pmysteryshop->min_level                       = to_uint(aj[i]["min_level"]);
        pmysteryshop->max_level                       = to_uint(aj[i]["max_level"]);
        pmysteryshop->rate                            = to_uint(aj[i]["rate"]);

        Add(pmysteryshop);
        ++count;
        LOG_DEBUG("id:%u,min_level:%u,max_level:%u,rate:%u,", pmysteryshop->id, pmysteryshop->min_level, pmysteryshop->max_level, pmysteryshop->rate);
    }
    LOG_INFO("MysteryShop.xls:%d", count);
}

void CMysteryShopData::ClearData(void)
{
    for( UInt32MysteryShopMap::iterator iter = id_mysteryshop_map.begin();
        iter != id_mysteryshop_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_mysteryshop_map.clear();
}

CMysteryShopData::SData* CMysteryShopData::Find( uint32 id )
{
    UInt32MysteryShopMap::iterator iter = id_mysteryshop_map.find(id);
    if ( iter != id_mysteryshop_map.end() )
        return iter->second;
    return NULL;
}

void CMysteryShopData::Add(SData* pmysteryshop)
{
    id_mysteryshop_map[pmysteryshop->id] = pmysteryshop;
}
