#include "raw.h"
#include "proto/altar.h"
#include "proto/constant.h"

RAW_USER_LOAD(altar_info)
{
    QuerySql("select reset_time, free_count, free_time, gold_free_time, money_seed_1, money_seed_10, gold_seed_1, gold_seed_10 from altar where role_id = %u", guid);

    for(sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        data.altar_info.reset_time     = sql->getInteger(i++);
        data.altar_info.free_count     = sql->getInteger(i++);
        data.altar_info.free_time      = sql->getInteger(i++);
        data.altar_info.gold_free_time = sql->getInteger(i++);
        data.altar_info.money_seed_1   = sql->getInteger(i++);
        data.altar_info.money_seed_10  = sql->getInteger(i++);
        data.altar_info.gold_seed_1    = sql->getInteger(i++);
        data.altar_info.gold_seed_10   = sql->getInteger(i++);
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE(altar_info)
{
    stream << strprintf("delete from altar where role_id = %u;", guid ) << std::endl;

    stream << strprintf("insert into altar(role_id, reset_time, free_count, free_time, gold_free_time, money_seed_1, money_seed_10, gold_seed_1, gold_seed_10) values (%u, %u, %u, %u, %u, %u, %u, %u, %u);",
        guid, data.altar_info.reset_time, data.altar_info.free_count, data.altar_info.free_time, data.altar_info.gold_free_time, data.altar_info.money_seed_1, data.altar_info.money_seed_10, data.altar_info.gold_seed_1, data.altar_info.gold_seed_10) << std::endl;
}
