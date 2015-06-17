#include "jsonconfig.h"
#include "r_daytaskvalrewarddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CDayTaskValRewardData::CDayTaskValRewardData()
{
}

CDayTaskValRewardData::~CDayTaskValRewardData()
{
    resource_clear(id_daytaskvalreward_map);
}

void CDayTaskValRewardData::LoadData(void)
{
    CJson jc = CJson::Load( "DayTaskValReward" );

    theResDataMgr.insert(this);
    resource_clear(id_daytaskvalreward_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pdaytaskvalreward             = new SData;
        pdaytaskvalreward->id                              = to_uint(aj[i]["id"]);
        pdaytaskvalreward->need_val                        = to_uint(aj[i]["need_val"]);
        S3UInt32 reward;
        for ( uint32 j = 1; j <= 4; ++j )
        {
            std::string buff = strprintf( "reward%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 3 != sscanf( value_string.c_str(), "%u%%%u%%%u", &reward.cate, &reward.objid, &reward.val ) )
                break;
            pdaytaskvalreward->reward.push_back(reward);
        }

        Add(pdaytaskvalreward);
        ++count;
        LOG_DEBUG("id:%u,need_val:%u,", pdaytaskvalreward->id, pdaytaskvalreward->need_val);
    }
    LOG_INFO("DayTaskValReward.xls:%d", count);
}

void CDayTaskValRewardData::ClearData(void)
{
    for( UInt32DayTaskValRewardMap::iterator iter = id_daytaskvalreward_map.begin();
        iter != id_daytaskvalreward_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_daytaskvalreward_map.clear();
}

CDayTaskValRewardData::SData* CDayTaskValRewardData::Find( uint32 id )
{
    UInt32DayTaskValRewardMap::iterator iter = id_daytaskvalreward_map.find(id);
    if ( iter != id_daytaskvalreward_map.end() )
        return iter->second;
    return NULL;
}

void CDayTaskValRewardData::Add(SData* pdaytaskvalreward)
{
    id_daytaskvalreward_map[pdaytaskvalreward->id] = pdaytaskvalreward;
}
