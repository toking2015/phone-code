#include "jsonconfig.h"
#include "r_trialrewardcountdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTrialRewardCountData::CTrialRewardCountData()
{
}

CTrialRewardCountData::~CTrialRewardCountData()
{
    resource_clear(id_trialrewardcount_map);
}

void CTrialRewardCountData::LoadData(void)
{
    CJson jc = CJson::Load( "TrialRewardCount" );

    theResDataMgr.insert(this);
    resource_clear(id_trialrewardcount_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptrialrewardcount             = new SData;
        ptrialrewardcount->trial_id                        = to_uint(aj[i]["trial_id"]);
        ptrialrewardcount->reward_count                    = to_uint(aj[i]["reward_count"]);
        ptrialrewardcount->trial_val                       = to_uint(aj[i]["trial_val"]);
        std::string reward_cost_string = aj[i]["reward_cost"].asString();
        sscanf( reward_cost_string.c_str(), "%u%%%u%%%u", &ptrialrewardcount->reward_cost.cate, &ptrialrewardcount->reward_cost.objid, &ptrialrewardcount->reward_cost.val );
        ptrialrewardcount->desc                            = to_str(aj[i]["desc"]);

        Add(ptrialrewardcount);
        ++count;
        LOG_DEBUG("trial_id:%u,reward_count:%u,trial_val:%u,desc:%s,", ptrialrewardcount->trial_id, ptrialrewardcount->reward_count, ptrialrewardcount->trial_val, ptrialrewardcount->desc.c_str());
    }
    LOG_INFO("TrialRewardCount.xls:%d", count);
}

void CTrialRewardCountData::ClearData(void)
{
    for( UInt32TrialRewardCountMap::iterator iter = id_trialrewardcount_map.begin();
        iter != id_trialrewardcount_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_trialrewardcount_map.clear();
}

CTrialRewardCountData::SData* CTrialRewardCountData::Find( uint32 trial_id,uint32 reward_count )
{
    return id_trialrewardcount_map[trial_id][reward_count];
}

void CTrialRewardCountData::Add(SData* ptrialrewardcount)
{
    id_trialrewardcount_map[ptrialrewardcount->trial_id][ptrialrewardcount->reward_count] = ptrialrewardcount;
}
