#include "jsonconfig.h"
#include "r_itemopendata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CItemOpenData::CItemOpenData()
{
}

CItemOpenData::~CItemOpenData()
{
    resource_clear(id_itemopen_map);
}

void CItemOpenData::LoadData(void)
{
    CJson jc = CJson::Load( "ItemOpen" );

    theResDataMgr.insert(this);
    resource_clear(id_itemopen_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pitemopen                     = new SData;
        pitemopen->id                              = to_uint(aj[i]["id"]);
        pitemopen->open_id                         = to_uint(aj[i]["open_id"]);
        pitemopen->reward                          = to_uint(aj[i]["reward"]);
        std::string level_rand_string = aj[i]["level_rand"].asString();
        sscanf( level_rand_string.c_str(), "%u%%%u", &pitemopen->level_rand.first, &pitemopen->level_rand.second );
        pitemopen->percent                         = to_uint(aj[i]["percent"]);
        pitemopen->desc                            = to_str(aj[i]["desc"]);

        Add(pitemopen);
        ++count;
        LOG_DEBUG("id:%u,open_id:%u,reward:%u,percent:%u,desc:%s,", pitemopen->id, pitemopen->open_id, pitemopen->reward, pitemopen->percent, pitemopen->desc.c_str());
    }
    LOG_INFO("ItemOpen.xls:%d", count);
}

void CItemOpenData::ClearData(void)
{
    for( UInt32ItemOpenMap::iterator iter = id_itemopen_map.begin();
        iter != id_itemopen_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_itemopen_map.clear();
}

CItemOpenData::SData* CItemOpenData::Find( uint32 id )
{
    UInt32ItemOpenMap::iterator iter = id_itemopen_map.find(id);
    if ( iter != id_itemopen_map.end() )
        return iter->second;
    return NULL;
}

void CItemOpenData::Add(SData* pitemopen)
{
    id_itemopen_map[pitemopen->id] = pitemopen;
}
