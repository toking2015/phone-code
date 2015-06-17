#include "jsonconfig.h"
#include "r_totemglyphhidedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTotemGlyphHideData::CTotemGlyphHideData()
{
}

CTotemGlyphHideData::~CTotemGlyphHideData()
{
    resource_clear(id_totemglyphhide_map);
}

void CTotemGlyphHideData::LoadData(void)
{
    CJson jc = CJson::Load( "TotemGlyphHide" );

    theResDataMgr.insert(this);
    resource_clear(id_totemglyphhide_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptotemglyphhide               = new SData;
        ptotemglyphhide->id                              = to_uint(aj[i]["id"]);
        std::string attr_string = aj[i]["attr"].asString();
        sscanf( attr_string.c_str(), "%u%%%u", &ptotemglyphhide->attr.first, &ptotemglyphhide->attr.second );

        Add(ptotemglyphhide);
        ++count;
        LOG_DEBUG("id:%u,", ptotemglyphhide->id);
    }
    LOG_INFO("TotemGlyphHide.xls:%d", count);
}

void CTotemGlyphHideData::ClearData(void)
{
    for( UInt32TotemGlyphHideMap::iterator iter = id_totemglyphhide_map.begin();
        iter != id_totemglyphhide_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_totemglyphhide_map.clear();
}

CTotemGlyphHideData::SData* CTotemGlyphHideData::Find( uint32 id )
{
    UInt32TotemGlyphHideMap::iterator iter = id_totemglyphhide_map.find(id);
    if ( iter != id_totemglyphhide_map.end() )
        return iter->second;
    return NULL;
}

void CTotemGlyphHideData::Add(SData* ptotemglyphhide)
{
    id_totemglyphhide_map[ptotemglyphhide->id] = ptotemglyphhide;
}
