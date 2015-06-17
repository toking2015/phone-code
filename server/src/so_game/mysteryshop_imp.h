#ifndef _GAMESVR_MYSTERY_SHOP_IMP_H_
#define _GAMESVR_MYSTERY_SHOP_IMP_H_

#include "common.h"
#include "resource/r_vendibleext.h"
#include "proto/common.h"
#include "proto/user.h"
#include "dynamicmgr.h"

namespace mystery_shop
{
    typedef std::vector<SUserMysteryGoods> MysteryGoodsList;
    // 购买
    bool Buy(SUser *p_user, CVendibleData::SData *p_data, uint32 count);
    // 设置下次刷新时间戳
    void SetNextTime(SUser *p_user);
    // 刷新商品列表
    void RefreshGoodsList(SUser *p_user);
    // 返回商品列表
    void ReplyGoodsList(SUser *p_user);

} // namespace mystery_shop

#endif
