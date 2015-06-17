local const = trans.const
local err = trans.err
local base = trans.base

const.kSignNormal		= 1		--  正常签到
const.kSignAdditional		= 2		--  补签
const.kPathSign		= 947156890		--  签到

err.kErrSignBeforeSvrOpen		= 1767476840		-- 签到日期比开服时间早

--  每日签到
base.reg( 'SSign', nil,
    {
        { 'day_id', 'uint32' },		--  签到日期id
        { 'sign_type', 'uint32' },		--  签到类型, kSignNormal或kSignAdditional
        { 'sign_time', 'uint32' },		--  签到时间
    }
)

base.reg( 'SSignInfo', nil,
    {
        { 'sign_list', { 'array', 'SSign' } },		--  签到列表
        { 'sum_list', { 'array', 'uint32' } },		--  累计签到已领取奖励id列表
    }
)

--  签到信息
base.reg( 'PQSignInfo', 'SMsgHead',
    {
    }, 35064835
)

base.reg( 'PRSignInfo', 'SMsgHead',
    {
        { 'info', 'SSignInfo' },
    }, 1494253166
)

--  签到
base.reg( 'PQSign', 'SMsgHead',
    {
    }, 1005883788
)

base.reg( 'PRSign', 'SMsgHead',
    {
        { 'sign', 'SSign' },
    }, 1149402159
)

--  领取累计签到奖励
base.reg( 'PQTakeSignSumReward', 'SMsgHead',
    {
        { 'reward_id', 'uint32' },		--  奖励id
    }, 664307434
)

base.reg( 'PRTakeSignSumReward', 'SMsgHead',
    {
        { 'reward_id', 'uint32' },
    }, 1148020005
)

--  领取豪华奖励
base.reg( 'PQTakeHaohuaReward', 'SMsgHead',
    {
    }, 977425689
)

base.reg( 'PRTakeHaohuaReward', 'SMsgHead',
    {
    }, 2024857271
)


