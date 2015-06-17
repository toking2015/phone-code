#include "raw.h"
#include "proto/totem.h"
#include "proto/constant.h"

RAW_USER_LOAD(totem_map)
{
    QuerySql("select packet,guid,id,level,speed_lv,formation_add_lv,skill_cd_lv,energy_time,accelerate_count from totem where role_id = %u", guid);
    for(sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        uint32 packet = sql->getInteger(i++);

        STotem totem;
        totem.guid             = sql->getInteger(i++);
        totem.id               = sql->getInteger(i++);
        totem.level            = sql->getInteger(i++);
        totem.speed_lv         = sql->getInteger(i++);
        totem.formation_add_lv = sql->getInteger(i++);
        totem.wake_lv          = sql->getInteger(i++);
        totem.energy_time      = sql->getInteger(i++);
        totem.accelerate_count = sql->getInteger(i++);

        data.totem_map[packet].totem_list.push_back(totem);
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE(totem_map)
{
    stream << strprintf("delete from totem where role_id = %u;", guid) << std::endl;

    for(std::map<uint32, STotemInfo>::iterator iter = data.totem_map.begin(); iter != data.totem_map.end(); ++iter)
    {
        STotemInfo &info = iter->second;
        for(uint32 i = 0; i < info.totem_list.size(); ++i)
        {
            STotem &totem = info.totem_list[i];
            stream << strprintf("insert into totem(role_id, packet, guid, id, level, speed_lv, formation_add_lv, skill_cd_lv, energy_time, accelerate_count) values (%u,%u,%u,%u,%u,%u,%u,%u,%u,%u);", guid, iter->first, totem.guid, totem.id, totem.level, totem.speed_lv, totem.formation_add_lv, totem.wake_lv, totem.energy_time, totem.accelerate_count) << std::endl;
        }
    }
}
