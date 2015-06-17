#include "jsonconfig.h"
#include "r_trialrewarddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTrialRewardData::CTrialRewardData()
{
}

CTrialRewardData::~CTrialRewardData()
{
    resource_clear(id_trialreward_map);
}

void CTrialRewardData::LoadData(void)
{
    CJson jc = CJson::Load( "TrialReward" );

    theResDataMgr.insert(this);
    resource_clear(id_trialreward_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptrialreward                  = new SData;
        ptrialreward->id                              = to_uint(aj[i]["id"]);
        ptrialreward->trial_id                        = to_uint(aj[i]["trial_id"]);
        ptrialreward->reward                          = to_uint(aj[i]["reward"]);
        std::string level_rand_string = aj[i]["level_rand"].asString();
        sscanf( level_rand_string.c_str(), "%u%%%u", &ptrialreward->level_rand.first, &ptrialreward->level_rand.second );
        ptrialreward->percent                         = to_uint(aj[i]["percent"]);
        ptrialreward->desc                            = to_str(aj[i]["desc"]);

        Add(ptrialreward);
        ++count;
        LOG_DEBUG("id:%u,trial_id:%u,reward:%u,percent:%u,desc:%s,", ptrialreward->id, ptrialreward->trial_id, ptrialreward->reward, ptrialreward->percent, ptrialreward->desc.c_str());
    }
    LOG_INFO("TrialReward.xls:%d", count);
}

void CTrialRewardData::ClearData(void)
{
    for( UInt32TrialRewardMap::iterator iter = id_trialreward_map.begin();
        iter != id_trialreward_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_trialreward_map.clear();
}

CTrialRewardData::SData* CTrialRewardData::Find( uint32 id )
{
    UInt32TrialRewardMap::iterator iter = id_trialreward_map.find(id);
    if ( iter != id_trialreward_map.end() )
        return iter->second;
    return NULL;
}

void CTrialRewardData::Add(SData* ptrialreward)
{
    id_trialreward_map[ptrialreward->id] = ptrialreward;
}
