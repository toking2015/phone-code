local const = trans.const
local err = trans.err
local base = trans.base

const.kPathAltar		= 1583754902		--  祭坛 
const.kAltarLotteryByMoney		= 1		--  金币抽奖
const.kAltarLotteryByGold		= 2		--  钻石抽奖
const.kAltarLotteryUseDefault		= 1		--  默认，即：金币抽卡将消耗金币，钻石抽卡消耗钻石
const.kAltarLotteryUseFree		= 2		--  使用免费的次数
const.kAltarLotteryUseItem		= 3		--  使用道具

err.kErrAltarCopyNotPassed		= 1601363085		-- 亲别急，先开荒副本吧

--  抽奖
base.reg( 'SAltarInfo', nil,
    {
        { 'reset_time', 'uint32' },		--  重置时间
        { 'free_count', 'uint32' },		--  免费次数
        { 'free_time', 'uint32' },		--  免费抽取的时间
        { 'gold_free_time', 'uint32' },		--  钻石免费抽取的时间
        { 'money_seed_1', 'uint32' },
        { 'money_seed_10', 'uint32' },
        { 'gold_seed_1', 'uint32' },
        { 'gold_seed_10', 'uint32' },
    }
)

-- =========================通迅协议============================
base.reg( 'PQAltarInfo', 'SMsgHead',
    {
    }, 11246124
)

base.reg( 'PRAltarInfo', 'SMsgHead',
    {
        { 'info', 'SAltarInfo' },
    }, 2075834311
)

--  抽奖 
base.reg( 'PQAltarLottery', 'SMsgHead',
    {
        { 'lottery_type', 'uint32' },		--  抽奖类型, kAltarLotteryByMoney或kAltarLotteryByGold
        { 'lottery_count', 'uint32' },		--  抽奖次数
        { 'use_type', 'uint32' },		--  使用类型
    }, 512180379
)

base.reg( 'PRAltarLottery', 'SMsgHead',
    {
        { 'id_list', { 'array', 'uint32' } },
        { 'reward_list', { 'array', 'S3UInt32' } },
        { 'extra_reward_list', { 'array', 'S3UInt32' } },
        { 'soldier_id', 'uint32' },
        { 'info', 'SAltarInfo' },
    }, 1154904222
)


