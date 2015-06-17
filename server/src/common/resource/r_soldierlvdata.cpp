#include "jsonconfig.h"
#include "r_soldierlvdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierLvData::CSoldierLvData()
{
}

CSoldierLvData::~CSoldierLvData()
{
    resource_clear(id_soldierlv_map);
}

void CSoldierLvData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierLv" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierlv_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierlv                    = new SData;
        psoldierlv->lv                              = to_uint(aj[i]["lv"]);
        std::string cost_string = aj[i]["cost"].asString();
        sscanf( cost_string.c_str(), "%u%%%u%%%u", &psoldierlv->cost.cate, &psoldierlv->cost.objid, &psoldierlv->cost.val );
        psoldierlv->hp                              = to_uint(aj[i]["hp"]);
        psoldierlv->physical_ack                    = to_uint(aj[i]["physical_ack"]);
        psoldierlv->physical_def                    = to_uint(aj[i]["physical_def"]);
        psoldierlv->magic_ack                       = to_uint(aj[i]["magic_ack"]);
        psoldierlv->magic_def                       = to_uint(aj[i]["magic_def"]);
        psoldierlv->speed                           = to_uint(aj[i]["speed"]);
        psoldierlv->critper                         = to_uint(aj[i]["critper"]);
        psoldierlv->crithurt                        = to_uint(aj[i]["crithurt"]);
        psoldierlv->critper_def                     = to_uint(aj[i]["critper_def"]);
        psoldierlv->crithurt_def                    = to_uint(aj[i]["crithurt_def"]);
        psoldierlv->hitper                          = to_uint(aj[i]["hitper"]);
        psoldierlv->dodgeper                        = to_uint(aj[i]["dodgeper"]);
        psoldierlv->parryper                        = to_uint(aj[i]["parryper"]);
        psoldierlv->parryper_dec                    = to_uint(aj[i]["parryper_dec"]);
        psoldierlv->recover_critper                 = to_uint(aj[i]["recover_critper"]);
        psoldierlv->recover_critper_def             = to_uint(aj[i]["recover_critper_def"]);
        psoldierlv->recover_add_fix                 = to_uint(aj[i]["recover_add_fix"]);
        psoldierlv->recover_del_fix                 = to_uint(aj[i]["recover_del_fix"]);
        psoldierlv->recover_add_per                 = to_uint(aj[i]["recover_add_per"]);
        psoldierlv->recover_del_per                 = to_uint(aj[i]["recover_del_per"]);
        psoldierlv->rage_add_fix                    = to_uint(aj[i]["rage_add_fix"]);
        psoldierlv->rage_del_fix                    = to_uint(aj[i]["rage_del_fix"]);
        psoldierlv->rage_add_per                    = to_uint(aj[i]["rage_add_per"]);
        psoldierlv->rage_del_per                    = to_uint(aj[i]["rage_del_per"]);

        Add(psoldierlv);
        ++count;
        LOG_DEBUG("lv:%u,hp:%u,physical_ack:%u,physical_def:%u,magic_ack:%u,magic_def:%u,speed:%u,critper:%u,crithurt:%u,critper_def:%u,crithurt_def:%u,hitper:%u,dodgeper:%u,parryper:%u,parryper_dec:%u,recover_critper:%u,recover_critper_def:%u,recover_add_fix:%u,recover_del_fix:%u,recover_add_per:%u,recover_del_per:%u,rage_add_fix:%u,rage_del_fix:%u,rage_add_per:%u,rage_del_per:%u,", psoldierlv->lv, psoldierlv->hp, psoldierlv->physical_ack, psoldierlv->physical_def, psoldierlv->magic_ack, psoldierlv->magic_def, psoldierlv->speed, psoldierlv->critper, psoldierlv->crithurt, psoldierlv->critper_def, psoldierlv->crithurt_def, psoldierlv->hitper, psoldierlv->dodgeper, psoldierlv->parryper, psoldierlv->parryper_dec, psoldierlv->recover_critper, psoldierlv->recover_critper_def, psoldierlv->recover_add_fix, psoldierlv->recover_del_fix, psoldierlv->recover_add_per, psoldierlv->recover_del_per, psoldierlv->rage_add_fix, psoldierlv->rage_del_fix, psoldierlv->rage_add_per, psoldierlv->rage_del_per);
    }
    LOG_INFO("SoldierLv.xls:%d", count);
}

void CSoldierLvData::ClearData(void)
{
    for( UInt32SoldierLvMap::iterator iter = id_soldierlv_map.begin();
        iter != id_soldierlv_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_soldierlv_map.clear();
}

CSoldierLvData::SData* CSoldierLvData::Find( uint32 lv )
{
    UInt32SoldierLvMap::iterator iter = id_soldierlv_map.find(lv);
    if ( iter != id_soldierlv_map.end() )
        return iter->second;
    return NULL;
}

void CSoldierLvData::Add(SData* psoldierlv)
{
    id_soldierlv_map[psoldierlv->lv] = psoldierlv;
}
