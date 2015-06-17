#include "jsonconfig.h"
#include "r_equipsuitmgr.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CEquipSuitData::CEquipSuitData()
{
}

CEquipSuitData::~CEquipSuitData()
{
    resource_clear(id_equipsuit_map);
}

void CEquipSuitData::LoadData(void)
{
    CJson jc = CJson::Load( "EquipSuit" );

    theResDataMgr.insert(this);
    resource_clear(id_equipsuit_map);
    suit_levels.clear();
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pequipsuit                    = new SData;
        pequipsuit->level                           = to_uint(aj[i]["level"]);
        pequipsuit->quality                         = to_uint(aj[i]["quality"]);
        pequipsuit->equip_type                      = to_uint(aj[i]["equip_type"]);
        pequipsuit->limit_level                     = to_uint(aj[i]["limit_level"]);
        S2UInt32 odds;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "odds%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &odds.first, &odds.second ) )
                break;
            pequipsuit->odds.push_back(odds);
        }

        Add(pequipsuit);
        ++count;
        LOG_DEBUG("level:%u,quality:%u,equip_type:%u,limit_level:%u,", pequipsuit->level, pequipsuit->quality, pequipsuit->equip_type, pequipsuit->limit_level);
    }
    LOG_INFO("EquipSuit.xls:%d", count);
}

void CEquipSuitData::ClearData(void)
{
    for (UInt32EquipSuitMap::iterator iter = id_equipsuit_map.begin();
        iter != id_equipsuit_map.end();
        ++iter)
    {
        UInt32EquipSuitVec &id_equipsuit_list = iter->second;
        for( UInt32EquipSuitVec::iterator v_iter = id_equipsuit_list.begin();
            v_iter != id_equipsuit_list.end();
            ++v_iter )
        {
            delete *v_iter;
        }
    }
    id_equipsuit_map.clear();
    suit_levels.clear();
}

void CEquipSuitData::Add(SData* pequipsuit)
{
    id_equipsuit_map[pequipsuit->equip_type].push_back(pequipsuit);
    suit_levels.insert(pequipsuit->limit_level);
}

CEquipSuitData::UInt32EquipSuitVec CEquipSuitData::FindSuits(uint32 equip_type, uint32 soldier_level, uint32 suit_level)
{
    UInt32EquipSuitVec ret;
    UInt32EquipSuitMap::iterator find_iter = id_equipsuit_map.find(equip_type);
    if (find_iter == id_equipsuit_map.end())
        return ret;
    UInt32EquipSuitVec &suit_list = find_iter->second;
    for (UInt32EquipSuitVec::iterator iter = suit_list.begin();
        iter != suit_list.end();
        ++iter)
    {
        if ((*iter)->limit_level <= soldier_level && (*iter)->level <= suit_level)
            ret.push_back(*iter);
    }
    return ret;
}

CEquipSuitData::SData * CEquipSuitData::Find(uint32 equip_type, uint32 level, uint32 quality)
{
    UInt32EquipSuitMap::iterator find_iter = id_equipsuit_map.find(equip_type);
    if (find_iter == id_equipsuit_map.end())
        return NULL;
    UInt32EquipSuitVec &suit_list = find_iter->second;
    for (UInt32EquipSuitVec::iterator iter = suit_list.begin();
        iter != suit_list.end();
        ++iter)
    {
        if ((*iter)->level == level && (*iter)->quality == quality)
            return *iter;
    }
    return NULL;
}

std::vector<uint32> CEquipSuitData::GetSuitLevels()
{
    std::vector<uint32> ret;
    for (std::set<uint32>::iterator iter = suit_levels.begin();
        iter != suit_levels.end();
        ++iter)
        ret.push_back(*iter);
    return ret;
}
