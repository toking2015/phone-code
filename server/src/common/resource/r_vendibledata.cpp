#include "jsonconfig.h"
#include "r_vendibledata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CVendibleData::CVendibleData()
{
}

CVendibleData::~CVendibleData()
{
    resource_clear(id_vendible_map);
}

void CVendibleData::LoadData(void)
{
    CJson jc = CJson::Load( "Vendible" );

    theResDataMgr.insert(this);
    resource_clear(id_vendible_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pvendible                     = new SData;
        pvendible->id                              = to_uint(aj[i]["id"]);
        std::string goods_string = aj[i]["goods"].asString();
        sscanf( goods_string.c_str(), "%u%%%u%%%u", &pvendible->goods.cate, &pvendible->goods.objid, &pvendible->goods.val );
        pvendible->item_id                         = to_uint(aj[i]["item_id"]);
        pvendible->count                           = to_uint(aj[i]["count"]);
        pvendible->shop_type                       = to_uint(aj[i]["shop_type"]);
        std::string fake_price_string = aj[i]["fake_price"].asString();
        sscanf( fake_price_string.c_str(), "%u%%%u%%%u", &pvendible->fake_price.cate, &pvendible->fake_price.objid, &pvendible->fake_price.val );
        std::string price_string = aj[i]["price"].asString();
        sscanf( price_string.c_str(), "%u%%%u%%%u", &pvendible->price.cate, &pvendible->price.objid, &pvendible->price.val );
        pvendible->history_limit_count             = to_uint(aj[i]["history_limit_count"]);
        pvendible->daily_limit_count               = to_uint(aj[i]["daily_limit_count"]);
        pvendible->server_limit_count              = to_uint(aj[i]["server_limit_count"]);
        pvendible->win_times_limit                 = to_uint(aj[i]["win_times_limit"]);

        Add(pvendible);
        ++count;
        LOG_DEBUG("id:%u,item_id:%u,count:%u,shop_type:%u,history_limit_count:%u,daily_limit_count:%u,server_limit_count:%u,win_times_limit:%u,", pvendible->id, pvendible->item_id, pvendible->count, pvendible->shop_type, pvendible->history_limit_count, pvendible->daily_limit_count, pvendible->server_limit_count, pvendible->win_times_limit);
    }
    LOG_INFO("Vendible.xls:%d", count);
}

void CVendibleData::ClearData(void)
{
    for( UInt32VendibleMap::iterator iter = id_vendible_map.begin();
        iter != id_vendible_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_vendible_map.clear();
}

CVendibleData::SData* CVendibleData::Find( uint32 id )
{
    UInt32VendibleMap::iterator iter = id_vendible_map.find(id);
    if ( iter != id_vendible_map.end() )
        return iter->second;
    return NULL;
}

void CVendibleData::Add(SData* pvendible)
{
    id_vendible_map[pvendible->id] = pvendible;
}
