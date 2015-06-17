#include "jsonconfig.h"
#include "r_soldierqualitydata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierQualityData::CSoldierQualityData()
{
}

CSoldierQualityData::~CSoldierQualityData()
{
    resource_clear(id_soldierquality_map);
}

void CSoldierQualityData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierQuality" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierquality_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierquality               = new SData;
        psoldierquality->lv                              = to_uint(aj[i]["lv"]);
        std::string quality_effect_string = aj[i]["quality_effect"].asString();
        sscanf( quality_effect_string.c_str(), "%u%%%u", &psoldierquality->quality_effect.first, &psoldierquality->quality_effect.second );
        psoldierquality->xp                              = to_uint(aj[i]["xp"]);
        psoldierquality->skill_active                    = to_uint(aj[i]["skill_active"]);
        psoldierquality->disillusion_skill_level            = to_uint(aj[i]["disillusion_skill_level"]);
        psoldierquality->lv_limit                        = to_uint(aj[i]["lv_limit"]);
        psoldierquality->skill_point                     = to_uint(aj[i]["skill_point"]);
        S3UInt32 costs;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "costs%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &costs.cate, &costs.objid, &costs.val ) )
                break;
            psoldierquality->costs.push_back(costs);
        }
        psoldierquality->hp                              = to_uint(aj[i]["hp"]);
        psoldierquality->physical_ack                    = to_uint(aj[i]["physical_ack"]);
        psoldierquality->physical_def                    = to_uint(aj[i]["physical_def"]);
        psoldierquality->magic_ack                       = to_uint(aj[i]["magic_ack"]);
        psoldierquality->magic_def                       = to_uint(aj[i]["magic_def"]);
        psoldierquality->speed                           = to_uint(aj[i]["speed"]);

        Add(psoldierquality);
        ++count;
        LOG_DEBUG("lv:%u,xp:%u,skill_active:%u,disillusion_skill_level:%u,lv_limit:%u,skill_point:%u,hp:%u,physical_ack:%u,physical_def:%u,magic_ack:%u,magic_def:%u,speed:%u,", psoldierquality->lv, psoldierquality->xp, psoldierquality->skill_active, psoldierquality->disillusion_skill_level, psoldierquality->lv_limit, psoldierquality->skill_point, psoldierquality->hp, psoldierquality->physical_ack, psoldierquality->physical_def, psoldierquality->magic_ack, psoldierquality->magic_def, psoldierquality->speed);
    }
    LOG_INFO("SoldierQuality.xls:%d", count);
}

void CSoldierQualityData::ClearData(void)
{
    for( UInt32SoldierQualityMap::iterator iter = id_soldierquality_map.begin();
        iter != id_soldierquality_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_soldierquality_map.clear();
}

CSoldierQualityData::SData* CSoldierQualityData::Find( uint32 lv )
{
    UInt32SoldierQualityMap::iterator iter = id_soldierquality_map.find(lv);
    if ( iter != id_soldierquality_map.end() )
        return iter->second;
    return NULL;
}

void CSoldierQualityData::Add(SData* psoldierquality)
{
    id_soldierquality_map[psoldierquality->lv] = psoldierquality;
}
