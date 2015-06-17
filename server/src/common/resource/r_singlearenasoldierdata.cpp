#include "jsonconfig.h"
#include "r_singlearenasoldierdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSingleArenaSoldierData::CSingleArenaSoldierData()
{
}

CSingleArenaSoldierData::~CSingleArenaSoldierData()
{
    resource_clear(id_singlearenasoldier_map);
}

void CSingleArenaSoldierData::LoadData(void)
{
    CJson jc = CJson::Load( "SingleArenaSoldier" );

    theResDataMgr.insert(this);
    resource_clear(id_singlearenasoldier_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psinglearenasoldier           = new SData;
        psinglearenasoldier->id                              = to_uint(aj[i]["id"]);
        psinglearenasoldier->rank                            = to_uint(aj[i]["rank"]);
        psinglearenasoldier->count                           = to_uint(aj[i]["count"]);

        Add(psinglearenasoldier);
        ++count;
        LOG_DEBUG("id:%u,rank:%u,count:%u,", psinglearenasoldier->id, psinglearenasoldier->rank, psinglearenasoldier->count);
    }
    LOG_INFO("SingleArenaSoldier.xls:%d", count);
}

void CSingleArenaSoldierData::ClearData(void)
{
    for( UInt32SingleArenaSoldierMap::iterator iter = id_singlearenasoldier_map.begin();
        iter != id_singlearenasoldier_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_singlearenasoldier_map.clear();
}

CSingleArenaSoldierData::SData* CSingleArenaSoldierData::Find( uint32 id )
{
    UInt32SingleArenaSoldierMap::iterator iter = id_singlearenasoldier_map.find(id);
    if ( iter != id_singlearenasoldier_map.end() )
        return iter->second;
    return NULL;
}

void CSingleArenaSoldierData::Add(SData* psinglearenasoldier)
{
    id_singlearenasoldier_map[psinglearenasoldier->id] = psinglearenasoldier;
}
