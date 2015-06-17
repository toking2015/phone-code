#include "jsonconfig.h"
#include "r_papercreatedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CPaperCreateData::CPaperCreateData()
{
}

CPaperCreateData::~CPaperCreateData()
{
    resource_clear(id_papercreate_map);
}

void CPaperCreateData::LoadData(void)
{
    CJson jc = CJson::Load( "PaperCreate" );

    theResDataMgr.insert(this);
    resource_clear(id_papercreate_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ppapercreate                  = new SData;
        ppapercreate->item_id                         = to_uint(aj[i]["item_id"]);
        ppapercreate->active_score                    = to_uint(aj[i]["active_score"]);
        ppapercreate->level_limit                     = to_uint(aj[i]["level_limit"]);
        ppapercreate->skill_type                      = to_uint(aj[i]["skill_type"]);

        Add(ppapercreate);
        ++count;
        LOG_DEBUG("item_id:%u,active_score:%u,level_limit:%u,skill_type:%u,", ppapercreate->item_id, ppapercreate->active_score, ppapercreate->level_limit, ppapercreate->skill_type);
    }
    LOG_INFO("PaperCreate.xls:%d", count);
}

void CPaperCreateData::ClearData(void)
{
    for( UInt32PaperCreateMap::iterator iter = id_papercreate_map.begin();
        iter != id_papercreate_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_papercreate_map.clear();
}

CPaperCreateData::SData* CPaperCreateData::Find( uint32 item_id )
{
    UInt32PaperCreateMap::iterator iter = id_papercreate_map.find(item_id);
    if ( iter != id_papercreate_map.end() )
        return iter->second;
    return NULL;
}

void CPaperCreateData::Add(SData* ppapercreate)
{
    id_papercreate_map[ppapercreate->item_id] = ppapercreate;
}
