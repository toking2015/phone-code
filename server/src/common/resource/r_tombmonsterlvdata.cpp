#include "jsonconfig.h"
#include "r_tombmonsterlvdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTombMonsterLvData::CTombMonsterLvData()
{
}

CTombMonsterLvData::~CTombMonsterLvData()
{
    resource_clear(id_tombmonsterlv_map);
}

void CTombMonsterLvData::LoadData(void)
{
    CJson jc = CJson::Load( "TombMonsterLv" );

    theResDataMgr.insert(this);
    resource_clear(id_tombmonsterlv_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptombmonsterlv                = new SData;
        ptombmonsterlv->lv                              = to_uint(aj[i]["lv"]);
        ptombmonsterlv->hp                              = to_uint(aj[i]["hp"]);
        ptombmonsterlv->physical_ack                    = to_uint(aj[i]["physical_ack"]);
        ptombmonsterlv->physical_def                    = to_uint(aj[i]["physical_def"]);
        ptombmonsterlv->magic_ack                       = to_uint(aj[i]["magic_ack"]);
        ptombmonsterlv->magic_def                       = to_uint(aj[i]["magic_def"]);
        ptombmonsterlv->speed                           = to_uint(aj[i]["speed"]);
        ptombmonsterlv->critper                         = to_uint(aj[i]["critper"]);
        ptombmonsterlv->crithurt                        = to_uint(aj[i]["crithurt"]);
        ptombmonsterlv->critper_def                     = to_uint(aj[i]["critper_def"]);
        ptombmonsterlv->crithurt_def                    = to_uint(aj[i]["crithurt_def"]);
        ptombmonsterlv->hitper                          = to_uint(aj[i]["hitper"]);
        ptombmonsterlv->dodgeper                        = to_uint(aj[i]["dodgeper"]);
        ptombmonsterlv->parryper                        = to_uint(aj[i]["parryper"]);
        ptombmonsterlv->parryper_dec                    = to_uint(aj[i]["parryper_dec"]);
        ptombmonsterlv->recover_critper                 = to_uint(aj[i]["recover_critper"]);
        ptombmonsterlv->recover_critper_def             = to_uint(aj[i]["recover_critper_def"]);
        ptombmonsterlv->recover_add_fix                 = to_uint(aj[i]["recover_add_fix"]);
        ptombmonsterlv->recover_del_fix                 = to_uint(aj[i]["recover_del_fix"]);
        ptombmonsterlv->recover_add_per                 = to_uint(aj[i]["recover_add_per"]);
        ptombmonsterlv->recover_del_per                 = to_uint(aj[i]["recover_del_per"]);
        ptombmonsterlv->rage_add_fix                    = to_uint(aj[i]["rage_add_fix"]);
        ptombmonsterlv->rage_del_fix                    = to_uint(aj[i]["rage_del_fix"]);
        ptombmonsterlv->rage_add_per                    = to_uint(aj[i]["rage_add_per"]);
        ptombmonsterlv->rage_del_per                    = to_uint(aj[i]["rage_del_per"]);

        Add(ptombmonsterlv);
        ++count;
        LOG_DEBUG("lv:%u,hp:%u,physical_ack:%u,physical_def:%u,magic_ack:%u,magic_def:%u,speed:%u,critper:%u,crithurt:%u,critper_def:%u,crithurt_def:%u,hitper:%u,dodgeper:%u,parryper:%u,parryper_dec:%u,recover_critper:%u,recover_critper_def:%u,recover_add_fix:%u,recover_del_fix:%u,recover_add_per:%u,recover_del_per:%u,rage_add_fix:%u,rage_del_fix:%u,rage_add_per:%u,rage_del_per:%u,", ptombmonsterlv->lv, ptombmonsterlv->hp, ptombmonsterlv->physical_ack, ptombmonsterlv->physical_def, ptombmonsterlv->magic_ack, ptombmonsterlv->magic_def, ptombmonsterlv->speed, ptombmonsterlv->critper, ptombmonsterlv->crithurt, ptombmonsterlv->critper_def, ptombmonsterlv->crithurt_def, ptombmonsterlv->hitper, ptombmonsterlv->dodgeper, ptombmonsterlv->parryper, ptombmonsterlv->parryper_dec, ptombmonsterlv->recover_critper, ptombmonsterlv->recover_critper_def, ptombmonsterlv->recover_add_fix, ptombmonsterlv->recover_del_fix, ptombmonsterlv->recover_add_per, ptombmonsterlv->recover_del_per, ptombmonsterlv->rage_add_fix, ptombmonsterlv->rage_del_fix, ptombmonsterlv->rage_add_per, ptombmonsterlv->rage_del_per);
    }
    LOG_INFO("TombMonsterLv.xls:%d", count);
}

void CTombMonsterLvData::ClearData(void)
{
    for( UInt32TombMonsterLvMap::iterator iter = id_tombmonsterlv_map.begin();
        iter != id_tombmonsterlv_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_tombmonsterlv_map.clear();
}

CTombMonsterLvData::SData* CTombMonsterLvData::Find( uint32 lv )
{
    UInt32TombMonsterLvMap::iterator iter = id_tombmonsterlv_map.find(lv);
    if ( iter != id_tombmonsterlv_map.end() )
        return iter->second;
    return NULL;
}

void CTombMonsterLvData::Add(SData* ptombmonsterlv)
{
    id_tombmonsterlv_map[ptombmonsterlv->lv] = ptombmonsterlv;
}
