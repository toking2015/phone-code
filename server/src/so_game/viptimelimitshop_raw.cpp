#include "raw.h"
#include "proto/viptimelimitshop.h"

RAW_USER_LOAD(viptimelimit_goods_list)
{
    QuerySql("select vip_package_id, buyed_count, next_buy_time from viptimelimit_shop_goods where role_id = %u", guid);
    for (sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        SUserVipTimeLimitGoods obj;
        obj.vip_package_id          = sql->getInteger(i++);
        obj.buyed_count         = sql->getInteger(i++);
        obj.next_buy_time       = sql->getInteger(i++);
        data.viptimelimit_goods_list.push_back(obj);
    }
    return DB_SUCCEED;
}

RAW_USER_SAVE(viptimelimit_goods_list)
{
    stream << strprintf("delete from viptimelimit_shop_goods where role_id = %u;", guid) << std::endl;
    if (data.viptimelimit_goods_list.empty())
        return;

    stream << "insert into viptimelimit_shop_goods(role_id, vip_package_id, buyed_count, next_buy_time) values";
    for (std::vector<SUserVipTimeLimitGoods>::iterator iter = data.viptimelimit_goods_list.begin();
        iter != data.viptimelimit_goods_list.end();
        ++iter)
    {
        if (iter != data.viptimelimit_goods_list.begin())
            stream << ", ";
        stream << "(" << guid << ", " << iter->vip_package_id << ", " << iter->buyed_count << "," << iter->next_buy_time << ")";
    }
    stream << std::endl;
}
