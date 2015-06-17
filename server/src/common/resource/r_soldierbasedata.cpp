#include "jsonconfig.h"
#include "r_soldierbasedata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierBaseData::CSoldierBaseData()
{
}

CSoldierBaseData::~CSoldierBaseData()
{
    resource_clear(id_soldierbase_map);
}

void CSoldierBaseData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierBase" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierbase_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierbase                  = new SData;
        psoldierbase->id                              = to_uint(aj[i]["id"]);
        psoldierbase->hp                              = to_uint(aj[i]["hp"]);
        psoldierbase->physical_ack                    = to_uint(aj[i]["physical_ack"]);
        psoldierbase->physical_def                    = to_uint(aj[i]["physical_def"]);
        psoldierbase->magic_ack                       = to_uint(aj[i]["magic_ack"]);
        psoldierbase->magic_def                       = to_uint(aj[i]["magic_def"]);
        psoldierbase->speed                           = to_uint(aj[i]["speed"]);
        psoldierbase->critper                         = to_uint(aj[i]["critper"]);
        psoldierbase->crithurt                        = to_uint(aj[i]["crithurt"]);
        psoldierbase->critper_def                     = to_uint(aj[i]["critper_def"]);
        psoldierbase->crithurt_def                    = to_uint(aj[i]["crithurt_def"]);
        psoldierbase->hitper                          = to_uint(aj[i]["hitper"]);
        psoldierbase->dodgeper                        = to_uint(aj[i]["dodgeper"]);
        psoldierbase->parryper                        = to_uint(aj[i]["parryper"]);
        psoldierbase->parryper_dec                    = to_uint(aj[i]["parryper_dec"]);
        psoldierbase->recover_critper                 = to_uint(aj[i]["recover_critper"]);
        psoldierbase->recover_critper_def             = to_uint(aj[i]["recover_critper_def"]);
        psoldierbase->recover_add_fix                 = to_uint(aj[i]["recover_add_fix"]);
        psoldierbase->recover_del_fix                 = to_uint(aj[i]["recover_del_fix"]);
        psoldierbase->recover_add_per                 = to_uint(aj[i]["recover_add_per"]);
        psoldierbase->recover_del_per                 = to_uint(aj[i]["recover_del_per"]);
        psoldierbase->rage_add_fix                    = to_uint(aj[i]["rage_add_fix"]);
        psoldierbase->rage_del_fix                    = to_uint(aj[i]["rage_del_fix"]);
        psoldierbase->rage_add_per                    = to_uint(aj[i]["rage_add_per"]);
        psoldierbase->rage_del_per                    = to_uint(aj[i]["rage_del_per"]);
        psoldierbase->initial_rage                    = to_uint(aj[i]["initial_rage"]);

        Add(psoldierbase);
        ++count;
        LOG_DEBUG("id:%u,hp:%u,physical_ack:%u,physical_def:%u,magic_ack:%u,magic_def:%u,speed:%u,critper:%u,crithurt:%u,critper_def:%u,crithurt_def:%u,hitper:%u,dodgeper:%u,parryper:%u,parryper_dec:%u,recover_critper:%u,recover_critper_def:%u,recover_add_fix:%u,recover_del_fix:%u,recover_add_per:%u,recover_del_per:%u,rage_add_fix:%u,rage_del_fix:%u,rage_add_per:%u,rage_del_per:%u,initial_rage:%u,", psoldierbase->id, psoldierbase->hp, psoldierbase->physical_ack, psoldierbase->physical_def, psoldierbase->magic_ack, psoldierbase->magic_def, psoldierbase->speed, psoldierbase->critper, psoldierbase->crithurt, psoldierbase->critper_def, psoldierbase->crithurt_def, psoldierbase->hitper, psoldierbase->dodgeper, psoldierbase->parryper, psoldierbase->parryper_dec, psoldierbase->recover_critper, psoldierbase->recover_critper_def, psoldierbase->recover_add_fix, psoldierbase->recover_del_fix, psoldierbase->recover_add_per, psoldierbase->recover_del_per, psoldierbase->rage_add_fix, psoldierbase->rage_del_fix, psoldierbase->rage_add_per, psoldierbase->rage_del_per, psoldierbase->initial_rage);
    }
    LOG_INFO("SoldierBase.xls:%d", count);
}

void CSoldierBaseData::ClearData(void)
{
    for( UInt32SoldierBaseMap::iterator iter = id_soldierbase_map.begin();
        iter != id_soldierbase_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_soldierbase_map.clear();
}

CSoldierBaseData::SData* CSoldierBaseData::Find( uint32 id )
{
    UInt32SoldierBaseMap::iterator iter = id_soldierbase_map.find(id);
    if ( iter != id_soldierbase_map.end() )
        return iter->second;
    return NULL;
}

void CSoldierBaseData::Add(SData* psoldierbase)
{
    id_soldierbase_map[psoldierbase->id] = psoldierbase;
}
