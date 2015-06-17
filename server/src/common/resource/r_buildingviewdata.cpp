#include "jsonconfig.h"
#include "r_buildingviewdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CBuildingViewData::CBuildingViewData()
{
}

CBuildingViewData::~CBuildingViewData()
{
    resource_clear(id_buildingview_map);
}

void CBuildingViewData::LoadData(void)
{
    CJson jc = CJson::Load( "BuildingView" );

    theResDataMgr.insert(this);
    resource_clear(id_buildingview_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pbuildingview                 = new SData;
        pbuildingview->id                              = to_uint(aj[i]["id"]);
        pbuildingview->name                            = to_str(aj[i]["name"]);
        pbuildingview->page                            = to_uint(aj[i]["page"]);
        pbuildingview->x                               = to_uint(aj[i]["x"]);
        pbuildingview->y                               = to_uint(aj[i]["y"]);
        pbuildingview->command                         = to_str(aj[i]["command"]);
        pbuildingview->desc                            = to_str(aj[i]["desc"]);

        Add(pbuildingview);
        ++count;
        LOG_DEBUG("id:%u,name:%s,page:%u,x:%u,y:%u,command:%s,desc:%s,", pbuildingview->id, pbuildingview->name.c_str(), pbuildingview->page, pbuildingview->x, pbuildingview->y, pbuildingview->command.c_str(), pbuildingview->desc.c_str());
    }
    LOG_INFO("BuildingView.xls:%d", count);
}

void CBuildingViewData::ClearData(void)
{
    for( UInt32BuildingViewMap::iterator iter = id_buildingview_map.begin();
        iter != id_buildingview_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_buildingview_map.clear();
}

CBuildingViewData::SData* CBuildingViewData::Find( uint32 id )
{
    UInt32BuildingViewMap::iterator iter = id_buildingview_map.find(id);
    if ( iter != id_buildingview_map.end() )
        return iter->second;
    return NULL;
}

void CBuildingViewData::Add(SData* pbuildingview)
{
    id_buildingview_map[pbuildingview->id] = pbuildingview;
}
