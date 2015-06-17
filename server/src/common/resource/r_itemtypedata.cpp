#include "jsonconfig.h"
#include "r_itemtypedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CItemTypeData::CItemTypeData()
{
}

CItemTypeData::~CItemTypeData()
{
    resource_clear(id_itemtype_map);
}

void CItemTypeData::LoadData(void)
{
    CJson jc = CJson::Load( "ItemType" );

    theResDataMgr.insert(this);
    resource_clear(id_itemtype_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pitemtype                     = new SData;
        pitemtype->item_type                       = to_uint(aj[i]["item_type"]);
        pitemtype->bag_type                        = to_uint(aj[i]["bag_type"]);
        uint32 bag_moves;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "bag_moves%d", j);
            bag_moves = to_uint(aj[i][buff]);
            pitemtype->bag_moves.push_back(bag_moves);
        }

        Add(pitemtype);
        ++count;
        LOG_DEBUG("item_type:%u,bag_type:%u,", pitemtype->item_type, pitemtype->bag_type);
    }
    LOG_INFO("ItemType.xls:%d", count);
}

void CItemTypeData::ClearData(void)
{
    for( UInt32ItemTypeMap::iterator iter = id_itemtype_map.begin();
        iter != id_itemtype_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_itemtype_map.clear();
}

CItemTypeData::SData* CItemTypeData::Find( uint32 item_type )
{
    UInt32ItemTypeMap::iterator iter = id_itemtype_map.find(item_type);
    if ( iter != id_itemtype_map.end() )
        return iter->second;
    return NULL;
}

void CItemTypeData::Add(SData* pitemtype)
{
    id_itemtype_map[pitemtype->item_type] = pitemtype;
}
