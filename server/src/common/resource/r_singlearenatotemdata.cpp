#include "jsonconfig.h"
#include "r_singlearenatotemdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSingleArenaTotemData::CSingleArenaTotemData()
{
}

CSingleArenaTotemData::~CSingleArenaTotemData()
{
    resource_clear(id_singlearenatotem_map);
}

void CSingleArenaTotemData::LoadData(void)
{
    CJson jc = CJson::Load( "SingleArenaTotem" );

    theResDataMgr.insert(this);
    resource_clear(id_singlearenatotem_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psinglearenatotem             = new SData;
        psinglearenatotem->id                              = to_uint(aj[i]["id"]);
        psinglearenatotem->rank                            = to_uint(aj[i]["rank"]);
        psinglearenatotem->count                           = to_uint(aj[i]["count"]);

        Add(psinglearenatotem);
        ++count;
        LOG_DEBUG("id:%u,rank:%u,count:%u,", psinglearenatotem->id, psinglearenatotem->rank, psinglearenatotem->count);
    }
    LOG_INFO("SingleArenaTotem.xls:%d", count);
}

void CSingleArenaTotemData::ClearData(void)
{
    for( UInt32SingleArenaTotemMap::iterator iter = id_singlearenatotem_map.begin();
        iter != id_singlearenatotem_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_singlearenatotem_map.clear();
}

CSingleArenaTotemData::SData* CSingleArenaTotemData::Find( uint32 id )
{
    UInt32SingleArenaTotemMap::iterator iter = id_singlearenatotem_map.find(id);
    if ( iter != id_singlearenatotem_map.end() )
        return iter->second;
    return NULL;
}

void CSingleArenaTotemData::Add(SData* psinglearenatotem)
{
    id_singlearenatotem_map[psinglearenatotem->id] = psinglearenatotem;
}
