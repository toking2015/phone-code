#include "jsonconfig.h"
#include "log.h"
#include "util.h"
#include "proto/constant.h"
#include "r_mysteryshopext.h"

uint32 goods_get_value(S2UInt32 &data)
{
    return data.second;
}

struct EqualMysteryId
{
    uint32 id;
    EqualMysteryId(uint32 _id) : id(_id) {}
    bool operator()(S2UInt32 &obj)
    {
        return obj.first == id;
    }
};
std::vector<uint16> CMysteryShopExt::GetGoodsList(uint32 level, uint32 count)
{
    std::vector<uint16> ret;
    std::vector<S2UInt32> goods_list;
    for (UInt32MysteryShopMap::iterator iter = id_mysteryshop_map.begin();
        iter != id_mysteryshop_map.end();
        ++iter)
    {
        SData *p_data = iter->second;
        if (p_data->min_level <= level && level <= p_data->max_level)
        {
            S2UInt32 obj;
            obj.first = p_data->id;
            obj.second = p_data->rate;
            goods_list.push_back(obj);
        }
    }

    if (goods_list.size() < count)
    {
        LOG_ERROR("CMysteryShopExt::GetGoodsList %u level only got %zu goods", level, goods_list.size());
        return ret;
    }

    while (count > 0)
    {
        S2UInt32 obj = round_rand(goods_list, goods_get_value);
        goods_list.erase(std::remove_if(goods_list.begin(), goods_list.end(), EqualMysteryId(obj.first)), goods_list.end());

        uint16 id = obj.first;
        ret.push_back(id);
        count--;
    }
    return ret;
}
