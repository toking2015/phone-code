#include "jsonconfig.h"
#include "r_tombrewarddata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CTombRewardData::CTombRewardData()
{
}

CTombRewardData::~CTombRewardData()
{
    resource_clear(id_tombreward_map);
}

void CTombRewardData::LoadData(void)
{
    CJson jc = CJson::Load( "TombReward" );

    theResDataMgr.insert(this);
    resource_clear(id_tombreward_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *ptombreward                   = new SData;
        ptombreward->id                              = to_uint(aj[i]["id"]);
        ptombreward->quality                         = to_uint(aj[i]["quality"]);
        ptombreward->reward                          = to_uint(aj[i]["reward"]);
        std::string level_rand_string = aj[i]["level_rand"].asString();
        sscanf( level_rand_string.c_str(), "%u%%%u", &ptombreward->level_rand.first, &ptombreward->level_rand.second );
        ptombreward->percent                         = to_uint(aj[i]["percent"]);
        ptombreward->extra_reward                    = to_uint(aj[i]["extra_reward"]);
        ptombreward->extra_percent                   = to_uint(aj[i]["extra_percent"]);
        ptombreward->desc                            = to_str(aj[i]["desc"]);

        Add(ptombreward);
        ++count;
        LOG_DEBUG("id:%u,quality:%u,reward:%u,percent:%u,extra_reward:%u,extra_percent:%u,desc:%s,", ptombreward->id, ptombreward->quality, ptombreward->reward, ptombreward->percent, ptombreward->extra_reward, ptombreward->extra_percent, ptombreward->desc.c_str());
    }
    LOG_INFO("TombReward.xls:%d", count);
}

void CTombRewardData::ClearData(void)
{
    for( UInt32TombRewardMap::iterator iter = id_tombreward_map.begin();
        iter != id_tombreward_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_tombreward_map.clear();
}

CTombRewardData::SData* CTombRewardData::Find( uint32 id )
{
    UInt32TombRewardMap::iterator iter = id_tombreward_map.find(id);
    if ( iter != id_tombreward_map.end() )
        return iter->second;
    return NULL;
}

void CTombRewardData::Add(SData* ptombreward)
{
    id_tombreward_map[ptombreward->id] = ptombreward;
}
