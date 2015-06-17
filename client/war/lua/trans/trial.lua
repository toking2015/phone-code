local const = trans.const
local err = trans.err
local base = trans.base

const.kTrialSurvival		= 1		-- 生存
const.kTrialStrength		= 2		-- 力量
const.kTrialAgile		= 3		-- 敏捷
const.kTrialIntelligence		= 4		-- 智力
const.kPathTrialSurvival		= 374239832		-- 生存
const.kPathTrialStrength		= 2132077111		-- 力量
const.kPathTrialAgile		= 537836721		-- 敏捷
const.kPathTrialIntelligence		= 306505229		-- 智力
const.kPathTrialFinish		= 1253727759		-- 试炼结束
const.kPathTrialRewardGet		= 231757346		-- 奖励领取

err.kErrTrialRewardDataNoExit		= 494174446		--奖励数据不存在
err.kErrTrialRewardHave		= 749815519		--奖励已经领取
err.kErrTrialRewardDataNoExitLevel		= 564084311		--这个等级的奖励不存在
err.kErrTrialDataNoExit		= 1661989178		--数据不存在
err.kErrTrialNotOpen		= 1726924814		--暂不开放
err.kErrTrialTryCount		= 768444096		--进入次数已经满
err.kErrTrialRewardValNot		= 831131258		--试炼值不够

-- ==========================通迅结构==========================
base.reg( 'SUserTrialReward', nil,
    {
        { 'trial_id', 'uint32' },		-- 试炼Id
        { 'reward', 'uint32' },		-- 奖励id
        { 'flag', 'uint32' },		-- 是否领取
    }
)

base.reg( 'SUserTrial', nil,
    {
        { 'trial_id', 'uint32' },		-- 试炼Id
        { 'trial_val', 'uint32' },		-- 试炼值
        { 'try_count', 'uint32' },		-- 挑战次数
        { 'reward_count', 'uint32' },		-- 奖励领取次数
        { 'max_single_val', 'uint32' },		-- 单次最大值
    }
)

-- =========================通迅协议============================
base.reg( 'PQTrialEnter', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼Id
        { 'formation_list', { 'array', 'SUserFormation' } },		-- 试炼阵型
    }, 189825132
)

base.reg( 'PQTrialRewardList', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼ID
    }, 644273634
)

base.reg( 'PRTrialRewardList', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼ID
        { 'reward_list', { 'array', 'SUserTrialReward' } },
    }, 1679379448
)

base.reg( 'PQTrialRewardGet', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼ID
        { 'index', 'uint32' },		-- 奖励index
    }, 745746844
)

base.reg( 'PRTrialRewardGet', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼ID
        { 'index', 'uint32' },		-- 奖励index
    }, 1462254479
)

base.reg( 'PQTrialRewardEnd', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼ID
    }, 84089290
)

base.reg( 'PRTrialRewardEnd', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼ID
    }, 1907887097
)

-- 请求更新
base.reg( 'PQTrialUpdate', 'SMsgHead',
    {
    }, 898503924
)

base.reg( 'PRTrialUpdate', 'SMsgHead',
    {
        { 'user_trial', 'SUserTrial' },		-- 更新    
    }, 1768293067
)

base.reg( 'PQTrialMopUp', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼ID
    }, 634559810
)

base.reg( 'PRTrialMopUp', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 试炼ID
        { 'trial_val', 'uint32' },		-- 当前的值
    }, 1409767765
)


