#include "jsonconfig.h"
#include "r_altardata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CAltarData::CAltarData()
{
}

CAltarData::~CAltarData()
{
    resource_clear(id_altar_map);
}

void CAltarData::LoadData(void)
{
    CJson jc = CJson::Load( "Altar" );

    theResDataMgr.insert(this);
    resource_clear(id_altar_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *paltar                        = new SData;
        paltar->id                              = to_uint(aj[i]["id"]);
        paltar->type                            = to_uint(aj[i]["type"]);
        paltar->lv                              = to_uint(aj[i]["lv"]);
        std::string reward_string = aj[i]["reward"].asString();
        sscanf( reward_string.c_str(), "%u%%%u%%%u", &paltar->reward.cate, &paltar->reward.objid, &paltar->reward.val );
        std::string extra_reward_string = aj[i]["extra_reward"].asString();
        sscanf( extra_reward_string.c_str(), "%u%%%u%%%u", &paltar->extra_reward.cate, &paltar->extra_reward.objid, &paltar->extra_reward.val );
        paltar->prob                            = to_uint(aj[i]["prob"]);
        paltar->is_rare                         = to_uint(aj[i]["is_rare"]);
        paltar->is_ten                          = to_uint(aj[i]["is_ten"]);

        Add(paltar);
        ++count;
        LOG_DEBUG("id:%u,type:%u,lv:%u,prob:%u,is_rare:%u,is_ten:%u,", paltar->id, paltar->type, paltar->lv, paltar->prob, paltar->is_rare, paltar->is_ten);
    }
    LOG_INFO("Altar.xls:%d", count);
}

void CAltarData::ClearData(void)
{
    for( UInt32AltarMap::iterator iter = id_altar_map.begin();
        iter != id_altar_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_altar_map.clear();
}

CAltarData::SData* CAltarData::Find( uint32 id )
{
    UInt32AltarMap::iterator iter = id_altar_map.find(id);
    if ( iter != id_altar_map.end() )
        return iter->second;
    return NULL;
}

void CAltarData::Add(SData* paltar)
{
    id_altar_map[paltar->id] = paltar;
}
