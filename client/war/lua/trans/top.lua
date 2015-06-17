local const = trans.const
local err = trans.err
local base = trans.base

const.kTopUser		= 1
const.kTopGuild		= 2

err.kErrNoUser		= 1483954651

-- 用户排行相关信息
base.reg( 'SUserTop', nil,
    {
        { 'dailygain_time', 'uint32' },		-- 日增变量时间戳
        { 'dailygain_xp', 'uint32' },		-- 日增经验值
        { 'dailygain_soldier', 'uint16' },		-- 日增武将数量
        { 'dailygain_fame', 'uint32' },		-- 日增名望值
    }
)

-- ##玩家排行相关数据保存
base.reg( 'PQTopSave', 'SMsgHead',
    {
        { 'top_data', 'SUserTop' },
    }, 195577959
)

-- @@玩家排行相关数据获取
base.reg( 'PQTopData', 'SMsgHead',
    {
    }, 766459091
)

base.reg( 'PRTopData', 'SMsgHead',
    {
        { 'top_data', 'SUserTop' },
    }, 1986846505
)


