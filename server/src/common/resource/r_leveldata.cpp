#include "jsonconfig.h"
#include "r_leveldata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CLevelData::CLevelData()
{
}

CLevelData::~CLevelData()
{
    resource_clear(id_level_map);
}

void CLevelData::LoadData(void)
{
    CJson jc = CJson::Load( "Level" );

    theResDataMgr.insert(this);
    resource_clear(id_level_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *plevel                        = new SData;
        plevel->level                           = to_uint(aj[i]["level"]);
        plevel->team_xp                         = to_uint(aj[i]["team_xp"]);
        plevel->vip_xp                          = to_uint(aj[i]["vip_xp"]);
        plevel->strength                        = to_uint(aj[i]["strength"]);
        plevel->strength_buy                    = to_uint(aj[i]["strength_buy"]);
        plevel->strength_price                  = to_uint(aj[i]["strength_price"]);
        plevel->strength_give                   = to_uint(aj[i]["strength_give"]);
        plevel->formation_count                 = to_uint(aj[i]["formation_count"]);
        plevel->formation_totem_count            = to_uint(aj[i]["formation_totem_count"]);
        plevel->soldier_lv                      = to_uint(aj[i]["soldier_lv"]);
        plevel->active_score_max                = to_uint(aj[i]["active_score_max"]);
        plevel->building_gold_times             = to_uint(aj[i]["building_gold_times"]);
        plevel->building_water_times            = to_uint(aj[i]["building_water_times"]);
        plevel->singlearena_times               = to_uint(aj[i]["singlearena_times"]);
        plevel->singlearena_price               = to_uint(aj[i]["singlearena_price"]);
        std::string task_30001_string = aj[i]["task_30001"].asString();
        sscanf( task_30001_string.c_str(), "%u%%%u%%%u", &plevel->task_30001.cate, &plevel->task_30001.objid, &plevel->task_30001.val );
        std::string task_30002_string = aj[i]["task_30002"].asString();
        sscanf( task_30002_string.c_str(), "%u%%%u%%%u", &plevel->task_30002.cate, &plevel->task_30002.objid, &plevel->task_30002.val );
        plevel->copy_normal_reset_times            = to_uint(aj[i]["copy_normal_reset_times"]);
        plevel->copy_elite_reset_times            = to_uint(aj[i]["copy_elite_reset_times"]);
        plevel->copy_normal_reset_price            = to_uint(aj[i]["copy_normal_reset_price"]);
        plevel->copy_elite_reset_price            = to_uint(aj[i]["copy_elite_reset_price"]);
        plevel->open_desc                       = to_str(aj[i]["open_desc"]);
        plevel->tomb_ratio                      = to_uint(aj[i]["tomb_ratio"]);
        plevel->vip_rights_desc                 = to_str(aj[i]["vip_rights_desc"]);
        plevel->glyph_lv                        = to_uint(aj[i]["glyph_lv"]);

        Add(plevel);
        ++count;
        LOG_DEBUG("level:%u,team_xp:%u,vip_xp:%u,strength:%u,strength_buy:%u,strength_price:%u,strength_give:%u,formation_count:%u,formation_totem_count:%u,soldier_lv:%u,active_score_max:%u,building_gold_times:%u,building_water_times:%u,singlearena_times:%u,singlearena_price:%u,copy_normal_reset_times:%u,copy_elite_reset_times:%u,copy_normal_reset_price:%u,copy_elite_reset_price:%u,open_desc:%s,tomb_ratio:%u,vip_rights_desc:%s,glyph_lv:%u,", plevel->level, plevel->team_xp, plevel->vip_xp, plevel->strength, plevel->strength_buy, plevel->strength_price, plevel->strength_give, plevel->formation_count, plevel->formation_totem_count, plevel->soldier_lv, plevel->active_score_max, plevel->building_gold_times, plevel->building_water_times, plevel->singlearena_times, plevel->singlearena_price, plevel->copy_normal_reset_times, plevel->copy_elite_reset_times, plevel->copy_normal_reset_price, plevel->copy_elite_reset_price, plevel->open_desc.c_str(), plevel->tomb_ratio, plevel->vip_rights_desc.c_str(), plevel->glyph_lv);
    }
    LOG_INFO("Level.xls:%d", count);
}

void CLevelData::ClearData(void)
{
    for( UInt32LevelMap::iterator iter = id_level_map.begin();
        iter != id_level_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_level_map.clear();
}

CLevelData::SData* CLevelData::Find( uint32 level )
{
    UInt32LevelMap::iterator iter = id_level_map.find(level);
    if ( iter != id_level_map.end() )
        return iter->second;
    return NULL;
}

void CLevelData::Add(SData* plevel)
{
    id_level_map[plevel->level] = plevel;
}
