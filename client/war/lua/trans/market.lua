local const = trans.const
local err = trans.err
local base = trans.base

const.kPathMarketReturn		= 254524643		-- 超时返还
const.kPathMarketCargoUp		= 2044516102		-- 货物上架
const.kPathMarketCargoDown		= 357133648		-- 货物下架
const.kPathMarketBuy		= 366073746		-- 货物购买
const.kPathMarketSell		= 930146548		-- 货物售出
const.kPathMarketRef		= 1892309926		-- 刷新货架内容
const.kPathMarketChange		= 805155233		-- 货物修改
const.kPathMarketAutoBuy		= 884419040		-- 自动购买
const.kMarketCargoTypePaper		= 1
const.kMarketCargoTypeMaterial		= 2

err.kErrMarketNotService		= 1836364015		--拍卖行服务未开启
err.kErrMarketCargoNoExist		= 825506719		--货物不存在
err.kErrMarketCargoNoExchange		= 391560087		--货物不可交易
err.kErrMarketPercentRound		= 1296708022		--货物上架价格指数范围错误
err.kErrMarketCargoCate		= 1825800181		--货物类型错误
err.kErrMarketCargoNotEnough		= 2089953920		--货物售卖数量不足
err.kErrMarketCargoPurview		= 1323018039		--操作权限不足
err.kErrMarketCargoChange		= 1360020592		--数据变更
err.kErrMarketParam		= 2034222067		--参数不合法
err.kErrMarketNotPaperSkill		= 1306858982		--还没选择手工技能
err.kErrMarketRefNotToTime		= 545248623		--免费刷新时间未到

-- [卖方商品信息]
base.reg( 'SMarketSellCargo', nil,
    {
        { 'sid', 'uint32' },		--  0 为跨服拍卖数据, 非0为指定服数据
        { 'cargo_id', 'uint32' },		-- 商品唯一ID
        { 'role_id', 'uint32' },		-- 上架货物主人
        { 'coin', 'S3UInt32' },		-- 上架货物剩余量
        { 'percent', 'uint8' },		-- 上架货物价值比值[ 80 - 180 ], 默认值 100
        { 'start_time', 'uint32' },		-- 上架时间
        { 'down_time', 'uint32' },		-- 下架时间
        { 'buy_name', 'string' },		-- 购买人
        { 'buy_count', 'uint32' },		-- 购买数量
        { 'money', 'uint32' },		-- 已经卖出的价格
    }
)

-- 批量匹配信息
base.reg( 'SMarketMatch', nil,
    {
        { 'cargo_id', 'uint32' },		-- 商品唯一ID
        { 'coin', 'S3UInt32' },		-- 需要购买量
        { 'percent', 'uint8' },		-- 上架货物价值比值[ 80 - 180 ], 默认值 100
    }
)

-- 购买记录
base.reg( 'SMarketLog', nil,
    {
        { 'name', 'string' },		-- 购买方角色名
        { 'coin', 'S3UInt32' },		-- 购买物品
        { 'time', 'uint32' },		-- 购买时间
        { 'price', 'uint32' },		-- 购买总价, 卖方收益为 price * 0.9, 税收为 price * 0.1
    }
)

-- ============================数据中心========================
base.reg( 'SMarketIndices', nil,
    {
        { 'paper_list', { 'array', 'uint32' } },		-- 图纸分类索引, < cargo_id >
        { 'material_list', { 'array', 'uint32' } },		-- 材料分类索引, < cargo_id >
    }
)

base.reg( 'CMarket', nil,
    {
        { 'social_time', 'uint32' },		-- 跨服拍卖开始时间, gamesvr 使用
        { 'global_id', 'uint32' },		-- 全局id, 0为未初始化
        { 'data_map', { 'indices', 'SMarketSellCargo' } },		-- 货品信息, < cargo_id, < data > >
        { 'indices_map', { 'indices', 'indices', 'SMarketIndices' } },		-- 数据索引, < sid, < type_level, SMarketIndices > >
        { 'user_map', { 'indices', 'array', 'uint32' } },		-- 用户售卖索引, < role_id, < cargo_id > >
        { 'down_map', { 'indices', 'indices', 'array', 'uint32' } },		-- 下架索引 <timestamp, serverid, < cargo_id> >
        { 'sell_map', { 'indices', 'array', 'uint32' } },		-- < serverid, < cargo_id > >;
    }
)

-- @@请求买方列表
base.reg( 'PQMarketBuyList', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器标识(仅服务器处理)
        { 'level', 'uint32' },		-- 玩家等级(服务器处理)
    }, 680228560
)

-- @@自定义请求拍卖行购买数据, 返回 PRMarketBuyList
base.reg( 'PQMarketCustomBuyList', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器标识(仅服务器处理)
        { 'equip', 'uint8' },		-- YY甲类型 kEquipYYY
        { 'level', 'uint16' },		-- T1, T2 ... Tx 对应的等级( 20, 35, 50, 65, 80, 95, 110, 125, 140, 155 )
    }, 11023047
)

base.reg( 'PRMarketCustomBuyList', 'SMsgHead',
    {
        { 'equip', 'uint8' },		-- YY甲类型 kEquipYYY
        { 'level', 'uint16' },		-- T1, T2 ... Tx 对应的等级( 20, 35, 50, 65, 80, 95, 110, 125, 140, 155 )
        { 'data', { 'array', 'SMarketSellCargo' } },
    }, 1472681061
)

-- 返回买方列表
base.reg( 'PRMarketBuyList', 'SMsgHead',
    {
        { 'data', { 'indices', 'SMarketSellCargo' } },
    }, 1411658984
)

-- 返回买方单数据
base.reg( 'PRMarketBuyData', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectUpdate, kObjectDel
        { 'data', 'SMarketSellCargo' },
    }, 1819854724
)

-- @@请求卖方列表
base.reg( 'PQMarketSellList', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器标识(仅服务器处理)
    }, 1030132927
)

base.reg( 'PRMarketSellList', 'SMsgHead',
    {
        { 'data', { 'indices', 'SMarketSellCargo' } },
    }, 1659115855
)

base.reg( 'PRMarketSellData', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectUpdate, kObjectDel
        { 'data', 'SMarketSellCargo' },
    }, 1824851074
)

-- 请求上架货物
base.reg( 'PQMarketCargoUp', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器标识(仅服务器处理)
        { 'coin', 'S3UInt32' },		-- 上架货品, 目前只接受[ kCoinItem( 可交易, 未绑定 ) ]
        { 'percent', 'uint8' },		-- 上架货物价值比值[ 80 - 180 ], 默认值 100
    }, 761321872
)

-- 请求下架货物
base.reg( 'PQMarketCargoDown', 'SMsgHead',
    {
        { 'cargo_id', 'uint32' },		-- 需下架的货物id
    }, 107099549
)

base.reg( 'PRMarketCargoDown', 'SMsgHead',
    {
        { 'data', 'SMarketSellCargo' },
    }, 2006886785
)

-- 交易口价格修改
base.reg( 'PQMarketCargoChange', 'SMsgHead',
    {
        { 'cargo_id', 'uint32' },
        { 'percent', 'uint8' },		-- 物价值修改[ 80 - 180 ]
    }, 921604485
)

-- 购买货物
base.reg( 'PQMarketBuy', 'SMsgHead',
    {
        { 'guid', 'uint32' },		-- 用户内唯一 SUserCargo guid
        { 'count', 'uint32' },		-- 购买数量
        { 'value', 'uint32' },		-- guid != 0 为需要花费的金币, 由客户端计算服务器验证, guid = 0 为 购买的 item_id
        { 'percent', 'uint8' },		-- 客户端物价, 服务器对校物价是否存在变动, 变动会导致购买失败
    }, 350735340
)

base.reg( 'PRMarketBuy', 'SMsgHead',
    {
        { 'result', 'uint32' },		-- 0 为购买成功, 非 0 为对应错误码
        { 'value', 'uint32' },		-- 花费的金币
        { 'coin', 'S3UInt32' },		-- 购买成功获得货币
    }, 1339903691
)

-- 购买全部货物
base.reg( 'PQMarketBuyAll', 'SMsgHead',
    {
        { 'coins', { 'array', 'S3UInt32' } },		-- 批量购买列表      cate->guid用户内唯一, objid->count购买数量, val->value需要花费的金币
        { 'percent', 'uint8' },		-- 客户端物价, 服务器对校物价是否存在变动, 变动会导致购买失败
        { 'value', 'uint32' },		-- 总的价值
    }, 344619840
)

base.reg( 'PRMarketBuyAll', 'SMsgHead',
    {
        { 'result', 'uint32' },		-- 0 为购买成功, 非 0 为对应错误码
        { 'value', 'uint32' },		-- 预扣除货币值
        { 'coin', 'S3UInt32' },		-- 购买成功获得货币
    }, 1279944605
)

-- 批量获取购买数据
base.reg( 'PQMarketBatchMatch', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器标识(仅服务器处理)
        { 'coins', { 'array', 'S3UInt32' } },		-- 批量匹配列表
    }, 382628001
)

base.reg( 'PRMarketBatchMatch', 'SMsgHead',
    {
        { 'result', 'uint32' },		-- 0 为购买成功, 非 0 为对应错误码
        { 'sid', 'uint32' },		-- 服务器标识(仅服务器处理)
        { 'cargos', { 'array', 'SMarketMatch' } },		-- 预购物信息
    }, 1229779097
)

-- 批量货物购买
base.reg( 'PQMarketBatchBuy', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器标识(仅服务器处理)
        { 'cargos', { 'array', 'SMarketMatch' } },		-- 购物信息
        { 'value', 'uint32' },		-- 预扣除货币值
        { 'path', 'uint32' },		-- 由客户端传递, 0 为使用默认值
    }, 214967243
)

base.reg( 'PRMarketBatchBuy', 'SMsgHead',
    {
        { 'result', 'uint32' },		-- 0 为购买成功, 非 0 为对应错误码
        { 'coins', { 'array', 'S3UInt32' } },		-- 批量购买列表
        { 'value', 'uint32' },		-- 预扣除货币值
        { 'path', 'uint32' },
    }, 1792916194
)

-- 请求售出金钱
base.reg( 'PQMarketSell', 'SMsgHead',
    {
        { 'cargo_id', 'uint32' },		-- id
    }, 402301576
)

base.reg( 'PRMarketSell', 'SMsgHead',
    {
        { 'cargo_id', 'uint32' },		-- id
        { 'name', 'string' },		-- 购买人名称
        { 'value', 'uint32' },		-- 交易金币量
        { 'coin', 'S3UInt32' },		-- 交易货品
    }, 1795127888
)

base.reg( 'PQMarketSocialReset', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 将指定服的购买索引转移到跨服索引(sid = 0)
    }, 131107855
)

base.reg( 'PQMarketDownTimeout', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器id
    }, 338435276
)

base.reg( 'PQMarketSellTimeout', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器id 
    }, 262770350
)

-- 服务器中转协议
base.reg( 'PQMarketList', 'SMsgHead',
    {
    }, 532964337
)

base.reg( 'PRMarketList', 'SMsgHead',
    {
        { 'list', { 'array', 'SMarketSellCargo' } },		-- list 为空时为最后一个数据包
    }, 1593277506
)

-- 返回单条日志( 卖品售出后 )
base.reg( 'PRMarketLogData', 'SMsgHead',
    {
        { 'data', 'SMarketLog' },
    }, 2026116139
)


