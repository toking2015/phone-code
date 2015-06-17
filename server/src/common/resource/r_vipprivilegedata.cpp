#include "jsonconfig.h"
#include "r_vipprivilegedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CVipPrivilegeData::CVipPrivilegeData()
{
}

CVipPrivilegeData::~CVipPrivilegeData()
{
    resource_clear(id_vipprivilege_map);
}

void CVipPrivilegeData::LoadData(void)
{
    CJson jc = CJson::Load( "VipPrivilege" );

    theResDataMgr.insert(this);
    resource_clear(id_vipprivilege_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pvipprivilege                 = new SData;
        pvipprivilege->id                              = to_uint(aj[i]["id"]);
        pvipprivilege->name                            = to_str(aj[i]["name"]);
        uint32 vip;
        for ( uint32 j = 1; j <= 20; ++j )
        {
            std::string buff = strprintf( "vip%d", j);
            vip = to_uint(aj[i][buff]);
            pvipprivilege->vip.push_back(vip);
        }

        Add(pvipprivilege);
        ++count;
        LOG_DEBUG("id:%u,name:%s,", pvipprivilege->id, pvipprivilege->name.c_str());
    }
    LOG_INFO("VipPrivilege.xls:%d", count);
}

void CVipPrivilegeData::ClearData(void)
{
    for( UInt32VipPrivilegeMap::iterator iter = id_vipprivilege_map.begin();
        iter != id_vipprivilege_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_vipprivilege_map.clear();
}

CVipPrivilegeData::SData* CVipPrivilegeData::Find( uint32 id )
{
    UInt32VipPrivilegeMap::iterator iter = id_vipprivilege_map.find(id);
    if ( iter != id_vipprivilege_map.end() )
        return iter->second;
    return NULL;
}

void CVipPrivilegeData::Add(SData* pvipprivilege)
{
    id_vipprivilege_map[pvipprivilege->id] = pvipprivilege;
}
