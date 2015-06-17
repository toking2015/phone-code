#include "jsonconfig.h"
#include "r_fixedequipdata.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CFixedEquipData::CFixedEquipData()
{
}

CFixedEquipData::~CFixedEquipData()
{
    resource_clear(id_fixedequip_map);
}

void CFixedEquipData::LoadData(void)
{
    CJson jc = CJson::Load( "FixedEquip" );

    theResDataMgr.insert(this);
    resource_clear(id_fixedequip_map);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *pfixedequip                   = new SData;
        pfixedequip->id                              = to_uint(aj[i]["id"]);
        pfixedequip->quality                         = to_uint(aj[i]["quality"]);
        pfixedequip->main_factor                     = to_uint(aj[i]["main_factor"]);
        pfixedequip->slave_factor                    = to_uint(aj[i]["slave_factor"]);

        Add(pfixedequip);
        ++count;
        LOG_DEBUG("id:%u,quality:%u,main_factor:%u,slave_factor:%u,", pfixedequip->id, pfixedequip->quality, pfixedequip->main_factor, pfixedequip->slave_factor);
    }
    LOG_INFO("FixedEquip.xls:%d", count);
}

void CFixedEquipData::ClearData(void)
{
    for( UInt32FixedEquipMap::iterator iter = id_fixedequip_map.begin();
        iter != id_fixedequip_map.end();
        ++iter )
    {
        for(std::map<uint32,SData*>::iterator jter = iter->second.begin();
            jter != iter->second.end();
            ++jter )
        {
            delete jter->second;
        }
    }
    id_fixedequip_map.clear();
}

CFixedEquipData::SData* CFixedEquipData::Find( uint32 id,uint32 quality )
{
    return id_fixedequip_map[id][quality];
}

void CFixedEquipData::Add(SData* pfixedequip)
{
    id_fixedequip_map[pfixedequip->id][pfixedequip->quality] = pfixedequip;
}
