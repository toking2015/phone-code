#include "jsonconfig.h"
#include "r_soldierdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierData::CSoldierData()
{
}

CSoldierData::~CSoldierData()
{
    resource_clear(id_soldier_map);
}

void CSoldierData::LoadData(void)
{
    CJson jc = CJson::Load( "Soldier" );

    theResDataMgr.insert(this);
    resource_clear(id_soldier_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldier                      = new SData;
        psoldier->id                              = to_uint(aj[i]["id"]);
        psoldier->locale_id                       = to_uint(aj[i]["locale_id"]);
        psoldier->name                            = to_str(aj[i]["name"]);
        psoldier->star                            = to_uint(aj[i]["star"]);
        psoldier->quality                         = to_uint(aj[i]["quality"]);
        psoldier->gender                          = to_uint(aj[i]["gender"]);
        psoldier->equip_type                      = to_uint(aj[i]["equip_type"]);
        psoldier->animation_name                  = to_str(aj[i]["animation_name"]);
        psoldier->avatar                          = to_uint(aj[i]["avatar"]);
        psoldier->occupation                      = to_uint(aj[i]["occupation"]);
        psoldier->formation                       = to_uint(aj[i]["formation"]);
        psoldier->race                            = to_uint(aj[i]["race"]);
        psoldier->source                          = to_uint(aj[i]["source"]);
        std::string star_cost_string = aj[i]["star_cost"].asString();
        sscanf( star_cost_string.c_str(), "%u%%%u%%%u", &psoldier->star_cost.cate, &psoldier->star_cost.objid, &psoldier->star_cost.val );
        std::string exist_give_string = aj[i]["exist_give"].asString();
        sscanf( exist_give_string.c_str(), "%u%%%u%%%u", &psoldier->exist_give.cate, &psoldier->exist_give.objid, &psoldier->exist_give.val );
        S2UInt32 get_attr;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "get_attr%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &get_attr.first, &get_attr.second ) )
                break;
            psoldier->get_attr.push_back(get_attr);
        }
        psoldier->get_score                       = to_uint(aj[i]["get_score"]);
        S2UInt32 skills;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "skills%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &skills.first, &skills.second ) )
                break;
            psoldier->skills.push_back(skills);
        }
        S2UInt32 odds;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "odds%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &odds.first, &odds.second ) )
                break;
            psoldier->odds.push_back(odds);
        }
        std::string sounds;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "sounds%d", j);
            sounds = to_str(aj[i][buff]);
            psoldier->sounds.push_back(sounds);
        }
        psoldier->desc                            = to_str(aj[i]["desc"]);

        Add(psoldier);
        ++count;
        LOG_DEBUG("id:%u,locale_id:%u,name:%s,star:%u,quality:%u,gender:%u,equip_type:%u,animation_name:%s,avatar:%u,occupation:%u,formation:%u,race:%u,source:%u,get_score:%u,desc:%s,", psoldier->id, psoldier->locale_id, psoldier->name.c_str(), psoldier->star, psoldier->quality, psoldier->gender, psoldier->equip_type, psoldier->animation_name.c_str(), psoldier->avatar, psoldier->occupation, psoldier->formation, psoldier->race, psoldier->source, psoldier->get_score, psoldier->desc.c_str());
    }
    LOG_INFO("Soldier.xls:%d", count);
}

void CSoldierData::ClearData(void)
{
    for( UInt32SoldierMap::iterator iter = id_soldier_map.begin();
        iter != id_soldier_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_soldier_map.clear();
}

CSoldierData::SData* CSoldierData::Find( uint32 id )
{
    UInt32SoldierMap::iterator iter = id_soldier_map.find(id);
    if ( iter != id_soldier_map.end() )
        return iter->second;
    return NULL;
}

void CSoldierData::Add(SData* psoldier)
{
    id_soldier_map[psoldier->id] = psoldier;
}
