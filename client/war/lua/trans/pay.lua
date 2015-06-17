local const = trans.const
local err = trans.err
local base = trans.base

const.kPayFlagTake		= 1		-- 货币领取标志
const.kPayTypeNormal		= 1		-- 普通, 充钻石
const.kPayTypeSpecial		= 2		-- 特殊充值
const.kPathPay		= 1647769913		-- 充值
const.kPathFirstPay		= 1351766338		-- 首次充值
const.kPathMonthReward		= 1332934034		-- 月卡奖励
const.kPathPayPresent		= 1491980783		-- 充值赠送

err.kErrPayMonthTimeLack		= 2072000969		--月卡已经过期
err.kErrPayMonthRewardHaveGet		= 833990684		--今天的月卡奖励已经领取
err.kErrPayFristPayRewardGet		= 953400842		--已经领取过首充奖励

-- ==========================通迅结构==========================
base.reg( 'SUserPayInfo', nil,
    {
        { 'pay_sum', 'uint32' },		-- 充值总额
        { 'pay_count', 'uint32' },		-- 充值次数
        { 'month_time', 'uint32' },		-- 月卡到期时间
        { 'month_reward', 'uint32' },		-- 月卡每天奖励
    }
)

-- 基本支付-印佳, 所有货币基本值都必须使用 uint32
base.reg( 'SUserPay', nil,
    {
        { 'uid', 'uint32' },		-- 唯一id
        { 'price', 'uint32' },		-- 充值金额(RMB), 价值 != 钻石
        { 'time', 'uint32' },		-- 充值日期
        { 'type', 'uint8' },		-- 充值类型 [ kPayTypeNormal | kPayTypeSpecial ]
        { 'flag', 'uint8' },		-- 标记kPayFlagTake
    }
)

-- @@请求新增加的订单
base.reg( 'PQPayList', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 目标ID
    }, 393345959
)

base.reg( 'PRPayList', 'SMsgHead',
    {
        { 'list', { 'array', 'SUserPay' } },		-- pay_list
    }, 1166471284
)

-- @@请求Pay信息
base.reg( 'PQPayInfo', 'SMsgHead',
    {
    }, 676129012
)

base.reg( 'PRPayInfo', 'SMsgHead',
    {
        { 'data', 'SUserPayInfo' },		-- PayInfo
    }, 2011903693
)

-- @@请求领取月卡奖励
base.reg( 'PQPayMonthReward', 'SMsgHead',
    {
    }, 923533371
)

base.reg( 'PRPayMonthReward', 'SMsgHead',
    {
    }, 2052680871
)

-- @@请求领取首充奖励
base.reg( 'PQPayFristPayReward', 'SMsgHead',
    {
    }, 43330202
)

-- 废弃
base.reg( 'PQReplyFristPayReward', 'SMsgHead',
    {
    }, 898214691
)

-- 废弃
base.reg( 'PRReplyFristPayReward', 'SMsgHead',
    {
        { 'flag', 'uint32' },		-- 领取标识
    }, 1488769700
)

-- 充值通知( 仅通知 )
base.reg( 'PRPayNotice', 'SMsgHead',
    {
        { 'uid', 'uint32' },		-- 唯一id
        { 'coin', 'uint32' },		-- 充值的RMB
    }, 1722629611
)

-- ======================服务器中转====================
base.reg( 'PQPayNotice', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- realdb 通知 game
    }, 721071533
)


