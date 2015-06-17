#include "jsonconfig.h"
#include "r_soldierequipmgr.h"
#include "log.h"
#include "proto/constant.h"
#include "util.h"

CSoldierEquipData::CSoldierEquipData()
{
}

CSoldierEquipData::~CSoldierEquipData()
{
    resource_clear(id_soldierequip_list);
}

void CSoldierEquipData::LoadData(void)
{
    CJson jc = CJson::Load( "SoldierEquip" );

    theResDataMgr.insert(this);
    resource_clear(id_soldierequip_list);
    int32 count = 0;
    const Json::Value aj = jc["Array"];
    for ( uint32 i = 0; i != aj.size(); ++i)
    {
        SData *psoldierequip                 = new SData;
        psoldierequip->soldier_id                      = to_uint(aj[i]["soldier_id"]);
        psoldierequip->equip_id                        = to_uint(aj[i]["equip_id"]);
        S2UInt32 effects;
        for ( uint32 j = 1; j <= 3; ++j )
        {
            std::string buff = strprintf( "effects%d", j);
            std::string value_string = aj[i][buff].asString();
            if ( 2 != sscanf( value_string.c_str(), "%u%%%u", &effects.first, &effects.second ) )
                break;
            psoldierequip->effects.push_back(effects);
        }

        Add(psoldierequip);
        ++count;
        LOG_DEBUG("soldier_id:%u,equip_id:%u,", psoldierequip->soldier_id, psoldierequip->equip_id);
    }
    LOG_INFO("SoldierEquip.xls:%d", count);
}

void CSoldierEquipData::ClearData(void)
{
    for( SoldierEquipList::iterator iter = id_soldierequip_list.begin();
        iter != id_soldierequip_list.end();
        ++iter )
    {
        EquipList &equip_list = iter->second;
        for (EquipList::iterator e_iter = equip_list.begin();
            e_iter != equip_list.end();
            ++e_iter)
        {
            delete e_iter->second;
        }
    }
    id_soldierequip_list.clear();
}

CSoldierEquipData::SData* CSoldierEquipData::Find( uint32 soldier_id,uint32 equip_id )
{
    SoldierEquipList::iterator iter = id_soldierequip_list.find(soldier_id);
    if (iter == id_soldierequip_list.end())
        return NULL;
    EquipList &equip_list = iter->second;
    EquipList::iterator find_iter = equip_list.find(equip_id);
    if (find_iter == equip_list.end())
        return NULL;
    return find_iter->second;
}

void CSoldierEquipData::Add(SData* psoldierequip)
{
    id_soldierequip_list[psoldierequip->soldier_id][psoldierequip->equip_id] = psoldierequip;
}
