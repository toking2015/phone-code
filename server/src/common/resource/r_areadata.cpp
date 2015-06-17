#include "jsonconfig.h"
#include "r_areadata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CAreaData::CAreaData()
{
}

CAreaData::~CAreaData()
{
    resource_clear(id_area_map);
}

void CAreaData::LoadData(void)
{
    CJson jc = CJson::Load( "Area" );

    theResDataMgr.insert(this);
    resource_clear(id_area_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *parea                         = new SData;
        parea->id                              = to_uint(aj[i]["id"]);
        parea->name                            = to_str(aj[i]["name"]);
        parea->normal_pass_reward              = to_uint(aj[i]["normal_pass_reward"]);
        parea->elite_pass_reward               = to_uint(aj[i]["elite_pass_reward"]);
        parea->normal_full_reward              = to_uint(aj[i]["normal_full_reward"]);
        parea->elite_full_reward               = to_uint(aj[i]["elite_full_reward"]);
        uint32 copy;
        for ( uint32 j = 1; j <= 16; ++j )
        {
            std::string buff = strprintf( "copy%d", j);
            copy = to_uint(aj[i][buff]);
            parea->copy.push_back(copy);
        }
        parea->icon                            = to_uint(aj[i]["icon"]);
        parea->level                           = to_uint(aj[i]["level"]);

        Add(parea);
        ++count;
        LOG_DEBUG("id:%u,name:%s,normal_pass_reward:%u,elite_pass_reward:%u,normal_full_reward:%u,elite_full_reward:%u,icon:%u,level:%u,", parea->id, parea->name.c_str(), parea->normal_pass_reward, parea->elite_pass_reward, parea->normal_full_reward, parea->elite_full_reward, parea->icon, parea->level);
    }
    LOG_INFO("Area.xls:%d", count);
}

void CAreaData::ClearData(void)
{
    for( UInt32AreaMap::iterator iter = id_area_map.begin();
        iter != id_area_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_area_map.clear();
}

CAreaData::SData* CAreaData::Find( uint32 id )
{
    UInt32AreaMap::iterator iter = id_area_map.find(id);
    if ( iter != id_area_map.end() )
        return iter->second;
    return NULL;
}

void CAreaData::Add(SData* parea)
{
    id_area_map[parea->id] = parea;
}
