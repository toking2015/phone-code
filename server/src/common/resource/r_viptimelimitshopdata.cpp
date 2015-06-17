#include "jsonconfig.h"
#include "r_viptimelimitshopdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CVipTimeLimitShopData::CVipTimeLimitShopData()
{
}

CVipTimeLimitShopData::~CVipTimeLimitShopData()
{
    resource_clear(id_viptimelimitshop_map);
}

void CVipTimeLimitShopData::LoadData(void)
{
    CJson jc = CJson::Load( "VipTimeLimitShop" );

    theResDataMgr.insert(this);
    resource_clear(id_viptimelimitshop_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pviptimelimitshop             = new SData;
        pviptimelimitshop->id                              = to_uint(aj[i]["id"]);
        pviptimelimitshop->level                           = to_uint(aj[i]["level"]);
        S3UInt32 item;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "item%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &item.cate, &item.objid, &item.val ) )
                break;
            pviptimelimitshop->item.push_back(item);
        }
        std::string discount_price_string = aj[i]["discount_price"].asString();
        sscanf( discount_price_string.c_str(), "%u%%%u%%%u", &pviptimelimitshop->discount_price.cate, &pviptimelimitshop->discount_price.objid, &pviptimelimitshop->discount_price.val );
        std::string real_price_string = aj[i]["real_price"].asString();
        sscanf( real_price_string.c_str(), "%u%%%u%%%u", &pviptimelimitshop->real_price.cate, &pviptimelimitshop->real_price.objid, &pviptimelimitshop->real_price.val );

        Add(pviptimelimitshop);
        ++count;
        LOG_DEBUG("id:%u,level:%u,", pviptimelimitshop->id, pviptimelimitshop->level);
    }
    LOG_INFO("VipTimeLimitShop.xls:%d", count);
}

void CVipTimeLimitShopData::ClearData(void)
{
    for( UInt32VipTimeLimitShopMap::iterator iter = id_viptimelimitshop_map.begin();
        iter != id_viptimelimitshop_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_viptimelimitshop_map.clear();
}

CVipTimeLimitShopData::SData* CVipTimeLimitShopData::Find( uint32 id,uint32 level )
{
    return id_viptimelimitshop_map[id][level];
}

void CVipTimeLimitShopData::Add(SData* pviptimelimitshop)
{
    id_viptimelimitshop_map[pviptimelimitshop->id][pviptimelimitshop->level] = pviptimelimitshop;
}
