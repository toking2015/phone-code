#include "jsonconfig.h"
#include "r_vardata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CVarData::CVarData()
{
}

CVarData::~CVarData()
{
    resource_clear(id_var_map);
}

void CVarData::LoadData(void)
{
    CJson jc = CJson::Load( "Var" );

    theResDataMgr.insert(this);
    resource_clear(id_var_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pvar                          = new SData;
        pvar->key                             = to_str(aj[i]["key"]);
        pvar->flag                            = to_uint(aj[i]["flag"]);

        Add(pvar);
        ++count;
        LOG_DEBUG("key:%s,flag:%u,", pvar->key.c_str(), pvar->flag);
    }
    LOG_INFO("Var.xls:%d", count);
}

void CVarData::ClearData(void)
{
    for( UInt32VarMap::iterator iter = id_var_map.begin();
        iter != id_var_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_var_map.clear();
}

CVarData::SData* CVarData::Find( std::string key )
{
    UInt32VarMap::iterator iter = id_var_map.find(key);
    if ( iter != id_var_map.end() )
        return iter->second;
    return NULL;
}

void CVarData::Add(SData* pvar)
{
    id_var_map[pvar->key] = pvar;
}
