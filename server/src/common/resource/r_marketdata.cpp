#include "jsonconfig.h"
#include "r_marketdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CMarketData::CMarketData()
{
}

CMarketData::~CMarketData()
{
    resource_clear(id_market_map);
}

void CMarketData::LoadData(void)
{
    CJson jc = CJson::Load( "Market" );

    theResDataMgr.insert(this);
    resource_clear(id_market_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pmarket                       = new SData;
        pmarket->item_id                         = to_uint(aj[i]["item_id"]);
        pmarket->type                            = to_uint(aj[i]["type"]);
        pmarket->level                           = to_uint(aj[i]["level"]);
        pmarket->group                           = to_uint(aj[i]["group"]);
        pmarket->value                           = to_uint(aj[i]["value"]);

        Add(pmarket);
        ++count;
        LOG_DEBUG("item_id:%u,type:%u,level:%u,group:%u,value:%u,", pmarket->item_id, pmarket->type, pmarket->level, pmarket->group, pmarket->value);
    }
    LOG_INFO("Market.xls:%d", count);
}

void CMarketData::ClearData(void)
{
    for( UInt32MarketMap::iterator iter = id_market_map.begin();
        iter != id_market_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_market_map.clear();
}

CMarketData::SData* CMarketData::Find( uint32 item_id )
{
    UInt32MarketMap::iterator iter = id_market_map.find(item_id);
    if ( iter != id_market_map.end() )
        return iter->second;
    return NULL;
}

void CMarketData::Add(SData* pmarket)
{
    id_market_map[pmarket->item_id] = pmarket;
}
