#include "jsonconfig.h"
#include "r_templegrouplevelupdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTempleGroupLevelUpData::CTempleGroupLevelUpData()
{
}

CTempleGroupLevelUpData::~CTempleGroupLevelUpData()
{
    resource_clear(id_templegrouplevelup_map);
}

void CTempleGroupLevelUpData::LoadData(void)
{
    CJson jc = CJson::Load( "TempleGroupLevelUp" );

    theResDataMgr.insert(this);
    resource_clear(id_templegrouplevelup_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptemplegrouplevelup           = new SData;
        ptemplegrouplevelup->id                              = to_uint(aj[i]["id"]);
        ptemplegrouplevelup->level                           = to_uint(aj[i]["level"]);
        ptemplegrouplevelup->star                            = to_uint(aj[i]["star"]);
        ptemplegrouplevelup->score                           = to_uint(aj[i]["score"]);
        S2UInt32 attrs;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "attrs%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &attrs.first, &attrs.second ) )
                break;
            ptemplegrouplevelup->attrs.push_back(attrs);
        }

        Add(ptemplegrouplevelup);
        ++count;
        LOG_DEBUG("id:%u,level:%u,star:%u,score:%u,", ptemplegrouplevelup->id, ptemplegrouplevelup->level, ptemplegrouplevelup->star, ptemplegrouplevelup->score);
    }
    LOG_INFO("TempleGroupLevelUp.xls:%d", count);
}

void CTempleGroupLevelUpData::ClearData(void)
{
    for( UInt32TempleGroupLevelUpMap::iterator iter = id_templegrouplevelup_map.begin();
        iter != id_templegrouplevelup_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_templegrouplevelup_map.clear();
}

CTempleGroupLevelUpData::SData* CTempleGroupLevelUpData::Find( uint32 id,uint32 level )
{
    return id_templegrouplevelup_map[id][level];
}

void CTempleGroupLevelUpData::Add(SData* ptemplegrouplevelup)
{
    id_templegrouplevelup_map[ptemplegrouplevelup->id][ptemplegrouplevelup->level] = ptemplegrouplevelup;
}
