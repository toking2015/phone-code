#include "jsonconfig.h"
#include "r_soldierqualityoccudata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierQualityOccuData::CSoldierQualityOccuData()
{
}

CSoldierQualityOccuData::~CSoldierQualityOccuData()
{
    resource_clear(id_soldierqualityoccu_map);
}

void CSoldierQualityOccuData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierQualityOccu" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierqualityoccu_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierqualityoccu           = new SData;
        psoldierqualityoccu->quality_id                      = to_uint(aj[i]["quality_id"]);
        psoldierqualityoccu->occu_id                         = to_uint(aj[i]["occu_id"]);
        std::string cost_string = aj[i]["cost"].asString();
        sscanf( cost_string.c_str(), "%u%%%u%%%u", &psoldierqualityoccu->cost.cate, &psoldierqualityoccu->cost.objid, &psoldierqualityoccu->cost.val );
        psoldierqualityoccu->limit_lv                        = to_uint(aj[i]["limit_lv"]);

        Add(psoldierqualityoccu);
        ++count;
        LOG_DEBUG("quality_id:%u,occu_id:%u,limit_lv:%u,", psoldierqualityoccu->quality_id, psoldierqualityoccu->occu_id, psoldierqualityoccu->limit_lv);
    }
    LOG_INFO("SoldierQualityOccu.xls:%d", count);
}

void CSoldierQualityOccuData::ClearData(void)
{
    for( UInt32SoldierQualityOccuMap::iterator iter = id_soldierqualityoccu_map.begin();
        iter != id_soldierqualityoccu_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_soldierqualityoccu_map.clear();
}

CSoldierQualityOccuData::SData* CSoldierQualityOccuData::Find( uint32 quality_id,uint32 occu_id )
{
    return id_soldierqualityoccu_map[quality_id][occu_id];
}

void CSoldierQualityOccuData::Add(SData* psoldierqualityoccu)
{
    id_soldierqualityoccu_map[psoldierqualityoccu->quality_id][psoldierqualityoccu->occu_id] = psoldierqualityoccu;
}
