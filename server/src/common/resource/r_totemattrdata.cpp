#include "jsonconfig.h"
#include "r_totemattrdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTotemAttrData::CTotemAttrData()
{
}

CTotemAttrData::~CTotemAttrData()
{
    resource_clear(id_totemattr_map);
}

void CTotemAttrData::LoadData(void)
{
    CJson jc = CJson::Load( "TotemAttr" );

    theResDataMgr.insert(this);
    resource_clear(id_totemattr_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptotemattr                    = new SData;
        ptotemattr->id                              = to_uint(aj[i]["id"]);
        ptotemattr->level                           = to_uint(aj[i]["level"]);
        std::string speed_string = aj[i]["speed"].asString();
        sscanf( speed_string.c_str(), "%u%%%u", &ptotemattr->speed.first, &ptotemattr->speed.second );
        std::string skill_string = aj[i]["skill"].asString();
        sscanf( skill_string.c_str(), "%u%%%u", &ptotemattr->skill.first, &ptotemattr->skill.second );
        std::string wake_string = aj[i]["wake"].asString();
        sscanf( wake_string.c_str(), "%u%%%u", &ptotemattr->wake.first, &ptotemattr->wake.second );
        ptotemattr->formation_add_position            = to_str(aj[i]["formation_add_position"]);
        std::string formation_add_attr_string = aj[i]["formation_add_attr"].asString();
        sscanf( formation_add_attr_string.c_str(), "%u%%%u", &ptotemattr->formation_add_attr.first, &ptotemattr->formation_add_attr.second );
        ptotemattr->formation_up_desc               = to_str(aj[i]["formation_up_desc"]);
        ptotemattr->energy_time                     = to_uint(aj[i]["energy_time"]);
        S3UInt32 train_cost;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "train_cost%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &train_cost.cate, &train_cost.objid, &train_cost.val ) )
                break;
            ptotemattr->train_cost.push_back(train_cost);
        }
        S3UInt32 accelerate_cost;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "accelerate_cost%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &accelerate_cost.cate, &accelerate_cost.objid, &accelerate_cost.val ) )
                break;
            ptotemattr->accelerate_cost.push_back(accelerate_cost);
        }
        ptotemattr->acc_count                       = to_uint(aj[i]["acc_count"]);

        Add(ptotemattr);
        ++count;
        LOG_DEBUG("id:%u,level:%u,formation_add_position:%s,formation_up_desc:%s,energy_time:%u,acc_count:%u,", ptotemattr->id, ptotemattr->level, ptotemattr->formation_add_position.c_str(), ptotemattr->formation_up_desc.c_str(), ptotemattr->energy_time, ptotemattr->acc_count);
    }
    LOG_INFO("TotemAttr.xls:%d", count);
}

void CTotemAttrData::ClearData(void)
{
    for( UInt32TotemAttrMap::iterator iter = id_totemattr_map.begin();
        iter != id_totemattr_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_totemattr_map.clear();
}

CTotemAttrData::SData* CTotemAttrData::Find( uint32 id,uint32 level )
{
    return id_totemattr_map[id][level];
}

void CTotemAttrData::Add(SData* ptotemattr)
{
    id_totemattr_map[ptotemattr->id][ptotemattr->level] = ptotemattr;
}
