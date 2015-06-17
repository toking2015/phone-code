#include "local.h"
#include "misc.h"
#include "shop_imp.h"
#include "user_imp.h"
#include "mysteryshop_imp.h"
#include "mysteryshop_event.h"
#include "server.h"
#include "resource/r_globalext.h"
#include "resource/r_mysteryshopext.h"
#include "proto/shop.h"
#include "proto/constant.h"

namespace mystery_shop
{

struct EqualMysteryGoods
{
    uint32 id;
    EqualMysteryGoods(uint32 _id) : id(_id) {}
    bool operator()(const SUserMysteryGoods &goods)
    {
        return goods.id == id;
    }
};

bool Buy(SUser *p_user, CVendibleData::SData *p_data, uint32 count)
{
    if (count != 1)
        return false;
    uint32 id = p_data->id;
    MysteryGoodsList::iterator iter = std::find_if(p_user->data.mystery_goods_list.begin(),
                                                   p_user->data.mystery_goods_list.end(), EqualMysteryGoods(id));
    if (iter == p_user->data.mystery_goods_list.end() || iter->buyed_count > 0)
        return false;
    if (!shop::Buy(p_user, p_data, count, kPathClearMasteryCD))
        return false;
    iter->buyed_count = 1;
    ReplyGoodsList(p_user);
    return true;
}

static uint32 FindNextTime()
{
    static int hours[] = { 12, 18, 21 };
    uint32 time_now = time(NULL);
    uint32 zero = zero_time(time_now);
    uint32 i = 0;
    uint32 next_time = 0;
    for (; i < sizeof(hours)/sizeof(int); i++)
    {
        next_time = zero + hours[i] * 3600;
        if (time_now < next_time)
            break;
    }

    if (i == sizeof(hours)/sizeof(int))
        next_time = zero + 86400 + hours[0] * 3600;
    return next_time;
}

void SetNextTime(SUser *p_user)
{
    p_user->data.other.mystery_refresh_time = FindNextTime();
    user::ReplyUserOther(p_user);
}

void RefreshGoodsList(SUser *p_user)
{
    p_user->data.mystery_goods_list.clear();
    std::vector<uint16> goods_list = theMysteryShopExt.GetGoodsList(p_user->data.simple.team_level, 9);
    for (std::vector<uint16>::iterator iter = goods_list.begin();
        iter != goods_list.end();
        ++iter)
    {
        SUserMysteryGoods obj;
        obj.id = *iter;
        p_user->data.mystery_goods_list.push_back(obj);
    }
    ReplyGoodsList(p_user);
    SetNextTime(p_user);
}

void ReplyGoodsList(SUser *p_user)
{
    PRShopMysteryGoods rep;
    rep.goods_list = p_user->data.mystery_goods_list;
    bccopy(rep, p_user->ext);
    local::write( local::access, rep );
}

} // namespace mystery_shop
