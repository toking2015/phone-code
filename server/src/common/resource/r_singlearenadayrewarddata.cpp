#include "jsonconfig.h"
#include "r_singlearenadayrewarddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSingleArenaDayRewardData::CSingleArenaDayRewardData()
{
}

CSingleArenaDayRewardData::~CSingleArenaDayRewardData()
{
    resource_clear(id_singlearenadayreward_map);
}

void CSingleArenaDayRewardData::LoadData(void)
{
    CJson jc = CJson::Load( "SingleArenaDayReward" );

    theResDataMgr.insert(this);
    resource_clear(id_singlearenadayreward_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psinglearenadayreward         = new SData;
        psinglearenadayreward->id                              = to_uint(aj[i]["id"]);
        std::string rank_string = aj[i]["rank"].asString();
        sscanf( rank_string.c_str(), "%u%%%u", &psinglearenadayreward->rank.first, &psinglearenadayreward->rank.second );
        S3UInt32 reward_;
        for ( uint32 j = 1; j <= 5; ++j )
        {
            std::string buff = strprintf( "reward_%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &reward_.cate, &reward_.objid, &reward_.val ) )
                break;
            psinglearenadayreward->reward_.push_back(reward_);
        }

        Add(psinglearenadayreward);
        ++count;
        LOG_DEBUG("id:%u,", psinglearenadayreward->id);
    }
    LOG_INFO("SingleArenaDayReward.xls:%d", count);
}

void CSingleArenaDayRewardData::ClearData(void)
{
    for( UInt32SingleArenaDayRewardMap::iterator iter = id_singlearenadayreward_map.begin();
        iter != id_singlearenadayreward_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_singlearenadayreward_map.clear();
}

CSingleArenaDayRewardData::SData* CSingleArenaDayRewardData::Find( uint32 id )
{
    UInt32SingleArenaDayRewardMap::iterator iter = id_singlearenadayreward_map.find(id);
    if ( iter != id_singlearenadayreward_map.end() )
        return iter->second;
    return NULL;
}

void CSingleArenaDayRewardData::Add(SData* psinglearenadayreward)
{
    id_singlearenadayreward_map[psinglearenadayreward->id] = psinglearenadayreward;
}
