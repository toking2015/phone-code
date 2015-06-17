#include "jsonconfig.h"
#include "r_paperskilldata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CPaperSkillData::CPaperSkillData()
{
}

CPaperSkillData::~CPaperSkillData()
{
    resource_clear(id_paperskill_map);
}

void CPaperSkillData::LoadData(void)
{
    CJson jc = CJson::Load( "PaperSkill" );

    theResDataMgr.insert(this);
    resource_clear(id_paperskill_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ppaperskill                   = new SData;
        ppaperskill->id                              = to_uint(aj[i]["id"]);
        ppaperskill->skill_type                      = to_uint(aj[i]["skill_type"]);
        ppaperskill->level                           = to_uint(aj[i]["level"]);
        ppaperskill->paper_level_limit               = to_uint(aj[i]["paper_level_limit"]);
        ppaperskill->collect_skill_level             = to_uint(aj[i]["collect_skill_level"]);
        ppaperskill->active_score_limit              = to_uint(aj[i]["active_score_limit"]);
        ppaperskill->active_score_add                = to_uint(aj[i]["active_score_add"]);
        ppaperskill->create_cost_reduce              = to_uint(aj[i]["create_cost_reduce"]);
        ppaperskill->level_up_star                   = to_uint(aj[i]["level_up_star"]);
        ppaperskill->level_up_money                  = to_uint(aj[i]["level_up_money"]);

        Add(ppaperskill);
        ++count;
        LOG_DEBUG("id:%u,skill_type:%u,level:%u,paper_level_limit:%u,collect_skill_level:%u,active_score_limit:%u,active_score_add:%u,create_cost_reduce:%u,level_up_star:%u,level_up_money:%u,", ppaperskill->id, ppaperskill->skill_type, ppaperskill->level, ppaperskill->paper_level_limit, ppaperskill->collect_skill_level, ppaperskill->active_score_limit, ppaperskill->active_score_add, ppaperskill->create_cost_reduce, ppaperskill->level_up_star, ppaperskill->level_up_money);
    }
    LOG_INFO("PaperSkill.xls:%d", count);
}

void CPaperSkillData::ClearData(void)
{
    for( UInt32PaperSkillMap::iterator iter = id_paperskill_map.begin();
        iter != id_paperskill_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_paperskill_map.clear();
}

CPaperSkillData::SData* CPaperSkillData::Find( uint32 id )
{
    UInt32PaperSkillMap::iterator iter = id_paperskill_map.find(id);
    if ( iter != id_paperskill_map.end() )
        return iter->second;
    return NULL;
}

void CPaperSkillData::Add(SData* ppaperskill)
{
    id_paperskill_map[ppaperskill->id] = ppaperskill;
}
