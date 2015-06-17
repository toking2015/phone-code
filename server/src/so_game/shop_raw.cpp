#include "raw.h"
#include "proto/shop.h"

RAW_USER_LOAD(shop_log)
{
    QuerySql("select vendible_id, daily_count, history_count from shop_log where role_id = %u", guid);
    for (sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        SUserShopLog obj;
        obj.id = sql->getInteger(i++);
        obj.daily_count = sql->getInteger(i++);
        obj.history_count = sql->getInteger(i++);
        data.shop_log.push_back(obj);
    }
    return DB_SUCCEED;
}

RAW_USER_LOAD(mystery_goods_list)
{
    QuerySql("select vendible_id, buyed_count from mystery_shop_goods where role_id = %u", guid);
    for (sql->first(); !sql->empty(); sql->next())
    {
        int32 i = 0;
        SUserMysteryGoods obj;
        obj.id = sql->getInteger(i++);
        obj.buyed_count = sql->getInteger(i++);
        data.mystery_goods_list.push_back(obj);
    }
    return DB_SUCCEED;
}

RAW_USER_SAVE(shop_log)
{
    stream << strprintf("delete from shop_log where role_id = %u;", guid) << std::endl;
    if (data.shop_log.empty())
        return;

    stream << "insert into shop_log (role_id, vendible_id, daily_count, history_count) values";
    for (std::vector<SUserShopLog>::iterator iter = data.shop_log.begin();
        iter != data.shop_log.end();
        ++iter)
    {
        if (iter != data.shop_log.begin())
            stream << ", ";
        stream << "(" << guid << ", " << iter->id << ", " << iter->daily_count << ", " << iter->history_count << ")";
    }
    stream << std::endl;
}

RAW_USER_SAVE(mystery_goods_list)
{
    stream << strprintf("delete from mystery_shop_goods where role_id = %u;", guid) << std::endl;
    if (data.mystery_goods_list.empty())
        return;

    stream << "insert into mystery_shop_goods(role_id, vendible_id, buyed_count) values";
    for (std::vector<SUserMysteryGoods>::iterator iter = data.mystery_goods_list.begin();
        iter != data.mystery_goods_list.end();
        ++iter)
    {
        if (iter != data.mystery_goods_list.begin())
            stream << ", ";
        stream << "(" << guid << ", " << iter->id << ", " << iter->buyed_count << ")";
    }
    stream << std::endl;
}
