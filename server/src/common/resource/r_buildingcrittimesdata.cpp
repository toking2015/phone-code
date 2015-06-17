#include "jsonconfig.h"
#include "r_buildingcrittimesdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBuildingCritTimesData::CBuildingCritTimesData()
{
}

CBuildingCritTimesData::~CBuildingCritTimesData()
{
    resource_clear(id_buildingcrittimes_map);
}

void CBuildingCritTimesData::LoadData(void)
{
    CJson jc = CJson::Load( "BuildingCritTimes" );

    theResDataMgr.insert(this);
    resource_clear(id_buildingcrittimes_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbuildingcrittimes            = new SData;
        pbuildingcrittimes->building_type                   = to_uint(aj[i]["building_type"]);
        S2UInt32 times;
        for ( uint32 j = 1; j <= 10; ++j )
        {
            std::string buff = strprintf( "times%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &times.first, &times.second ) )
                break;
            pbuildingcrittimes->times.push_back(times);
        }

        Add(pbuildingcrittimes);
        ++count;
        LOG_DEBUG("building_type:%u,", pbuildingcrittimes->building_type);
    }
    LOG_INFO("BuildingCritTimes.xls:%d", count);
}

void CBuildingCritTimesData::ClearData(void)
{
    for( UInt32BuildingCritTimesMap::iterator iter = id_buildingcrittimes_map.begin();
        iter != id_buildingcrittimes_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_buildingcrittimes_map.clear();
}

CBuildingCritTimesData::SData* CBuildingCritTimesData::Find( uint32 building_type )
{
    UInt32BuildingCritTimesMap::iterator iter = id_buildingcrittimes_map.find(building_type);
    if ( iter != id_buildingcrittimes_map.end() )
        return iter->second;
    return NULL;
}

void CBuildingCritTimesData::Add(SData* pbuildingcrittimes)
{
    id_buildingcrittimes_map[pbuildingcrittimes->building_type] = pbuildingcrittimes;
}
