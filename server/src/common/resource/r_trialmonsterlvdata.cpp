#include "jsonconfig.h"
#include "r_trialmonsterlvdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTrialMonsterLvData::CTrialMonsterLvData()
{
}

CTrialMonsterLvData::~CTrialMonsterLvData()
{
    resource_clear(id_trialmonsterlv_map);
}

void CTrialMonsterLvData::LoadData(void)
{
    CJson jc = CJson::Load( "TrialMonsterLv" );

    theResDataMgr.insert(this);
    resource_clear(id_trialmonsterlv_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptrialmonsterlv               = new SData;
        ptrialmonsterlv->lv                              = to_uint(aj[i]["lv"]);
        ptrialmonsterlv->hp                              = to_uint(aj[i]["hp"]);
        ptrialmonsterlv->physical_ack                    = to_uint(aj[i]["physical_ack"]);
        ptrialmonsterlv->physical_def                    = to_uint(aj[i]["physical_def"]);
        ptrialmonsterlv->magic_ack                       = to_uint(aj[i]["magic_ack"]);
        ptrialmonsterlv->magic_def                       = to_uint(aj[i]["magic_def"]);
        ptrialmonsterlv->speed                           = to_uint(aj[i]["speed"]);
        ptrialmonsterlv->critper                         = to_uint(aj[i]["critper"]);
        ptrialmonsterlv->crithurt                        = to_uint(aj[i]["crithurt"]);
        ptrialmonsterlv->critper_def                     = to_uint(aj[i]["critper_def"]);
        ptrialmonsterlv->crithurt_def                    = to_uint(aj[i]["crithurt_def"]);
        ptrialmonsterlv->hitper                          = to_uint(aj[i]["hitper"]);
        ptrialmonsterlv->dodgeper                        = to_uint(aj[i]["dodgeper"]);
        ptrialmonsterlv->parryper                        = to_uint(aj[i]["parryper"]);
        ptrialmonsterlv->parryper_dec                    = to_uint(aj[i]["parryper_dec"]);
        ptrialmonsterlv->recover_critper                 = to_uint(aj[i]["recover_critper"]);
        ptrialmonsterlv->recover_critper_def             = to_uint(aj[i]["recover_critper_def"]);
        ptrialmonsterlv->recover_add_fix                 = to_uint(aj[i]["recover_add_fix"]);
        ptrialmonsterlv->recover_del_fix                 = to_uint(aj[i]["recover_del_fix"]);
        ptrialmonsterlv->recover_add_per                 = to_uint(aj[i]["recover_add_per"]);
        ptrialmonsterlv->recover_del_per                 = to_uint(aj[i]["recover_del_per"]);
        ptrialmonsterlv->rage_add_fix                    = to_uint(aj[i]["rage_add_fix"]);
        ptrialmonsterlv->rage_del_fix                    = to_uint(aj[i]["rage_del_fix"]);
        ptrialmonsterlv->rage_add_per                    = to_uint(aj[i]["rage_add_per"]);
        ptrialmonsterlv->rage_del_per                    = to_uint(aj[i]["rage_del_per"]);

        Add(ptrialmonsterlv);
        ++count;
        LOG_DEBUG("lv:%u,hp:%u,physical_ack:%u,physical_def:%u,magic_ack:%u,magic_def:%u,speed:%u,critper:%u,crithurt:%u,critper_def:%u,crithurt_def:%u,hitper:%u,dodgeper:%u,parryper:%u,parryper_dec:%u,recover_critper:%u,recover_critper_def:%u,recover_add_fix:%u,recover_del_fix:%u,recover_add_per:%u,recover_del_per:%u,rage_add_fix:%u,rage_del_fix:%u,rage_add_per:%u,rage_del_per:%u,", ptrialmonsterlv->lv, ptrialmonsterlv->hp, ptrialmonsterlv->physical_ack, ptrialmonsterlv->physical_def, ptrialmonsterlv->magic_ack, ptrialmonsterlv->magic_def, ptrialmonsterlv->speed, ptrialmonsterlv->critper, ptrialmonsterlv->crithurt, ptrialmonsterlv->critper_def, ptrialmonsterlv->crithurt_def, ptrialmonsterlv->hitper, ptrialmonsterlv->dodgeper, ptrialmonsterlv->parryper, ptrialmonsterlv->parryper_dec, ptrialmonsterlv->recover_critper, ptrialmonsterlv->recover_critper_def, ptrialmonsterlv->recover_add_fix, ptrialmonsterlv->recover_del_fix, ptrialmonsterlv->recover_add_per, ptrialmonsterlv->recover_del_per, ptrialmonsterlv->rage_add_fix, ptrialmonsterlv->rage_del_fix, ptrialmonsterlv->rage_add_per, ptrialmonsterlv->rage_del_per);
    }
    LOG_INFO("TrialMonsterLv.xls:%d", count);
}

void CTrialMonsterLvData::ClearData(void)
{
    for( UInt32TrialMonsterLvMap::iterator iter = id_trialmonsterlv_map.begin();
        iter != id_trialmonsterlv_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_trialmonsterlv_map.clear();
}

CTrialMonsterLvData::SData* CTrialMonsterLvData::Find( uint32 lv )
{
    UInt32TrialMonsterLvMap::iterator iter = id_trialmonsterlv_map.find(lv);
    if ( iter != id_trialmonsterlv_map.end() )
        return iter->second;
    return NULL;
}

void CTrialMonsterLvData::Add(SData* ptrialmonsterlv)
{
    id_trialmonsterlv_map[ptrialmonsterlv->lv] = ptrialmonsterlv;
}
