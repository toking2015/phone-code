#include "jsonconfig.h"
#include "r_equipqualitydata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CEquipQualityData::CEquipQualityData()
{
}

CEquipQualityData::~CEquipQualityData()
{
    resource_clear(id_equipquality_map);
}

void CEquipQualityData::LoadData(void)
{
    CJson jc = CJson::Load( "EquipQuality" );

    theResDataMgr.insert(this);
    resource_clear(id_equipquality_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pequipquality                 = new SData;
        pequipquality->quality                         = to_uint(aj[i]["quality"]);
        pequipquality->main_min                        = to_uint(aj[i]["main_min"]);
        pequipquality->main_max                        = to_uint(aj[i]["main_max"]);
        pequipquality->slave_min                       = to_uint(aj[i]["slave_min"]);
        pequipquality->slave_max                       = to_uint(aj[i]["slave_max"]);
        pequipquality->slave_attr_num                  = to_uint(aj[i]["slave_attr_num"]);

        Add(pequipquality);
        ++count;
        LOG_DEBUG("quality:%u,main_min:%u,main_max:%u,slave_min:%u,slave_max:%u,slave_attr_num:%u,", pequipquality->quality, pequipquality->main_min, pequipquality->main_max, pequipquality->slave_min, pequipquality->slave_max, pequipquality->slave_attr_num);
    }
    LOG_INFO("EquipQuality.xls:%d", count);
}

void CEquipQualityData::ClearData(void)
{
    for( UInt32EquipQualityMap::iterator iter = id_equipquality_map.begin();
        iter != id_equipquality_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_equipquality_map.clear();
}

CEquipQualityData::SData* CEquipQualityData::Find( uint32 quality )
{
    UInt32EquipQualityMap::iterator iter = id_equipquality_map.find(quality);
    if ( iter != id_equipquality_map.end() )
        return iter->second;
    return NULL;
}

void CEquipQualityData::Add(SData* pequipquality)
{
    id_equipquality_map[pequipquality->quality] = pequipquality;
}
