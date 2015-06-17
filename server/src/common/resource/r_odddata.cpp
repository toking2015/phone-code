#include "jsonconfig.h"
#include "r_odddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

COddData::COddData()
{
}

COddData::~COddData()
{
    resource_clear(id_odd_map);
}

void COddData::LoadData(void)
{
    CJson jc = CJson::Load( "Odd" );

    theResDataMgr.insert(this);
    resource_clear(id_odd_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *podd                          = new SData;
        podd->id                              = to_uint(aj[i]["id"]);
        podd->level                           = to_uint(aj[i]["level"]);
        podd->name                            = to_str(aj[i]["name"]);
        podd->max_count                       = to_uint(aj[i]["max_count"]);
        podd->condition                       = to_uint(aj[i]["condition"]);
        podd->immediately                     = to_uint(aj[i]["immediately"]);
        podd->percent                         = to_uint(aj[i]["percent"]);
        podd->icon                            = to_uint(aj[i]["icon"]);
        podd->type                            = to_uint(aj[i]["type"]);
        podd->attr                            = to_uint(aj[i]["attr"]);
        podd->delay_round                     = to_uint(aj[i]["delay_round"]);
        podd->keep_round                      = to_uint(aj[i]["keep_round"]);
        std::string status_string = aj[i]["status"].asString();
        sscanf( status_string.c_str(), "%u%%%u%%%u", &podd->status.cate, &podd->status.objid, &podd->status.val );
        std::string effect_string = aj[i]["effect"].asString();
        sscanf( effect_string.c_str(), "%u%%%u%%%u", &podd->effect.cate, &podd->effect.objid, &podd->effect.val );
        podd->effect_count                    = to_uint(aj[i]["effect_count"]);
        podd->description                     = to_str(aj[i]["description"]);
        podd->target_type_skill               = to_uint(aj[i]["target_type_skill"]);
        podd->target_type_special             = to_uint(aj[i]["target_type_special"]);
        podd->target_type                     = to_uint(aj[i]["target_type"]);
        podd->target_range_count              = to_uint(aj[i]["target_range_count"]);
        podd->target_range_cond               = to_uint(aj[i]["target_range_cond"]);
        std::string addodd_string = aj[i]["addodd"].asString();
        sscanf( addodd_string.c_str(), "%u%%%u", &podd->addodd.first, &podd->addodd.second );
        std::string changeodd_string = aj[i]["changeodd"].asString();
        sscanf( changeodd_string.c_str(), "%u%%%u", &podd->changeodd.first, &podd->changeodd.second );
        podd->limit_count                     = to_uint(aj[i]["limit_count"]);
        podd->limit_count_all                 = to_uint(aj[i]["limit_count_all"]);
        podd->onceeffect                      = to_str(aj[i]["onceeffect"]);
        podd->buffeffect                      = to_str(aj[i]["buffeffect"]);
        podd->buffname                        = to_str(aj[i]["buffname"]);
        podd->buff_offset                     = to_uint(aj[i]["buff_offset"]);
        podd->buff_only                       = to_uint(aj[i]["buff_only"]);

        Add(podd);
        ++count;
        LOG_DEBUG("id:%u,level:%u,name:%s,max_count:%u,condition:%u,immediately:%u,percent:%u,icon:%u,type:%u,attr:%u,delay_round:%u,keep_round:%u,effect_count:%u,description:%s,target_type_skill:%u,target_type_special:%u,target_type:%u,target_range_count:%u,target_range_cond:%u,limit_count:%u,limit_count_all:%u,onceeffect:%s,buffeffect:%s,buffname:%s,buff_offset:%u,buff_only:%u,", podd->id, podd->level, podd->name.c_str(), podd->max_count, podd->condition, podd->immediately, podd->percent, podd->icon, podd->type, podd->attr, podd->delay_round, podd->keep_round, podd->effect_count, podd->description.c_str(), podd->target_type_skill, podd->target_type_special, podd->target_type, podd->target_range_count, podd->target_range_cond, podd->limit_count, podd->limit_count_all, podd->onceeffect.c_str(), podd->buffeffect.c_str(), podd->buffname.c_str(), podd->buff_offset, podd->buff_only);
    }
    LOG_INFO("Odd.xls:%d", count);
}

void COddData::ClearData(void)
{
    for( UInt32OddMap::iterator iter = id_odd_map.begin();
        iter != id_odd_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_odd_map.clear();
}

COddData::SData* COddData::Find( uint32 id,uint32 level )
{
    return id_odd_map[id][level];
}

void COddData::Add(SData* podd)
{
    id_odd_map[podd->id][podd->level] = podd;
}
