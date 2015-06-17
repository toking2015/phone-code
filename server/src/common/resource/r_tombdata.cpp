#include "jsonconfig.h"
#include "r_tombdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTombData::CTombData()
{
}

CTombData::~CTombData()
{
    resource_clear(id_tomb_map);
}

void CTombData::LoadData(void)
{
    CJson jc = CJson::Load( "Tomb" );

    theResDataMgr.insert(this);
    resource_clear(id_tomb_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptomb                         = new SData;
        ptomb->id                              = to_uint(aj[i]["id"]);
        ptomb->name                            = to_str(aj[i]["name"]);
        ptomb->monster_id                      = to_uint(aj[i]["monster_id"]);
        ptomb->ratio                           = to_uint(aj[i]["ratio"]);
        ptomb->desc                            = to_str(aj[i]["desc"]);

        Add(ptomb);
        ++count;
        LOG_DEBUG("id:%u,name:%s,monster_id:%u,ratio:%u,desc:%s,", ptomb->id, ptomb->name.c_str(), ptomb->monster_id, ptomb->ratio, ptomb->desc.c_str());
    }
    LOG_INFO("Tomb.xls:%d", count);
}

void CTombData::ClearData(void)
{
    for( UInt32TombMap::iterator iter = id_tomb_map.begin();
        iter != id_tomb_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_tomb_map.clear();
}

CTombData::SData* CTombData::Find( uint32 id )
{
    UInt32TombMap::iterator iter = id_tomb_map.find(id);
    if ( iter != id_tomb_map.end() )
        return iter->second;
    return NULL;
}

void CTombData::Add(SData* ptomb)
{
    id_tomb_map[ptomb->id] = ptomb;
}
