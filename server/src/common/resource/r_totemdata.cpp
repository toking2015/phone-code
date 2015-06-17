#include "jsonconfig.h"
#include "r_totemdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTotemData::CTotemData()
{
}

CTotemData::~CTotemData()
{
    resource_clear(id_totem_map);
}

void CTotemData::LoadData(void)
{
    CJson jc = CJson::Load( "Totem" );

    theResDataMgr.insert(this);
    resource_clear(id_totem_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptotem                        = new SData;
        ptotem->id                              = to_uint(aj[i]["id"]);
        ptotem->name                            = to_str(aj[i]["name"]);
        ptotem->type                            = to_uint(aj[i]["type"]);
        ptotem->ready                           = to_str(aj[i]["ready"]);
        ptotem->init_lv                         = to_uint(aj[i]["init_lv"]);
        ptotem->init_attr_lv                    = to_uint(aj[i]["init_attr_lv"]);
        ptotem->max_lv                          = to_uint(aj[i]["max_lv"]);
        S2UInt32 get_attr;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "get_attr%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &get_attr.first, &get_attr.second ) )
                break;
            ptotem->get_attr.push_back(get_attr);
        }
        ptotem->get_score                       = to_uint(aj[i]["get_score"]);
        S3UInt32 activate_conds;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "activate_conds%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &activate_conds.cate, &activate_conds.objid, &activate_conds.val ) )
                break;
            ptotem->activate_conds.push_back(activate_conds);
        }
        ptotem->animation_name                  = to_str(aj[i]["animation_name"]);
        ptotem->ready_animation                 = to_str(aj[i]["ready_animation"]);
        ptotem->passive_act                     = to_str(aj[i]["passive_act"]);
        ptotem->avatar                          = to_uint(aj[i]["avatar"]);
        ptotem->quality                         = to_uint(aj[i]["quality"]);
        ptotem->desc                            = to_str(aj[i]["desc"]);
        ptotem->path                            = to_str(aj[i]["path"]);

        Add(ptotem);
        ++count;
        LOG_DEBUG("id:%u,name:%s,type:%u,ready:%s,init_lv:%u,init_attr_lv:%u,max_lv:%u,get_score:%u,animation_name:%s,ready_animation:%s,passive_act:%s,avatar:%u,quality:%u,desc:%s,path:%s,", ptotem->id, ptotem->name.c_str(), ptotem->type, ptotem->ready.c_str(), ptotem->init_lv, ptotem->init_attr_lv, ptotem->max_lv, ptotem->get_score, ptotem->animation_name.c_str(), ptotem->ready_animation.c_str(), ptotem->passive_act.c_str(), ptotem->avatar, ptotem->quality, ptotem->desc.c_str(), ptotem->path.c_str());
    }
    LOG_INFO("Totem.xls:%d", count);
}

void CTotemData::ClearData(void)
{
    for( UInt32TotemMap::iterator iter = id_totem_map.begin();
        iter != id_totem_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_totem_map.clear();
}

CTotemData::SData* CTotemData::Find( uint32 id )
{
    UInt32TotemMap::iterator iter = id_totem_map.find(id);
    if ( iter != id_totem_map.end() )
        return iter->second;
    return NULL;
}

void CTotemData::Add(SData* ptotem)
{
    id_totem_map[ptotem->id] = ptotem;
}
