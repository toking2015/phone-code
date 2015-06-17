local const = trans.const
local err = trans.err
local base = trans.base

const.kPathVipTimeLimitShop		= 1557217052		-- vip限时商店

err.kErrVipTimeLimitShopBuyLimit		= 552735418		--超出了购买限制
err.kErrVipTimeLimitShopLevelLimit		= 252430009		--vip等级不够

-- vip限时商店-黄少杰
base.reg( 'SUserVipTimeLimitGoods', nil,
    {
        { 'vip_package_id', 'uint32' },		-- 礼包等级
        { 'buyed_count', 'uint32' },		-- 购买数量
        { 'next_buy_time', 'uint32' },		-- 下次可以购买的时间
    }
)

-- @@请求商品列表
base.reg( 'PQVipTimeLimitShopWeek', 'SMsgHead',
    {
    }, 746990542
)

-- @@返回商品列表
base.reg( 'PRVipTimeLimitShopWeek', 'SMsgHead',
    {
        { 'now_week', 'uint32' },		-- 当前周数
        { 'buyed_list', { 'array', 'SUserVipTimeLimitGoods' } },		-- 购买记录
        { 'next_refresh_time', 'uint32' },		-- 下次可以购买的时间
    }, 1223021540
)

-- @@请求购买
base.reg( 'PQVipTimeLimitShopBuy', 'SMsgHead',
    {
        { 'vip_level', 'uint32' },		-- 购买礼包的等级
        { 'count', 'uint32' },		-- 购买数量
    }, 1936613
)

-- @@返回购买记录
base.reg( 'PRVipTimeLimitShopBuy', 'SMsgHead',
    {
        { 'buyed_info', 'SUserVipTimeLimitGoods' },		-- 购买记录单个
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectUpdate, kObjectDel
    }, 1101010730
)


