#include "jsonconfig.h"
#include "r_templescorerewarddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTempleScoreRewardData::CTempleScoreRewardData()
{
}

CTempleScoreRewardData::~CTempleScoreRewardData()
{
    resource_clear(id_templescorereward_map);
}

void CTempleScoreRewardData::LoadData(void)
{
    CJson jc = CJson::Load( "TempleScoreReward" );

    theResDataMgr.insert(this);
    resource_clear(id_templescorereward_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptemplescorereward            = new SData;
        ptemplescorereward->id                              = to_uint(aj[i]["id"]);
        ptemplescorereward->score                           = to_uint(aj[i]["score"]);
        S3UInt32 reward;
        for ( uint32 j = 1; j <= 6; ++j )
        {
            std::string buff = strprintf( "reward%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &reward.cate, &reward.objid, &reward.val ) )
                break;
            ptemplescorereward->reward.push_back(reward);
        }

        Add(ptemplescorereward);
        ++count;
        LOG_DEBUG("id:%u,score:%u,", ptemplescorereward->id, ptemplescorereward->score);
    }
    LOG_INFO("TempleScoreReward.xls:%d", count);
}

void CTempleScoreRewardData::ClearData(void)
{
    for( UInt32TempleScoreRewardMap::iterator iter = id_templescorereward_map.begin();
        iter != id_templescorereward_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_templescorereward_map.clear();
}

CTempleScoreRewardData::SData* CTempleScoreRewardData::Find( uint32 id )
{
    UInt32TempleScoreRewardMap::iterator iter = id_templescorereward_map.find(id);
    if ( iter != id_templescorereward_map.end() )
        return iter->second;
    return NULL;
}

void CTempleScoreRewardData::Add(SData* ptemplescorereward)
{
    id_templescorereward_map[ptemplescorereward->id] = ptemplescorereward;
}
