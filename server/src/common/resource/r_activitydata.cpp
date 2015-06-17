#include "jsonconfig.h"
#include "r_activitydata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CActivityData::CActivityData()
{
}

CActivityData::~CActivityData()
{
    resource_clear(id_activity_map);
}

void CActivityData::LoadData(void)
{
    CJson jc = CJson::Load( "Activity" );

    theResDataMgr.insert(this);
    resource_clear(id_activity_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pactivity                     = new SData;
        pactivity->name                            = to_str(aj[i]["name"]);
        pactivity->cycle                           = to_uint(aj[i]["cycle"]);

        Add(pactivity);
        ++count;
        LOG_DEBUG("name:%s,cycle:%u,", pactivity->name.c_str(), pactivity->cycle);
    }
    LOG_INFO("Activity.xls:%d", count);
}

void CActivityData::ClearData(void)
{
    for( UInt32ActivityMap::iterator iter = id_activity_map.begin();
        iter != id_activity_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_activity_map.clear();
}

CActivityData::SData* CActivityData::Find( std::string name )
{
    UInt32ActivityMap::iterator iter = id_activity_map.find(name);
    if ( iter != id_activity_map.end() )
        return iter->second;
    return NULL;
}

void CActivityData::Add(SData* pactivity)
{
    id_activity_map[pactivity->name] = pactivity;
}
