#include "jsonconfig.h"
#include "r_totemglyphdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTotemGlyphData::CTotemGlyphData()
{
}

CTotemGlyphData::~CTotemGlyphData()
{
    resource_clear(id_totemglyph_map);
}

void CTotemGlyphData::LoadData(void)
{
    CJson jc = CJson::Load( "TotemGlyph" );

    theResDataMgr.insert(this);
    resource_clear(id_totemglyph_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptotemglyph                   = new SData;
        ptotemglyph->id                              = to_uint(aj[i]["id"]);
        ptotemglyph->name                            = to_str(aj[i]["name"]);
        ptotemglyph->type                            = to_uint(aj[i]["type"]);
        ptotemglyph->quality                         = to_uint(aj[i]["quality"]);
        S2UInt32 attrs;
        for ( uint32 j = 1; j <= 5; ++j )
        {
            std::string buff = strprintf( "attrs%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &attrs.first, &attrs.second ) )
                break;
            ptotemglyph->attrs.push_back(attrs);
        }

        Add(ptotemglyph);
        ++count;
        LOG_DEBUG("id:%u,name:%s,type:%u,quality:%u,", ptotemglyph->id, ptotemglyph->name.c_str(), ptotemglyph->type, ptotemglyph->quality);
    }
    LOG_INFO("TotemGlyph.xls:%d", count);
}

void CTotemGlyphData::ClearData(void)
{
    for( UInt32TotemGlyphMap::iterator iter = id_totemglyph_map.begin();
        iter != id_totemglyph_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_totemglyph_map.clear();
}

CTotemGlyphData::SData* CTotemGlyphData::Find( uint32 id )
{
    UInt32TotemGlyphMap::iterator iter = id_totemglyph_map.find(id);
    if ( iter != id_totemglyph_map.end() )
        return iter->second;
    return NULL;
}

void CTotemGlyphData::Add(SData* ptotemglyph)
{
    id_totemglyph_map[ptotemglyph->id] = ptotemglyph;
}
