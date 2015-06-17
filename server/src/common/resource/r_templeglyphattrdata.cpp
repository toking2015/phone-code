#include "jsonconfig.h"
#include "r_templeglyphattrdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTempleGlyphAttrData::CTempleGlyphAttrData()
{
}

CTempleGlyphAttrData::~CTempleGlyphAttrData()
{
    resource_clear(id_templeglyphattr_map);
}

void CTempleGlyphAttrData::LoadData(void)
{
    CJson jc = CJson::Load( "TempleGlyphAttr" );

    theResDataMgr.insert(this);
    resource_clear(id_templeglyphattr_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptempleglyphattr              = new SData;
        ptempleglyphattr->id                              = to_uint(aj[i]["id"]);
        ptempleglyphattr->level                           = to_uint(aj[i]["level"]);
        ptempleglyphattr->exp                             = to_uint(aj[i]["exp"]);
        S2UInt32 attrs;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "attrs%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &attrs.first, &attrs.second ) )
                break;
            ptempleglyphattr->attrs.push_back(attrs);
        }

        Add(ptempleglyphattr);
        ++count;
        LOG_DEBUG("id:%u,level:%u,exp:%u,", ptempleglyphattr->id, ptempleglyphattr->level, ptempleglyphattr->exp);
    }
    LOG_INFO("TempleGlyphAttr.xls:%d", count);
}

void CTempleGlyphAttrData::ClearData(void)
{
    for( UInt32TempleGlyphAttrMap::iterator iter = id_templeglyphattr_map.begin();
        iter != id_templeglyphattr_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_templeglyphattr_map.clear();
}

CTempleGlyphAttrData::SData* CTempleGlyphAttrData::Find( uint32 id,uint32 level )
{
    return id_templeglyphattr_map[id][level];
}

void CTempleGlyphAttrData::Add(SData* ptempleglyphattr)
{
    id_templeglyphattr_map[ptempleglyphattr->id][ptempleglyphattr->level] = ptempleglyphattr;
}
