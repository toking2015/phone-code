#include "jsonconfig.h"
#include "r_buildingcostdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBuildingCostData::CBuildingCostData()
{
}

CBuildingCostData::~CBuildingCostData()
{
    resource_clear(id_buildingcost_map);
}

void CBuildingCostData::LoadData(void)
{
    CJson jc = CJson::Load( "BuildingCost" );

    theResDataMgr.insert(this);
    resource_clear(id_buildingcost_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbuildingcost                 = new SData;
        pbuildingcost->times                           = to_uint(aj[i]["times"]);
        std::string cost2_string = aj[i]["cost2"].asString();
        sscanf( cost2_string.c_str(), "%u%%%u%%%u", &pbuildingcost->cost2.cate, &pbuildingcost->cost2.objid, &pbuildingcost->cost2.val );
        std::string cost6_string = aj[i]["cost6"].asString();
        sscanf( cost6_string.c_str(), "%u%%%u%%%u", &pbuildingcost->cost6.cate, &pbuildingcost->cost6.objid, &pbuildingcost->cost6.val );

        Add(pbuildingcost);
        ++count;
        LOG_DEBUG("times:%u,", pbuildingcost->times);
    }
    LOG_INFO("BuildingCost.xls:%d", count);
}

void CBuildingCostData::ClearData(void)
{
    for( UInt32BuildingCostMap::iterator iter = id_buildingcost_map.begin();
        iter != id_buildingcost_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_buildingcost_map.clear();
}

CBuildingCostData::SData* CBuildingCostData::Find( uint32 times )
{
    UInt32BuildingCostMap::iterator iter = id_buildingcost_map.find(times);
    if ( iter != id_buildingcost_map.end() )
        return iter->second;
    return NULL;
}

void CBuildingCostData::Add(SData* pbuildingcost)
{
    id_buildingcost_map[pbuildingcost->times] = pbuildingcost;
}
