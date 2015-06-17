#include "jsonconfig.h"
#include "r_buildingupgradedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBuildingUpgradeData::CBuildingUpgradeData()
{
}

CBuildingUpgradeData::~CBuildingUpgradeData()
{
    resource_clear(id_buildingupgrade_map);
}

void CBuildingUpgradeData::LoadData(void)
{
    CJson jc = CJson::Load( "BuildingUpgrade" );

    theResDataMgr.insert(this);
    resource_clear(id_buildingupgrade_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbuildingupgrade              = new SData;
        pbuildingupgrade->id                              = to_uint(aj[i]["id"]);
        pbuildingupgrade->level                           = to_uint(aj[i]["level"]);
        pbuildingupgrade->u_level                         = to_uint(aj[i]["u_level"]);
        pbuildingupgrade->f_level                         = to_uint(aj[i]["f_level"]);
        pbuildingupgrade->w_level                         = to_uint(aj[i]["w_level"]);
        pbuildingupgrade->s_level                         = to_uint(aj[i]["s_level"]);

        Add(pbuildingupgrade);
        ++count;
        LOG_DEBUG("id:%u,level:%u,u_level:%u,f_level:%u,w_level:%u,s_level:%u,", pbuildingupgrade->id, pbuildingupgrade->level, pbuildingupgrade->u_level, pbuildingupgrade->f_level, pbuildingupgrade->w_level, pbuildingupgrade->s_level);
    }
    LOG_INFO("BuildingUpgrade.xls:%d", count);
}

void CBuildingUpgradeData::ClearData(void)
{
    for( UInt32BuildingUpgradeMap::iterator iter = id_buildingupgrade_map.begin();
        iter != id_buildingupgrade_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_buildingupgrade_map.clear();
}

CBuildingUpgradeData::SData* CBuildingUpgradeData::Find( uint32 id,uint32 level )
{
    return id_buildingupgrade_map[id][level];
}

void CBuildingUpgradeData::Add(SData* pbuildingupgrade)
{
    id_buildingupgrade_map[pbuildingupgrade->id][pbuildingupgrade->level] = pbuildingupgrade;
}
