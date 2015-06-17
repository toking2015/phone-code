#include "jsonconfig.h"
#include "r_copymaterialdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CCopyMaterialData::CCopyMaterialData()
{
}

CCopyMaterialData::~CCopyMaterialData()
{
    resource_clear(id_copymaterial_map);
}

void CCopyMaterialData::LoadData(void)
{
    CJson jc = CJson::Load( "CopyMaterial" );

    theResDataMgr.insert(this);
    resource_clear(id_copymaterial_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pcopymaterial                 = new SData;
        pcopymaterial->collect_level                   = to_uint(aj[i]["collect_level"]);
        pcopymaterial->active_score                    = to_uint(aj[i]["active_score"]);
        uint32 materials;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "materials%d", j);
            materials = to_uint(aj[i][buff]);
            pcopymaterial->materials.push_back(materials);
        }
        pcopymaterial->min_num                         = to_uint(aj[i]["min_num"]);
        pcopymaterial->max_num                         = to_uint(aj[i]["max_num"]);

        Add(pcopymaterial);
        ++count;
        LOG_DEBUG("collect_level:%u,active_score:%u,min_num:%u,max_num:%u,", pcopymaterial->collect_level, pcopymaterial->active_score, pcopymaterial->min_num, pcopymaterial->max_num);
    }
    LOG_INFO("CopyMaterial.xls:%d", count);
}

void CCopyMaterialData::ClearData(void)
{
    for( UInt32CopyMaterialMap::iterator iter = id_copymaterial_map.begin();
        iter != id_copymaterial_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_copymaterial_map.clear();
}

CCopyMaterialData::SData* CCopyMaterialData::Find( uint32 collect_level )
{
    UInt32CopyMaterialMap::iterator iter = id_copymaterial_map.find(collect_level);
    if ( iter != id_copymaterial_map.end() )
        return iter->second;
    return NULL;
}

void CCopyMaterialData::Add(SData* pcopymaterial)
{
    id_copymaterial_map[pcopymaterial->collect_level] = pcopymaterial;
}
