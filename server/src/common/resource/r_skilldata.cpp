#include "jsonconfig.h"
#include "r_skilldata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSkillData::CSkillData()
{
}

CSkillData::~CSkillData()
{
    resource_clear(id_skill_map);
}

void CSkillData::LoadData(void)
{
    CJson jc = CJson::Load( "Skill" );

    theResDataMgr.insert(this);
    resource_clear(id_skill_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pskill                        = new SData;
        pskill->id                              = to_uint(aj[i]["id"]);
        pskill->level                           = to_uint(aj[i]["level"]);
        pskill->locale_id                       = to_uint(aj[i]["locale_id"]);
        pskill->disillusion                     = to_uint(aj[i]["disillusion"]);
        pskill->type                            = to_uint(aj[i]["type"]);
        pskill->distance                        = to_uint(aj[i]["distance"]);
        pskill->name                            = to_str(aj[i]["name"]);
        pskill->condition                       = to_uint(aj[i]["condition"]);
        pskill->attr                            = to_uint(aj[i]["attr"]);
        pskill->occupation                      = to_uint(aj[i]["occupation"]);
        pskill->icon                            = to_uint(aj[i]["icon"]);
        pskill->icon_type                       = to_uint(aj[i]["icon_type"]);
        pskill->buckle_blood                    = to_uint(aj[i]["buckle_blood"]);
        pskill->vibrate                         = to_str(aj[i]["vibrate"]);
        pskill->flash                           = to_str(aj[i]["flash"]);
        S2UInt32 mights;
        for ( uint32 j = 1; j <= 15; ++j )
        {
            std::string buff = strprintf( "mights%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &mights.first, &mights.second ) )
                break;
            pskill->mights.push_back(mights);
        }
        pskill->hurt_add                        = to_uint(aj[i]["hurt_add"]);
        pskill->break_per                       = to_uint(aj[i]["break_per"]);
        pskill->can_break                       = to_uint(aj[i]["can_break"]);
        pskill->self_addrage                    = to_uint(aj[i]["self_addrage"]);
        pskill->self_costrage                   = to_uint(aj[i]["self_costrage"]);
        pskill->def_addrage                     = to_uint(aj[i]["def_addrage"]);
        pskill->def_delrage                     = to_uint(aj[i]["def_delrage"]);
        pskill->self_addtotem                   = to_uint(aj[i]["self_addtotem"]);
        pskill->self_costtotem                  = to_uint(aj[i]["self_costtotem"]);
        pskill->def_addtotem                    = to_uint(aj[i]["def_addtotem"]);
        pskill->clear_rage                      = to_uint(aj[i]["clear_rage"]);
        pskill->clear_odd                       = to_uint(aj[i]["clear_odd"]);
        pskill->suck_hp                         = to_uint(aj[i]["suck_hp"]);
        pskill->pattern                         = to_uint(aj[i]["pattern"]);
        pskill->target_type                     = to_uint(aj[i]["target_type"]);
        pskill->target_range_count              = to_uint(aj[i]["target_range_count"]);
        pskill->target_range_cond               = to_uint(aj[i]["target_range_cond"]);
        S2UInt32 odds;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "odds%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &odds.first, &odds.second ) )
                break;
            pskill->odds.push_back(odds);
        }
        pskill->cooldown                        = to_uint(aj[i]["cooldown"]);
        pskill->start_round                     = to_uint(aj[i]["start_round"]);
        pskill->action_flag                     = to_str(aj[i]["action_flag"]);
        pskill->effect_index                    = to_uint(aj[i]["effect_index"]);
        pskill->skillname                       = to_str(aj[i]["skillname"]);
        pskill->interval                        = to_uint(aj[i]["interval"]);
        pskill->desc                            = to_str(aj[i]["desc"]);

        Add(pskill);
        ++count;
        LOG_DEBUG("id:%u,level:%u,locale_id:%u,disillusion:%u,type:%u,distance:%u,name:%s,condition:%u,attr:%u,occupation:%u,icon:%u,icon_type:%u,buckle_blood:%u,vibrate:%s,flash:%s,hurt_add:%u,break_per:%u,can_break:%u,self_addrage:%u,self_costrage:%u,def_addrage:%u,def_delrage:%u,self_addtotem:%u,self_costtotem:%u,def_addtotem:%u,clear_rage:%u,clear_odd:%u,suck_hp:%u,pattern:%u,target_type:%u,target_range_count:%u,target_range_cond:%u,cooldown:%u,start_round:%u,action_flag:%s,effect_index:%u,skillname:%s,interval:%u,desc:%s,", pskill->id, pskill->level, pskill->locale_id, pskill->disillusion, pskill->type, pskill->distance, pskill->name.c_str(), pskill->condition, pskill->attr, pskill->occupation, pskill->icon, pskill->icon_type, pskill->buckle_blood, pskill->vibrate.c_str(), pskill->flash.c_str(), pskill->hurt_add, pskill->break_per, pskill->can_break, pskill->self_addrage, pskill->self_costrage, pskill->def_addrage, pskill->def_delrage, pskill->self_addtotem, pskill->self_costtotem, pskill->def_addtotem, pskill->clear_rage, pskill->clear_odd, pskill->suck_hp, pskill->pattern, pskill->target_type, pskill->target_range_count, pskill->target_range_cond, pskill->cooldown, pskill->start_round, pskill->action_flag.c_str(), pskill->effect_index, pskill->skillname.c_str(), pskill->interval, pskill->desc.c_str());
    }
    LOG_INFO("Skill.xls:%d", count);
}

void CSkillData::ClearData(void)
{
    for( UInt32SkillMap::iterator iter = id_skill_map.begin();
        iter != id_skill_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_skill_map.clear();
}

CSkillData::SData* CSkillData::Find( uint32 id,uint32 level )
{
    return id_skill_map[id][level];
}

void CSkillData::Add(SData* pskill)
{
    id_skill_map[pskill->id][pskill->level] = pskill;
}
