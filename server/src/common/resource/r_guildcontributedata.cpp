#include "jsonconfig.h"
#include "r_guildcontributedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CGuildContributeData::CGuildContributeData()
{
}

CGuildContributeData::~CGuildContributeData()
{
    resource_clear(id_guildcontribute_map);
}

void CGuildContributeData::LoadData(void)
{
    CJson jc = CJson::Load( "GuildContribute" );

    theResDataMgr.insert(this);
    resource_clear(id_guildcontribute_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pguildcontribute              = new SData;
        pguildcontribute->id                              = to_uint(aj[i]["id"]);
        std::string cost_string = aj[i]["cost"].asString();
        sscanf( cost_string.c_str(), "%u%%%u%%%u", &pguildcontribute->cost.cate, &pguildcontribute->cost.objid, &pguildcontribute->cost.val );
        pguildcontribute->contribute                      = to_uint(aj[i]["contribute"]);
        S3UInt32 coins;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "coins%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &coins.cate, &coins.objid, &coins.val ) )
                break;
            pguildcontribute->coins.push_back(coins);
        }
        pguildcontribute->name                            = to_str(aj[i]["name"]);

        Add(pguildcontribute);
        ++count;
        LOG_DEBUG("id:%u,contribute:%u,name:%s,", pguildcontribute->id, pguildcontribute->contribute, pguildcontribute->name.c_str());
    }
    LOG_INFO("GuildContribute.xls:%d", count);
}

void CGuildContributeData::ClearData(void)
{
    for( UInt32GuildContributeMap::iterator iter = id_guildcontribute_map.begin();
        iter != id_guildcontribute_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_guildcontribute_map.clear();
}

CGuildContributeData::SData* CGuildContributeData::Find( uint32 id )
{
    UInt32GuildContributeMap::iterator iter = id_guildcontribute_map.find(id);
    if ( iter != id_guildcontribute_map.end() )
        return iter->second;
    return NULL;
}

void CGuildContributeData::Add(SData* pguildcontribute)
{
    id_guildcontribute_map[pguildcontribute->id] = pguildcontribute;
}
