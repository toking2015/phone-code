#include "jsonconfig.h"
#include "r_totemextdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTotemExtData::CTotemExtData()
{
}

CTotemExtData::~CTotemExtData()
{
    resource_clear(id_totemext_map);
}

void CTotemExtData::LoadData(void)
{
    CJson jc = CJson::Load( "TotemExt" );

    theResDataMgr.insert(this);
    resource_clear(id_totemext_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptotemext                     = new SData;
        ptotemext->id                              = to_uint(aj[i]["id"]);
        ptotemext->totem_id                        = to_uint(aj[i]["totem_id"]);
        ptotemext->level                           = to_uint(aj[i]["level"]);
        ptotemext->wake_lv                         = to_uint(aj[i]["wake_lv"]);
        ptotemext->formation_lv                    = to_uint(aj[i]["formation_lv"]);
        ptotemext->speed_lv                        = to_uint(aj[i]["speed_lv"]);

        Add(ptotemext);
        ++count;
        LOG_DEBUG("id:%u,totem_id:%u,level:%u,wake_lv:%u,formation_lv:%u,speed_lv:%u,", ptotemext->id, ptotemext->totem_id, ptotemext->level, ptotemext->wake_lv, ptotemext->formation_lv, ptotemext->speed_lv);
    }
    LOG_INFO("TotemExt.xls:%d", count);
}

void CTotemExtData::ClearData(void)
{
    for( UInt32TotemExtMap::iterator iter = id_totemext_map.begin();
        iter != id_totemext_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_totemext_map.clear();
}

CTotemExtData::SData* CTotemExtData::Find( uint32 id )
{
    UInt32TotemExtMap::iterator iter = id_totemext_map.find(id);
    if ( iter != id_totemext_map.end() )
        return iter->second;
    return NULL;
}

void CTotemExtData::Add(SData* ptotemext)
{
    id_totemext_map[ptotemext->id] = ptotemext;
}
