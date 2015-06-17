#include "jsonconfig.h"
#include "r_templeglyphdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTempleGlyphData::CTempleGlyphData()
{
}

CTempleGlyphData::~CTempleGlyphData()
{
    resource_clear(id_templeglyph_map);
}

void CTempleGlyphData::LoadData(void)
{
    CJson jc = CJson::Load( "TempleGlyph" );

    theResDataMgr.insert(this);
    resource_clear(id_templeglyph_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptempleglyph                  = new SData;
        ptempleglyph->id                              = to_uint(aj[i]["id"]);
        ptempleglyph->name                            = to_str(aj[i]["name"]);
        ptempleglyph->type                            = to_uint(aj[i]["type"]);
        ptempleglyph->quality                         = to_uint(aj[i]["quality"]);
        ptempleglyph->init_lv                         = to_uint(aj[i]["init_lv"]);
        ptempleglyph->exp                             = to_uint(aj[i]["exp"]);
        ptempleglyph->icon                            = to_str(aj[i]["icon"]);
        ptempleglyph->icon2                           = to_str(aj[i]["icon2"]);

        Add(ptempleglyph);
        ++count;
        LOG_DEBUG("id:%u,name:%s,type:%u,quality:%u,init_lv:%u,exp:%u,icon:%s,icon2:%s,", ptempleglyph->id, ptempleglyph->name.c_str(), ptempleglyph->type, ptempleglyph->quality, ptempleglyph->init_lv, ptempleglyph->exp, ptempleglyph->icon.c_str(), ptempleglyph->icon2.c_str());
    }
    LOG_INFO("TempleGlyph.xls:%d", count);
}

void CTempleGlyphData::ClearData(void)
{
    for( UInt32TempleGlyphMap::iterator iter = id_templeglyph_map.begin();
        iter != id_templeglyph_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_templeglyph_map.clear();
}

CTempleGlyphData::SData* CTempleGlyphData::Find( uint32 id )
{
    UInt32TempleGlyphMap::iterator iter = id_templeglyph_map.find(id);
    if ( iter != id_templeglyph_map.end() )
        return iter->second;
    return NULL;
}

void CTempleGlyphData::Add(SData* ptempleglyph)
{
    id_templeglyph_map[ptempleglyph->id] = ptempleglyph;
}
