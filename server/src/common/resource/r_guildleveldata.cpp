#include "jsonconfig.h"
#include "r_guildleveldata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CGuildLevelData::CGuildLevelData()
{
}

CGuildLevelData::~CGuildLevelData()
{
    resource_clear(id_guildlevel_map);
}

void CGuildLevelData::LoadData(void)
{
    CJson jc = CJson::Load( "GuildLevel" );

    theResDataMgr.insert(this);
    resource_clear(id_guildlevel_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pguildlevel                   = new SData;
        pguildlevel->level                           = to_uint(aj[i]["level"]);
        pguildlevel->levelup_xp                      = to_uint(aj[i]["levelup_xp"]);
        pguildlevel->member_count                    = to_uint(aj[i]["member_count"]);
        pguildlevel->vendible_begin                  = to_uint(aj[i]["vendible_begin"]);
        pguildlevel->vendible_end                    = to_uint(aj[i]["vendible_end"]);

        Add(pguildlevel);
        ++count;
        LOG_DEBUG("level:%u,levelup_xp:%u,member_count:%u,vendible_begin:%u,vendible_end:%u,", pguildlevel->level, pguildlevel->levelup_xp, pguildlevel->member_count, pguildlevel->vendible_begin, pguildlevel->vendible_end);
    }
    LOG_INFO("GuildLevel.xls:%d", count);
}

void CGuildLevelData::ClearData(void)
{
    for( UInt32GuildLevelMap::iterator iter = id_guildlevel_map.begin();
        iter != id_guildlevel_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_guildlevel_map.clear();
}

CGuildLevelData::SData* CGuildLevelData::Find( uint32 level )
{
    UInt32GuildLevelMap::iterator iter = id_guildlevel_map.find(level);
    if ( iter != id_guildlevel_map.end() )
        return iter->second;
    return NULL;
}

void CGuildLevelData::Add(SData* pguildlevel)
{
    id_guildlevel_map[pguildlevel->level] = pguildlevel;
}
