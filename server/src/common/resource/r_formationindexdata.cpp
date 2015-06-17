#include "jsonconfig.h"
#include "r_formationindexdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CFormationIndexData::CFormationIndexData()
{
}

CFormationIndexData::~CFormationIndexData()
{
    resource_clear(id_formationindex_map);
}

void CFormationIndexData::LoadData(void)
{
    CJson jc = CJson::Load( "FormationIndex" );

    theResDataMgr.insert(this);
    resource_clear(id_formationindex_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pformationindex               = new SData;
        pformationindex->index                           = to_uint(aj[i]["index"]);
        pformationindex->level                           = to_uint(aj[i]["level"]);

        Add(pformationindex);
        ++count;
        LOG_DEBUG("index:%u,level:%u,", pformationindex->index, pformationindex->level);
    }
    LOG_INFO("FormationIndex.xls:%d", count);
}

void CFormationIndexData::ClearData(void)
{
    for( UInt32FormationIndexMap::iterator iter = id_formationindex_map.begin();
        iter != id_formationindex_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_formationindex_map.clear();
}

CFormationIndexData::SData* CFormationIndexData::Find( uint32 index )
{
    UInt32FormationIndexMap::iterator iter = id_formationindex_map.find(index);
    if ( iter != id_formationindex_map.end() )
        return iter->second;
    return NULL;
}

void CFormationIndexData::Add(SData* pformationindex)
{
    id_formationindex_map[pformationindex->index] = pformationindex;
}
