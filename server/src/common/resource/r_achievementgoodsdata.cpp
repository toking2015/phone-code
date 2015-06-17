#include "jsonconfig.h"
#include "r_achievementgoodsdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CAchievementGoodsData::CAchievementGoodsData()
{
}

CAchievementGoodsData::~CAchievementGoodsData()
{
    resource_clear(id_achievementgoods_map);
}

void CAchievementGoodsData::LoadData(void)
{
    CJson jc = CJson::Load( "AchievementGoods" );

    theResDataMgr.insert(this);
    resource_clear(id_achievementgoods_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pachievementgoods             = new SData;
        pachievementgoods->id                              = to_uint(aj[i]["id"]);
        std::string cond_string = aj[i]["cond"].asString();
        sscanf( cond_string.c_str(), "%u%%%u", &pachievementgoods->cond.first, &pachievementgoods->cond.second );

        Add(pachievementgoods);
        ++count;
        LOG_DEBUG("id:%u,", pachievementgoods->id);
    }
    LOG_INFO("AchievementGoods.xls:%d", count);
}

void CAchievementGoodsData::ClearData(void)
{
    for( UInt32AchievementGoodsMap::iterator iter = id_achievementgoods_map.begin();
        iter != id_achievementgoods_map.end();
        ++iter )
    {
        delete iter->second;
    }
    id_achievementgoods_map.clear();
}

CAchievementGoodsData::SData* CAchievementGoodsData::Find( uint32 id )
{
    UInt32AchievementGoodsMap::iterator iter = id_achievementgoods_map.find(id);
    if ( iter != id_achievementgoods_map.end() )
        return iter->second;
    return NULL;
}

void CAchievementGoodsData::Add(SData* pachievementgoods)
{
    id_achievementgoods_map[pachievementgoods->id] = pachievementgoods;
}
