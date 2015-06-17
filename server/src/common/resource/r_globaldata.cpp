#include "jsonconfig.h"
#include "r_globaldata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CGlobalData::CGlobalData()
{
}

CGlobalData::~CGlobalData()
{
    resource_clear(id_global_map);
}

void CGlobalData::LoadData(void)
{
    CJson jc = CJson::Load( "Global" );

    theResDataMgr.insert(this);
    resource_clear(id_global_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pglobal                       = new SData;
        pglobal->global_name                     = to_str(aj[i]["global_name"]);
        pglobal->data                            = to_str(aj[i]["data"]);
        pglobal->describe                        = to_str(aj[i]["describe"]);

        Add(pglobal);
        ++count;
        LOG_DEBUG("global_name:%s,data:%s,describe:%s,", pglobal->global_name.c_str(), pglobal->data.c_str(), pglobal->describe.c_str());
    }
    LOG_INFO("Global.xls:%d", count);
}

void CGlobalData::ClearData(void)
{
    for( UInt32GlobalMap::iterator iter = id_global_map.begin();
        iter != id_global_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_global_map.clear();
}

CGlobalData::SData* CGlobalData::Find( std::string global_name )
{
    UInt32GlobalMap::iterator iter = id_global_map.find(global_name);
    if ( iter != id_global_map.end() )
        return iter->second;
    return NULL;
}

void CGlobalData::Add(SData* pglobal)
{
    id_global_map[pglobal->global_name] = pglobal;
}
