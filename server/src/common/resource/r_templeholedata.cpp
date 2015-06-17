#include "jsonconfig.h"
#include "r_templeholedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTempleHoleData::CTempleHoleData()
{
}

CTempleHoleData::~CTempleHoleData()
{
    resource_clear(id_templehole_map);
}

void CTempleHoleData::LoadData(void)
{
    CJson jc = CJson::Load( "TempleHole" );

    theResDataMgr.insert(this);
    resource_clear(id_templehole_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptemplehole                   = new SData;
        ptemplehole->id                              = to_uint(aj[i]["id"]);
        ptemplehole->level                           = to_uint(aj[i]["level"]);
        S3UInt32 cost_item;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "cost_item%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &cost_item.cate, &cost_item.objid, &cost_item.val ) )
                break;
            ptemplehole->cost_item.push_back(cost_item);
        }
        S3UInt32 cost_coin;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "cost_coin%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &cost_coin.cate, &cost_coin.objid, &cost_coin.val ) )
                break;
            ptemplehole->cost_coin.push_back(cost_coin);
        }

        Add(ptemplehole);
        ++count;
        LOG_DEBUG("id:%u,level:%u,", ptemplehole->id, ptemplehole->level);
    }
    LOG_INFO("TempleHole.xls:%d", count);
}

void CTempleHoleData::ClearData(void)
{
    for( UInt32TempleHoleMap::iterator iter = id_templehole_map.begin();
        iter != id_templehole_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_templehole_map.clear();
}

CTempleHoleData::SData* CTempleHoleData::Find( uint32 id )
{
    UInt32TempleHoleMap::iterator iter = id_templehole_map.find(id);
    if ( iter != id_templehole_map.end() )
        return iter->second;
    return NULL;
}

void CTempleHoleData::Add(SData* ptemplehole)
{
    id_templehole_map[ptemplehole->id] = ptemplehole;
}
