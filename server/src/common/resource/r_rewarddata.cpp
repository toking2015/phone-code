#include "jsonconfig.h"
#include "r_rewarddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CRewardData::CRewardData()
{
}

CRewardData::~CRewardData()
{
    resource_clear(id_reward_map);
}

void CRewardData::LoadData(void)
{
    CJson jc = CJson::Load( "Reward" );

    theResDataMgr.insert(this);
    resource_clear(id_reward_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *preward                       = new SData;
        preward->id                              = to_uint(aj[i]["id"]);
        S3UInt32 coins;
        for ( uint32 j = 1; j <= 16; ++j )
        {
            std::string buff = strprintf( "coins%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &coins.cate, &coins.objid, &coins.val ) )
                break;
            preward->coins.push_back(coins);
        }

        Add(preward);
        ++count;
        LOG_DEBUG("id:%u,", preward->id);
    }
    LOG_INFO("Reward.xls:%d", count);
}

void CRewardData::ClearData(void)
{
    for( UInt32RewardMap::iterator iter = id_reward_map.begin();
        iter != id_reward_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_reward_map.clear();
}

CRewardData::SData* CRewardData::Find( uint32 id )
{
    UInt32RewardMap::iterator iter = id_reward_map.find(id);
    if ( iter != id_reward_map.end() )
        return iter->second;
    return NULL;
}

void CRewardData::Add(SData* preward)
{
    id_reward_map[preward->id] = preward;
}
