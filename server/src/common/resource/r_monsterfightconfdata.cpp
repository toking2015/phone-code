#include "jsonconfig.h"
#include "r_monsterfightconfdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CMonsterFightConfData::CMonsterFightConfData()
{
}

CMonsterFightConfData::~CMonsterFightConfData()
{
    resource_clear(id_monsterfightconf_map);
}

void CMonsterFightConfData::LoadData(void)
{
    CJson jc = CJson::Load( "MonsterFightConf" );

    theResDataMgr.insert(this);
    resource_clear(id_monsterfightconf_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pmonsterfightconf             = new SData;
        pmonsterfightconf->index                           = to_uint(aj[i]["index"]);
        S2UInt32 add;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "add%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &add.first, &add.second ) )
                break;
            pmonsterfightconf->add.push_back(add);
        }
        S2UInt32 totemadd;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "totemadd%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &totemadd.first, &totemadd.second ) )
                break;
            pmonsterfightconf->totemadd.push_back(totemadd);
        }

        Add(pmonsterfightconf);
        ++count;
        LOG_DEBUG("index:%u,", pmonsterfightconf->index);
    }
    LOG_INFO("MonsterFightConf.xls:%d", count);
}

void CMonsterFightConfData::ClearData(void)
{
    for( UInt32MonsterFightConfMap::iterator iter = id_monsterfightconf_map.begin();
        iter != id_monsterfightconf_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_monsterfightconf_map.clear();
}

CMonsterFightConfData::SData* CMonsterFightConfData::Find( uint32 index )
{
    UInt32MonsterFightConfMap::iterator iter = id_monsterfightconf_map.find(index);
    if ( iter != id_monsterfightconf_map.end() )
        return iter->second;
    return NULL;
}

void CMonsterFightConfData::Add(SData* pmonsterfightconf)
{
    id_monsterfightconf_map[pmonsterfightconf->index] = pmonsterfightconf;
}
