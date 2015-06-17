#include "jsonconfig.h"
#include "r_tombrewardbasedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTombRewardBaseData::CTombRewardBaseData()
{
}

CTombRewardBaseData::~CTombRewardBaseData()
{
    resource_clear(id_tombrewardbase_map);
}

void CTombRewardBaseData::LoadData(void)
{
    CJson jc = CJson::Load( "TombRewardBase" );

    theResDataMgr.insert(this);
    resource_clear(id_tombrewardbase_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptombrewardbase               = new SData;
        ptombrewardbase->id                              = to_uint(aj[i]["id"]);
        ptombrewardbase->reward                          = to_uint(aj[i]["reward"]);
        ptombrewardbase->tomb_coin                       = to_uint(aj[i]["tomb_coin"]);
        ptombrewardbase->desc                            = to_str(aj[i]["desc"]);

        Add(ptombrewardbase);
        ++count;
        LOG_DEBUG("id:%u,reward:%u,tomb_coin:%u,desc:%s,", ptombrewardbase->id, ptombrewardbase->reward, ptombrewardbase->tomb_coin, ptombrewardbase->desc.c_str());
    }
    LOG_INFO("TombRewardBase.xls:%d", count);
}

void CTombRewardBaseData::ClearData(void)
{
    for( UInt32TombRewardBaseMap::iterator iter = id_tombrewardbase_map.begin();
        iter != id_tombrewardbase_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_tombrewardbase_map.clear();
}

CTombRewardBaseData::SData* CTombRewardBaseData::Find( uint32 id )
{
    UInt32TombRewardBaseMap::iterator iter = id_tombrewardbase_map.find(id);
    if ( iter != id_tombrewardbase_map.end() )
        return iter->second;
    return NULL;
}

void CTombRewardBaseData::Add(SData* ptombrewardbase)
{
    id_tombrewardbase_map[ptombrewardbase->id] = ptombrewardbase;
}
