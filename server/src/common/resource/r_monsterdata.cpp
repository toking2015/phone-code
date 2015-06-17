#include "jsonconfig.h"
#include "r_monsterdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CMonsterData::CMonsterData()
{
}

CMonsterData::~CMonsterData()
{
    resource_clear(id_monster_map);
}

void CMonsterData::LoadData(void)
{
    CJson jc = CJson::Load( "Monster" );

    theResDataMgr.insert(this);
    resource_clear(id_monster_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pmonster                      = new SData;
        pmonster->id                              = to_uint(aj[i]["id"]);
        pmonster->local_id                        = to_uint(aj[i]["local_id"]);
        pmonster->class_id                        = to_uint(aj[i]["class_id"]);
        pmonster->name                            = to_str(aj[i]["name"]);
        pmonster->type                            = to_uint(aj[i]["type"]);
        pmonster->equip_type                      = to_uint(aj[i]["equip_type"]);
        pmonster->level                           = to_uint(aj[i]["level"]);
        pmonster->animation_name                  = to_str(aj[i]["animation_name"]);
        pmonster->music                           = to_str(aj[i]["music"]);
        pmonster->avatar                          = to_uint(aj[i]["avatar"]);
        pmonster->occupation                      = to_uint(aj[i]["occupation"]);
        pmonster->quality                         = to_uint(aj[i]["quality"]);
        uint32 packets;
        for ( uint32 j = 1; j <= 5; ++j )
        {
            std::string buff = strprintf( "packets%d", j);
            packets = to_uint(aj[i][buff]);
            pmonster->packets.push_back(packets);
        }
        pmonster->fight_value                     = to_uint(aj[i]["fight_value"]);
        pmonster->initial_rage                    = to_uint(aj[i]["initial_rage"]);
        pmonster->hp                              = to_uint(aj[i]["hp"]);
        pmonster->physical_ack                    = to_uint(aj[i]["physical_ack"]);
        pmonster->physical_def                    = to_uint(aj[i]["physical_def"]);
        pmonster->magic_ack                       = to_uint(aj[i]["magic_ack"]);
        pmonster->magic_def                       = to_uint(aj[i]["magic_def"]);
        pmonster->speed                           = to_uint(aj[i]["speed"]);
        pmonster->critper                         = to_uint(aj[i]["critper"]);
        pmonster->crithurt                        = to_uint(aj[i]["crithurt"]);
        pmonster->critper_def                     = to_uint(aj[i]["critper_def"]);
        pmonster->crithurt_def                    = to_uint(aj[i]["crithurt_def"]);
        pmonster->hitper                          = to_uint(aj[i]["hitper"]);
        pmonster->dodgeper                        = to_uint(aj[i]["dodgeper"]);
        pmonster->parryper                        = to_uint(aj[i]["parryper"]);
        pmonster->parryper_dec                    = to_uint(aj[i]["parryper_dec"]);
        pmonster->stun_def                        = to_uint(aj[i]["stun_def"]);
        pmonster->silent_def                      = to_uint(aj[i]["silent_def"]);
        pmonster->weak_def                        = to_uint(aj[i]["weak_def"]);
        pmonster->fire_def                        = to_uint(aj[i]["fire_def"]);
        pmonster->rebound_physical_ack            = to_uint(aj[i]["rebound_physical_ack"]);
        pmonster->rebound_magic_ack               = to_uint(aj[i]["rebound_magic_ack"]);
        S2UInt32 odds;
        for ( uint32 j = 1; j <= 7; ++j )
        {
            std::string buff = strprintf( "odds%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &odds.first, &odds.second ) )
                break;
            pmonster->odds.push_back(odds);
        }
        S2UInt32 skills;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "skills%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &skills.first, &skills.second ) )
                break;
            pmonster->skills.push_back(skills);
        }
        pmonster->money                           = to_uint(aj[i]["money"]);
        pmonster->exp                             = to_uint(aj[i]["exp"]);
        pmonster->desc                            = to_str(aj[i]["desc"]);
        pmonster->hp_layer                        = to_uint(aj[i]["hp_layer"]);
        uint32 fight_monster;
        for ( uint32 j = 1; j <= 5; ++j )
        {
            std::string buff = strprintf( "fight_monster%d", j);
            fight_monster = to_uint(aj[i][buff]);
            pmonster->fight_monster.push_back(fight_monster);
        }
        pmonster->help_monster                    = to_uint(aj[i]["help_monster"]);
        pmonster->strength                        = to_uint(aj[i]["strength"]);
        pmonster->recover_critper                 = to_uint(aj[i]["recover_critper"]);
        pmonster->recover_critper_def             = to_uint(aj[i]["recover_critper_def"]);
        pmonster->recover_add_fix                 = to_uint(aj[i]["recover_add_fix"]);
        pmonster->recover_del_fix                 = to_uint(aj[i]["recover_del_fix"]);
        pmonster->recover_add_per                 = to_uint(aj[i]["recover_add_per"]);
        pmonster->recover_del_per                 = to_uint(aj[i]["recover_del_per"]);
        pmonster->rage_add_fix                    = to_uint(aj[i]["rage_add_fix"]);
        pmonster->rage_del_fix                    = to_uint(aj[i]["rage_del_fix"]);
        pmonster->rage_add_per                    = to_uint(aj[i]["rage_add_per"]);
        pmonster->rage_del_per                    = to_uint(aj[i]["rage_del_per"]);

        Add(pmonster);
        ++count;
        LOG_DEBUG("id:%u,local_id:%u,class_id:%u,name:%s,type:%u,equip_type:%u,level:%u,animation_name:%s,music:%s,avatar:%u,occupation:%u,quality:%u,fight_value:%u,initial_rage:%u,hp:%u,physical_ack:%u,physical_def:%u,magic_ack:%u,magic_def:%u,speed:%u,critper:%u,crithurt:%u,critper_def:%u,crithurt_def:%u,hitper:%u,dodgeper:%u,parryper:%u,parryper_dec:%u,stun_def:%u,silent_def:%u,weak_def:%u,fire_def:%u,rebound_physical_ack:%u,rebound_magic_ack:%u,money:%u,exp:%u,desc:%s,hp_layer:%u,help_monster:%u,strength:%u,recover_critper:%u,recover_critper_def:%u,recover_add_fix:%u,recover_del_fix:%u,recover_add_per:%u,recover_del_per:%u,rage_add_fix:%u,rage_del_fix:%u,rage_add_per:%u,rage_del_per:%u,", pmonster->id, pmonster->local_id, pmonster->class_id, pmonster->name.c_str(), pmonster->type, pmonster->equip_type, pmonster->level, pmonster->animation_name.c_str(), pmonster->music.c_str(), pmonster->avatar, pmonster->occupation, pmonster->quality, pmonster->fight_value, pmonster->initial_rage, pmonster->hp, pmonster->physical_ack, pmonster->physical_def, pmonster->magic_ack, pmonster->magic_def, pmonster->speed, pmonster->critper, pmonster->crithurt, pmonster->critper_def, pmonster->crithurt_def, pmonster->hitper, pmonster->dodgeper, pmonster->parryper, pmonster->parryper_dec, pmonster->stun_def, pmonster->silent_def, pmonster->weak_def, pmonster->fire_def, pmonster->rebound_physical_ack, pmonster->rebound_magic_ack, pmonster->money, pmonster->exp, pmonster->desc.c_str(), pmonster->hp_layer, pmonster->help_monster, pmonster->strength, pmonster->recover_critper, pmonster->recover_critper_def, pmonster->recover_add_fix, pmonster->recover_del_fix, pmonster->recover_add_per, pmonster->recover_del_per, pmonster->rage_add_fix, pmonster->rage_del_fix, pmonster->rage_add_per, pmonster->rage_del_per);
    }
    LOG_INFO("Monster.xls:%d", count);
}

void CMonsterData::ClearData(void)
{
    for( UInt32MonsterMap::iterator iter = id_monster_map.begin();
        iter != id_monster_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_monster_map.clear();
}

CMonsterData::SData* CMonsterData::Find( uint32 id )
{
    UInt32MonsterMap::iterator iter = id_monster_map.find(id);
    if ( iter != id_monster_map.end() )
        return iter->second;
    return NULL;
}

void CMonsterData::Add(SData* pmonster)
{
    id_monster_map[pmonster->id] = pmonster;
}
