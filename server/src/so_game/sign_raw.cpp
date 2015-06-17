#include "raw.h"

#include "proto/sign.h"
#include "proto/constant.h"

RAW_USER_LOAD(sign_info)
{
    QuerySql("select day_id, sign_type, sign_time from sign_day where role_id = %u", guid);
    for(sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        SSign sign;
        sign.day_id    = sql->getInteger(i++);
        sign.sign_type = sql->getInteger(i++);
        sign.sign_time = sql->getInteger(i++);

        data.sign_info.sign_list.push_back(sign);
    }

    QuerySql("select reward_id from sign_sum where role_id = %u", guid);
    for(sql->first(); !sql->empty(); sql->next())
    {
        uint32 reward_id = sql->getInteger(0);

        data.sign_info.sum_list.push_back(reward_id);
    }

    return DB_SUCCEED;
}

RAW_USER_SAVE(sign_info)
{
    stream << strprintf("delete from sign_day where role_id = %u;", guid ) << std::endl;
    stream << strprintf("delete from sign_sum where role_id = %u;", guid ) << std::endl;

    for(uint32 i = 0; i < data.sign_info.sign_list.size(); ++i)
    {
        SSign &sign = data.sign_info.sign_list[i];

        stream << strprintf("insert into sign_day(role_id, day_id, sign_type, sign_time) values (%u, %u, %u, %u);",
            guid, sign.day_id, sign.sign_type, sign.sign_time) << std::endl;
    }

    for(uint32 i = 0; i < data.sign_info.sum_list.size(); ++i)
    {
        stream << strprintf("insert into sign_sum(role_id, reward_id) values (%u, %u);", guid, data.sign_info.sum_list[i]) << std::endl;
    }
}
