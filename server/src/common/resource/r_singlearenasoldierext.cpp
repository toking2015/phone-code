#include "jsonconfig.h"
#include "log.h"
#include "proto/constant.h"
#include "r_singlearenasoldierext.h"

CSingleArenaSoldierExt::~CSingleArenaSoldierExt()
{
    ClearData();
}

void CSingleArenaSoldierExt::LoadData()
{
   //清空数据
    ClearData();

    //父类加载数据
    CSingleArenaSoldierData::LoadData();

    //分析匹配key
    for( CSingleArenaSoldierData::UInt32SingleArenaSoldierMap::iterator iter = id_singlearenasoldier_map.begin();
        iter != id_singlearenasoldier_map.end();
        ++iter )
    {
        if( 0 == iter->second->rank )
            continue;
        rank_map[iter->second->rank].push_back(iter->second);
    }

    //打印信息
    for( std::map<uint32, std::vector<SData*> >::iterator iter = rank_map.begin();
        iter != rank_map.end();
        ++iter )
    {
        LOG_DEBUG("rank:%d,count:%d", iter->first, (uint32)iter->second.size());
    }
}

void CSingleArenaSoldierExt::ClearData()
{
    rank_map.clear();
}

std::vector<uint32> CSingleArenaSoldierExt::GetSoldier( uint32 rank )
{
    std::map<uint32, std::vector<SData*> >::iterator target_iter = rank_map.begin();
    for( std::map<uint32, std::vector<SData*> >::iterator iter = rank_map.begin();
        iter != rank_map.end();
        ++iter )
    {
        if( rank < iter->first )
            break;

        target_iter = iter;
    }

    std::vector<SData*> list = target_iter->second;
    std::vector<uint32> target_list;

    if ( list.empty() )
        return target_list;

    random_shuffle(list.begin(), list.end());

    for( std::vector<SData*>::iterator iter = list.begin();
        iter != list.end();
        ++iter )
    {
        target_list.push_back((*iter)->id);
    }
    return target_list;
}
