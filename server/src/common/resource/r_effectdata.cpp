#include "jsonconfig.h"
#include "r_effectdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CEffectData::CEffectData()
{
}

CEffectData::~CEffectData()
{
    resource_clear(id_effect_map);
}

void CEffectData::LoadData(void)
{
    CJson jc = CJson::Load( "Effect" );

    theResDataMgr.insert(this);
    resource_clear(id_effect_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *peffect                       = new SData;
        peffect->id                              = to_uint(aj[i]["id"]);
        peffect->mode                            = to_uint(aj[i]["mode"]);
        peffect->local_id                        = to_uint(aj[i]["local_id"]);
        peffect->desc                            = to_str(aj[i]["desc"]);
        peffect->PercenValue                     = to_uint(aj[i]["PercenValue"]);
        peffect->icon                            = to_uint(aj[i]["icon"]);

        Add(peffect);
        ++count;
        LOG_DEBUG("id:%u,mode:%u,local_id:%u,desc:%s,PercenValue:%u,icon:%u,", peffect->id, peffect->mode, peffect->local_id, peffect->desc.c_str(), peffect->PercenValue, peffect->icon);
    }
    LOG_INFO("Effect.xls:%d", count);
}

void CEffectData::ClearData(void)
{
    for( UInt32EffectMap::iterator iter = id_effect_map.begin();
        iter != id_effect_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_effect_map.clear();
}

CEffectData::SData* CEffectData::Find( uint32 id )
{
    UInt32EffectMap::iterator iter = id_effect_map.find(id);
    if ( iter != id_effect_map.end() )
        return iter->second;
    return NULL;
}

void CEffectData::Add(SData* peffect)
{
    id_effect_map[peffect->id] = peffect;
}
