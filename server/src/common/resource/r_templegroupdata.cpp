#include "jsonconfig.h"
#include "r_templegroupdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTempleGroupData::CTempleGroupData()
{
}

CTempleGroupData::~CTempleGroupData()
{
    resource_clear(id_templegroup_map);
}

void CTempleGroupData::LoadData(void)
{
    CJson jc = CJson::Load( "TempleGroup" );

    theResDataMgr.insert(this);
    resource_clear(id_templegroup_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptemplegroup                  = new SData;
        ptemplegroup->id                              = to_uint(aj[i]["id"]);
        ptemplegroup->init_lv                         = to_uint(aj[i]["init_lv"]);
        ptemplegroup->get_score                       = to_uint(aj[i]["get_score"]);
        S2UInt32 members;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "members%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &members.first, &members.second ) )
                break;
            ptemplegroup->members.push_back(members);
        }

        Add(ptemplegroup);
        ++count;
        LOG_DEBUG("id:%u,init_lv:%u,get_score:%u,", ptemplegroup->id, ptemplegroup->init_lv, ptemplegroup->get_score);
    }
    LOG_INFO("TempleGroup.xls:%d", count);
}

void CTempleGroupData::ClearData(void)
{
    for( UInt32TempleGroupMap::iterator iter = id_templegroup_map.begin();
        iter != id_templegroup_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_templegroup_map.clear();
}

CTempleGroupData::SData* CTempleGroupData::Find( uint32 id )
{
    UInt32TempleGroupMap::iterator iter = id_templegroup_map.find(id);
    if ( iter != id_templegroup_map.end() )
        return iter->second;
    return NULL;
}

void CTempleGroupData::Add(SData* ptemplegroup)
{
    id_templegroup_map[ptemplegroup->id] = ptemplegroup;
}
