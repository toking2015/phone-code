#include "jsonconfig.h"
#include "r_buildingspeeddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBuildingSpeedData::CBuildingSpeedData()
{
}

CBuildingSpeedData::~CBuildingSpeedData()
{
    resource_clear(id_buildingspeed_map);
}

void CBuildingSpeedData::LoadData(void)
{
    CJson jc = CJson::Load( "BuildingSpeed" );

    theResDataMgr.insert(this);
    resource_clear(id_buildingspeed_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbuildingspeed                = new SData;
        pbuildingspeed->level                           = to_uint(aj[i]["level"]);
        pbuildingspeed->speed2                          = to_uint(aj[i]["speed2"]);
        pbuildingspeed->speed6                          = to_uint(aj[i]["speed6"]);

        Add(pbuildingspeed);
        ++count;
        LOG_DEBUG("level:%u,speed2:%u,speed6:%u,", pbuildingspeed->level, pbuildingspeed->speed2, pbuildingspeed->speed6);
    }
    LOG_INFO("BuildingSpeed.xls:%d", count);
}

void CBuildingSpeedData::ClearData(void)
{
    for( UInt32BuildingSpeedMap::iterator iter = id_buildingspeed_map.begin();
        iter != id_buildingspeed_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_buildingspeed_map.clear();
}

CBuildingSpeedData::SData* CBuildingSpeedData::Find( uint32 level )
{
    UInt32BuildingSpeedMap::iterator iter = id_buildingspeed_map.find(level);
    if ( iter != id_buildingspeed_map.end() )
        return iter->second;
    return NULL;
}

void CBuildingSpeedData::Add(SData* pbuildingspeed)
{
    id_buildingspeed_map[pbuildingspeed->level] = pbuildingspeed;
}
