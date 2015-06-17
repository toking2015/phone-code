local const = trans.const
local err = trans.err
local base = trans.base

const.kTombFront		= 50		-- 往前取名次
const.kTombBack		= 2000		-- 往后取名词
const.kTombPart		= 5		-- 分成多少部分
const.kTombPartCount		= 4		-- 一部分多少人
const.kPathTombRewardGet		= 1394672885		-- 墓地奖励领取
const.kPathTombPlayerReset		= 2087704392		-- 墓地人物重置
const.kPathTombFight		= 878590869		-- 墓地触发战斗
const.kPathTombMopUp		= 1310537727		-- 墓地扫荡

err.kErrTombPlayerData		= 1170054082		--对战玩家信息出错
err.kErrTombRewardDataNoExitLevel		= 1698394481		--奖励数据不存在
err.kErrTombRewardDataNoExit		= 267636965		--奖励数据不存在
err.kErrTombRewardNotGet		= 905129988		--奖励未领取
err.kErrTombNotOpen		= 105739333		--未开放

-- 大墓地-印佳
base.reg( 'STombTarget', nil,
    {
        { 'attr', 'uint32' },		-- 怪物玩家
        { 'target_id', 'uint32' },		-- id
        { 'reward', 'uint32' },		-- 奖励是否领取
    }
)

base.reg( 'SUserKillInfo', nil,
    {
        { 'monster_id', 'uint32' },		-- 怪物id
        { 'count', 'uint32' },		-- 次数
    }
)

base.reg( 'SUserTomb', nil,
    {
        { 'try_count', 'uint32' },		-- 今天挑战次数 
        { 'try_count_now', 'uint32' },		-- 当前是第几次挑战
        { 'win_count', 'uint32' },		-- 胜利次数
        { 'max_win_count', 'uint32' },		-- 今天最大胜利次数
        { 'reward_count', 'uint32' },		-- 领奖次数 
        { 'totem_value_self', 'uint32' },		-- 图腾值自己
        { 'totem_value_target', 'uint32' },		-- 图腾值对面
        { 'history_win_count', 'uint32' },		-- 历史上最大胜利次数
        { 'history_reset_count', 'uint32' },		-- 历史重置次数
        { 'history_pass_count', 'uint32' },		-- 历史通关次数
        { 'history_kill_count', { 'array', 'SUserKillInfo' } },		-- 历史杀怪记录
    }
)

-- 战斗
base.reg( 'PQTombFight', 'SMsgHead',
    {
        { 'player_index', 'uint32' },		-- 玩家位置 从0开始
        { 'player_guid', 'uint32' },		-- 玩家GUID
        { 'formation_list', { 'array', 'SUserFormation' } },		-- 试炼阵型
    }, 934860173
)

-- 领奖
base.reg( 'PQTombRewardGet', 'SMsgHead',
    {
        { 'reward_index', 'uint32' },		-- 奖励位置 从0开始
    }, 1060724092
)

base.reg( 'PRTombRewardGet', 'SMsgHead',
    {
        { 'target', 'STombTarget' },		-- 领取信息 
        { 'reward_list', { 'array', 'S3UInt32' } },		-- 奖励
    }, 1318917084
)

-- 玩家重置
base.reg( 'PQTombPlayerReset', 'SMsgHead',
    {
        { 'player_index', 'uint32' },		-- 玩家位置
    }, 663519283
)

base.reg( 'PRTombPlayerReset', 'SMsgHead',
    {
        { 'player_index', 'uint32' },
        { 'target', 'STombTarget' },		-- 对战人员嘻嘻 
    }, 1853519620
)

-- 重置
base.reg( 'PQTombReset', 'SMsgHead',
    {
    }, 45751435
)

base.reg( 'PRTombReset', 'SMsgHead',
    {
        { 'tomb_info', 'SUserTomb' },		-- 墓地信息
        { 'tomb_target_list', { 'array', 'STombTarget' } },		-- 对战信息 
    }, 1929444106
)

-- 扫荡
base.reg( 'PQTombMopUp', 'SMsgHead',
    {
    }, 122187354
)

base.reg( 'PRTombMopUp', 'SMsgHead',
    {
        { 'reward_list', { 'array', 'array', 'S3UInt32' } },		-- 奖励
    }, 1828509994
)

base.reg( 'PQTombInfo', 'SMsgHead',
    {
    }, 141353931
)

base.reg( 'PRTombInfo', 'SMsgHead',
    {
        { 'info', 'SUserTomb' },		-- info 
    }, 1945453920
)

base.reg( 'PQTombTargetList', 'SMsgHead',
    {
    }, 300678455
)

base.reg( 'PRTombTargetList', 'SMsgHead',
    {
        { 'tomb_target_list', { 'array', 'STombTarget' } },		-- 对战信息
    }, 1420666319
)


