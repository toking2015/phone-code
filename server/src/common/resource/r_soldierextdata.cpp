#include "jsonconfig.h"
#include "r_soldierextdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierExtData::CSoldierExtData()
{
}

CSoldierExtData::~CSoldierExtData()
{
    resource_clear(id_soldierext_map);
}

void CSoldierExtData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierExt" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierext_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierext                   = new SData;
        psoldierext->id                              = to_uint(aj[i]["id"]);
        psoldierext->soldier_id                      = to_uint(aj[i]["soldier_id"]);
        psoldierext->level                           = to_uint(aj[i]["level"]);
        psoldierext->fighting                        = to_uint(aj[i]["fighting"]);
        psoldierext->star                            = to_uint(aj[i]["star"]);
        psoldierext->quality                         = to_uint(aj[i]["quality"]);
        psoldierext->initial_rage                    = to_uint(aj[i]["initial_rage"]);
        psoldierext->hp                              = to_uint(aj[i]["hp"]);
        psoldierext->physical_ack                    = to_uint(aj[i]["physical_ack"]);
        psoldierext->physical_def                    = to_uint(aj[i]["physical_def"]);
        psoldierext->magic_ack                       = to_uint(aj[i]["magic_ack"]);
        psoldierext->magic_def                       = to_uint(aj[i]["magic_def"]);
        psoldierext->speed                           = to_uint(aj[i]["speed"]);
        psoldierext->critper                         = to_uint(aj[i]["critper"]);
        psoldierext->crithurt                        = to_uint(aj[i]["crithurt"]);
        psoldierext->critper_def                     = to_uint(aj[i]["critper_def"]);
        psoldierext->crithurt_def                    = to_uint(aj[i]["crithurt_def"]);
        psoldierext->hitper                          = to_uint(aj[i]["hitper"]);
        psoldierext->dodgeper                        = to_uint(aj[i]["dodgeper"]);
        psoldierext->parryper                        = to_uint(aj[i]["parryper"]);
        psoldierext->parryper_dec                    = to_uint(aj[i]["parryper_dec"]);
        psoldierext->stun_def                        = to_uint(aj[i]["stun_def"]);
        psoldierext->silent_def                      = to_uint(aj[i]["silent_def"]);
        psoldierext->weak_def                        = to_uint(aj[i]["weak_def"]);
        psoldierext->fire_def                        = to_uint(aj[i]["fire_def"]);
        psoldierext->rebound_physical_ack            = to_uint(aj[i]["rebound_physical_ack"]);
        psoldierext->rebound_magic_ack               = to_uint(aj[i]["rebound_magic_ack"]);
        S2UInt32 odds;
        for ( uint32 j = 1; j <= 7; ++j )
        {
            std::string buff = strprintf( "odds%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &odds.first, &odds.second ) )
                break;
            psoldierext->odds.push_back(odds);
        }
        S2UInt32 skills;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "skills%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &skills.first, &skills.second ) )
                break;
            psoldierext->skills.push_back(skills);
        }
        psoldierext->recover_critper                 = to_uint(aj[i]["recover_critper"]);
        psoldierext->recover_critper_def             = to_uint(aj[i]["recover_critper_def"]);
        psoldierext->recover_add_fix                 = to_uint(aj[i]["recover_add_fix"]);
        psoldierext->recover_del_fix                 = to_uint(aj[i]["recover_del_fix"]);
        psoldierext->recover_add_per                 = to_uint(aj[i]["recover_add_per"]);
        psoldierext->recover_del_per                 = to_uint(aj[i]["recover_del_per"]);
        psoldierext->rage_add_fix                    = to_uint(aj[i]["rage_add_fix"]);
        psoldierext->rage_del_fix                    = to_uint(aj[i]["rage_del_fix"]);
        psoldierext->rage_add_per                    = to_uint(aj[i]["rage_add_per"]);
        psoldierext->rage_del_per                    = to_uint(aj[i]["rage_del_per"]);

        Add(psoldierext);
        ++count;
        LOG_DEBUG("id:%u,soldier_id:%u,level:%u,fighting:%u,star:%u,quality:%u,initial_rage:%u,hp:%u,physical_ack:%u,physical_def:%u,magic_ack:%u,magic_def:%u,speed:%u,critper:%u,crithurt:%u,critper_def:%u,crithurt_def:%u,hitper:%u,dodgeper:%u,parryper:%u,parryper_dec:%u,stun_def:%u,silent_def:%u,weak_def:%u,fire_def:%u,rebound_physical_ack:%u,rebound_magic_ack:%u,recover_critper:%u,recover_critper_def:%u,recover_add_fix:%u,recover_del_fix:%u,recover_add_per:%u,recover_del_per:%u,rage_add_fix:%u,rage_del_fix:%u,rage_add_per:%u,rage_del_per:%u,", psoldierext->id, psoldierext->soldier_id, psoldierext->level, psoldierext->fighting, psoldierext->star, psoldierext->quality, psoldierext->initial_rage, psoldierext->hp, psoldierext->physical_ack, psoldierext->physical_def, psoldierext->magic_ack, psoldierext->magic_def, psoldierext->speed, psoldierext->critper, psoldierext->crithurt, psoldierext->critper_def, psoldierext->crithurt_def, psoldierext->hitper, psoldierext->dodgeper, psoldierext->parryper, psoldierext->parryper_dec, psoldierext->stun_def, psoldierext->silent_def, psoldierext->weak_def, psoldierext->fire_def, psoldierext->rebound_physical_ack, psoldierext->rebound_magic_ack, psoldierext->recover_critper, psoldierext->recover_critper_def, psoldierext->recover_add_fix, psoldierext->recover_del_fix, psoldierext->recover_add_per, psoldierext->recover_del_per, psoldierext->rage_add_fix, psoldierext->rage_del_fix, psoldierext->rage_add_per, psoldierext->rage_del_per);
    }
    LOG_INFO("SoldierExt.xls:%d", count);
}

void CSoldierExtData::ClearData(void)
{
    for( UInt32SoldierExtMap::iterator iter = id_soldierext_map.begin();
        iter != id_soldierext_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_soldierext_map.clear();
}

CSoldierExtData::SData* CSoldierExtData::Find( uint32 id )
{
    UInt32SoldierExtMap::iterator iter = id_soldierext_map.find(id);
    if ( iter != id_soldierext_map.end() )
        return iter->second;
    return NULL;
}

void CSoldierExtData::Add(SData* psoldierext)
{
    id_soldierext_map[psoldierext->id] = psoldierext;
}
