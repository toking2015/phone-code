#include "jsonconfig.h"
#include "r_buildingdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBuildingData::CBuildingData()
{
}

CBuildingData::~CBuildingData()
{
    resource_clear(id_building_map);
}

void CBuildingData::LoadData(void)
{
    CJson jc = CJson::Load( "Building" );

    theResDataMgr.insert(this);
    resource_clear(id_building_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbuilding                     = new SData;
        pbuilding->id                              = to_uint(aj[i]["id"]);
        pbuilding->type                            = to_uint(aj[i]["type"]);
        pbuilding->common_open                     = to_uint(aj[i]["common_open"]);
        pbuilding->copy_open                       = to_uint(aj[i]["copy_open"]);
        pbuilding->task_open                       = to_uint(aj[i]["task_open"]);
        pbuilding->name                            = to_str(aj[i]["name"]);
        pbuilding->description                     = to_str(aj[i]["description"]);
        pbuilding->length                          = to_uint(aj[i]["length"]);
        pbuilding->width                           = to_uint(aj[i]["width"]);
        pbuilding->upgrade                         = to_uint(aj[i]["upgrade"]);
        pbuilding->up_if                           = to_uint(aj[i]["up_if"]);
        pbuilding->icon                            = to_uint(aj[i]["icon"]);
        pbuilding->isShow                          = to_uint(aj[i]["isShow"]);

        Add(pbuilding);
        ++count;
        LOG_DEBUG("id:%u,type:%u,common_open:%u,copy_open:%u,task_open:%u,name:%s,description:%s,length:%u,width:%u,upgrade:%u,up_if:%u,icon:%u,isShow:%u,", pbuilding->id, pbuilding->type, pbuilding->common_open, pbuilding->copy_open, pbuilding->task_open, pbuilding->name.c_str(), pbuilding->description.c_str(), pbuilding->length, pbuilding->width, pbuilding->upgrade, pbuilding->up_if, pbuilding->icon, pbuilding->isShow);
    }
    LOG_INFO("Building.xls:%d", count);
}

void CBuildingData::ClearData(void)
{
    for( UInt32BuildingMap::iterator iter = id_building_map.begin();
        iter != id_building_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_building_map.clear();
}

CBuildingData::SData* CBuildingData::Find( uint32 id )
{
    UInt32BuildingMap::iterator iter = id_building_map.find(id);
    if ( iter != id_building_map.end() )
        return iter->second;
    return NULL;
}

void CBuildingData::Add(SData* pbuilding)
{
    id_building_map[pbuilding->id] = pbuilding;
}
