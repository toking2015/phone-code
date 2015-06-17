#include "jsonconfig.h"
#include "r_activityopendata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CActivityOpenData::CActivityOpenData()
{
}

CActivityOpenData::~CActivityOpenData()
{
    resource_clear(id_activityopen_map);
}

void CActivityOpenData::LoadData(void)
{
    CJson jc = CJson::Load( "ActivityOpen" );

    theResDataMgr.insert(this);
    resource_clear(id_activityopen_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pactivityopen                 = new SData;
        pactivityopen->name                            = to_str(aj[i]["name"]);
        pactivityopen->type                            = to_uint(aj[i]["type"]);
        pactivityopen->first_time                      = to_str(aj[i]["first_time"]);
        pactivityopen->second_time                     = to_uint(aj[i]["second_time"]);
        pactivityopen->desc                            = to_str(aj[i]["desc"]);

        Add(pactivityopen);
        ++count;
        LOG_DEBUG("name:%s,type:%u,first_time:%s,second_time:%u,desc:%s,", pactivityopen->name.c_str(), pactivityopen->type, pactivityopen->first_time.c_str(), pactivityopen->second_time, pactivityopen->desc.c_str());
    }
    LOG_INFO("ActivityOpen.xls:%d", count);
}

void CActivityOpenData::ClearData(void)
{
    for( UInt32ActivityOpenMap::iterator iter = id_activityopen_map.begin();
        iter != id_activityopen_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_activityopen_map.clear();
}

CActivityOpenData::SData* CActivityOpenData::Find( std::string name,uint32 type )
{
    return id_activityopen_map[name][type];
}

void CActivityOpenData::Add(SData* pactivityopen)
{
    id_activityopen_map[pactivityopen->name][pactivityopen->type] = pactivityopen;
}
