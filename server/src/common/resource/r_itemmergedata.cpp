#include "jsonconfig.h"
#include "r_itemmergedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CItemMergeData::CItemMergeData()
{
}

CItemMergeData::~CItemMergeData()
{
    resource_clear(id_itemmerge_map);
}

void CItemMergeData::LoadData(void)
{
    CJson jc = CJson::Load( "ItemMerge" );

    theResDataMgr.insert(this);
    resource_clear(id_itemmerge_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pitemmerge                    = new SData;
        pitemmerge->id                              = to_uint(aj[i]["id"]);
        pitemmerge->type                            = to_uint(aj[i]["type"]);
        pitemmerge->limit_level                     = to_uint(aj[i]["limit_level"]);
        pitemmerge->item_id                         = to_uint(aj[i]["item_id"]);
        pitemmerge->package_id                      = to_uint(aj[i]["package_id"]);
        std::string dst_item_string = aj[i]["dst_item"].asString();
        sscanf( dst_item_string.c_str(), "%u%%%u%%%u", &pitemmerge->dst_item.cate, &pitemmerge->dst_item.objid, &pitemmerge->dst_item.val );
        S3UInt32 materials;
        for ( uint32 j = 1; j <= 5; ++j )
        {
            std::string buff = strprintf( "materials%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &materials.cate, &materials.objid, &materials.val ) )
                break;
            pitemmerge->materials.push_back(materials);
        }
        pitemmerge->desc                            = to_str(aj[i]["desc"]);

        Add(pitemmerge);
        ++count;
        LOG_DEBUG("id:%u,type:%u,limit_level:%u,item_id:%u,package_id:%u,desc:%s,", pitemmerge->id, pitemmerge->type, pitemmerge->limit_level, pitemmerge->item_id, pitemmerge->package_id, pitemmerge->desc.c_str());
    }
    LOG_INFO("ItemMerge.xls:%d", count);
}

void CItemMergeData::ClearData(void)
{
    for( UInt32ItemMergeMap::iterator iter = id_itemmerge_map.begin();
        iter != id_itemmerge_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_itemmerge_map.clear();
}

CItemMergeData::SData* CItemMergeData::Find( uint32 id )
{
    UInt32ItemMergeMap::iterator iter = id_itemmerge_map.find(id);
    if ( iter != id_itemmerge_map.end() )
        return iter->second;
    return NULL;
}

void CItemMergeData::Add(SData* pitemmerge)
{
    id_itemmerge_map[pitemmerge->id] = pitemmerge;
}
