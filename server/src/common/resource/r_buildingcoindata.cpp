#include "jsonconfig.h"
#include "r_buildingcoindata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBuildingCoinData::CBuildingCoinData()
{
}

CBuildingCoinData::~CBuildingCoinData()
{
    resource_clear(id_buildingcoin_map);
}

void CBuildingCoinData::LoadData(void)
{
    CJson jc = CJson::Load( "BuildingCoin" );

    theResDataMgr.insert(this);
    resource_clear(id_buildingcoin_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbuildingcoin                 = new SData;
        pbuildingcoin->building                        = to_uint(aj[i]["building"]);
        S3UInt32 value;
        for ( uint32 j = 1; j <= 10; ++j )
        {
            std::string buff = strprintf( "value%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &value.cate, &value.objid, &value.val ) )
                break;
            pbuildingcoin->value.push_back(value);
        }

        Add(pbuildingcoin);
        ++count;
        LOG_DEBUG("building:%u,", pbuildingcoin->building);
    }
    LOG_INFO("BuildingCoin.xls:%d", count);
}

void CBuildingCoinData::ClearData(void)
{
    for( UInt32BuildingCoinMap::iterator iter = id_buildingcoin_map.begin();
        iter != id_buildingcoin_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_buildingcoin_map.clear();
}

CBuildingCoinData::SData* CBuildingCoinData::Find( uint32 building )
{
    UInt32BuildingCoinMap::iterator iter = id_buildingcoin_map.find(building);
    if ( iter != id_buildingcoin_map.end() )
        return iter->second;
    return NULL;
}

void CBuildingCoinData::Add(SData* pbuildingcoin)
{
    id_buildingcoin_map[pbuildingcoin->building] = pbuildingcoin;
}
