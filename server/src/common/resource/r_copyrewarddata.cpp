#include "jsonconfig.h"
#include "r_copyrewarddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CCopyRewardData::CCopyRewardData()
{
}

CCopyRewardData::~CCopyRewardData()
{
    resource_clear(id_copyreward_map);
}

void CCopyRewardData::LoadData(void)
{
    CJson jc = CJson::Load( "CopyReward" );

    theResDataMgr.insert(this);
    resource_clear(id_copyreward_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pcopyreward                   = new SData;
        pcopyreward->gid                             = to_uint(aj[i]["gid"]);
        S2UInt32 coin;
        for ( uint32 j = 1; j <= 16; ++j )
        {
            std::string buff = strprintf( "coin%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &coin.first, &coin.second ) )
                break;
            pcopyreward->coin.push_back(coin);
        }

        Add(pcopyreward);
        ++count;
        LOG_DEBUG("gid:%u,", pcopyreward->gid);
    }
    LOG_INFO("CopyReward.xls:%d", count);
}

void CCopyRewardData::ClearData(void)
{
    for( UInt32CopyRewardMap::iterator iter = id_copyreward_map.begin();
        iter != id_copyreward_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_copyreward_map.clear();
}

CCopyRewardData::SData* CCopyRewardData::Find( uint32 gid )
{
    UInt32CopyRewardMap::iterator iter = id_copyreward_map.find(gid);
    if ( iter != id_copyreward_map.end() )
        return iter->second;
    return NULL;
}

void CCopyRewardData::Add(SData* pcopyreward)
{
    id_copyreward_map[pcopyreward->gid] = pcopyreward;
}
