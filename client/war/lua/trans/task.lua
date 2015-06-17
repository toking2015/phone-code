local const = trans.const
local err = trans.err
local base = trans.base

const.kPathTaskAccept		= 94118515		-- 任务接受
const.kPathTaskFinished		= 1563095759		-- 任务完成奖励
const.kPathTaskAutoFinished		= 339870132		-- 自动完成任务奖励
const.kPathDayTaskValReward		= 1750380674		-- 日常任务积分领奖
const.kPathDayTaskValReset		= 1110794590		-- 日常任务积分重置
const.kTaskTypeMain		= 1		-- 主线任务
const.kTaskTypeBranch		= 2		-- 支线任务
const.kTaskTypeDayRepeat		= 3		-- 日常任务
const.kTaskTypeActivity		= 4		-- 活动任务
const.kTaskCondGut		= 1		-- 完成剧情          1%[剧情Id]%1
const.kTaskCondMonster		= 2		-- 击杀怪物          2%[怪物ClassId]%[击杀次数]
const.kTaskCondCopyFinished		= 3		-- 副本通关          3%[副本Id]%1
const.kTaskCondCopyGroup		= 4		-- 副本集群完成      4%[集群Id]%1
const.kTaskCondItem		= 5		-- 物品收集          5%[物品Id]%[数量]
const.kTaskCondLotteryCard		= 6		-- 祭坛抽卡          6%[抽卡类型(0不分类型)]%[次数]
const.kTaskCondBuildingTake		= 7		-- 建筑资源领取      7%[建筑类型]%[数量]
const.kTaskCondVipLevel		= 8		-- VIP等级           8%[0]%[等级]
const.kTaskCondMonthCard		= 9		-- 月卡剩余天数      9%[0]%[天数], 不满1天算1天
const.kTaskCondTime		= 10		-- 指定时间完成      10%[开始小时]%[结束小时]
const.kTaskCondBossKillCount		= 11		-- BOSS击杀数量      11%[分本类型(1:普通,2:精英)]%[数量]
const.kTaskCondSingleArenaBattle		= 12		-- 单人竞技场次数    12%[0]%[次数]
const.kTaskCondTrialFinished		= 13		-- 十字军试炼        13%[0]%[次数]
const.kTaskCondItemMerge		= 14		-- 打造装备          14%[0]%[次数]
const.kTaskCondMarketCargoUp		= 15		-- 市场货品上架      15%[0]%[次数]
const.kTaskCondBuildingSpeed		= 16		-- 建筑物加速        16%[建筑类型]%[次数]
const.kTaskCondTotemGlyphMerge		= 17		-- 图腾合成          17%[0]%[次数]
const.kTaskCondTeamLevel		= 18		-- 战队等级          18%[0]%[等级]
const.kTaskCondSoldierCollect		= 19		-- 英雄数量          19%[0]%[数量]
const.kTaskCondTotemLevel		= 20		-- 图腾等级数        20%[等级]%[图腾数]
const.kTaskCondSoldierQuality		= 21		-- 英雄品质          21%[等级]%[英雄数]
const.kTaskCondVendibleBuy		= 22		-- 商品购买          22%[vendible_id]%[数量]
const.kTaskCondTotemSkillLevelUp		= 23		-- 图腾技能升级数    23%0%[次数]
const.kTaskCondSoldierLevelUp		= 24		-- 武将升级数        24%0%[次数]
const.kTaskCondBossKillId		= 25		-- BOSS指定击杀      25%[boss_id]%1
const.kTaskCondMonsterTeam		= 26		-- 击杀怪物组合      26%[monster_id]%[击杀次数]
const.kTaskCondTotem		= 27		-- 获得图腾          27%[totem_id]%1
const.kTaskCondTomb		= 28		-- 大墓地            28%[关数]%1
const.kTaskCondWeiXinShared		= 29		-- 微信分享          29%[0]%[次数]
const.kTaskCondChat		= 30		-- 聊天发言          30%[频道(1全服,2副本,3公会)]%[次数]
const.kTaskCondFriendGiveActiveScoreTimes		= 31		-- 好友活跃赠送      31%[0]%[次数]

err.kErrTaskLevelLimit		= 1027262878		--任务等级限制
err.kErrTaskExist		= 1499676256		--任务已存在
err.kErrTaskFrontLog		= 1762712797		--前置任务未完成
err.kErrTaskFrontCopy		= 646451468		--前置副本未通关
err.kErrTaskLogExist		= 1125439091		--任务已完成
err.kErrTaskDayRepeatMax		= 891902097		--日常任务数量限制
err.kErrTaskNotExist		= 895190570		--任务数据不存在
err.kErrTaskCondUnfinished		= 1353496591		--任务条件未完成
err.kErrTaskCondReject		= 1693029574		--任务条件拒绝客户端修改
err.kErrTaskActivityClose		= 690805510		--活动已关闭, 不能接受活动任务
err.kErrTaskDayRewardNotExist		= 500602654		--日常任务积分奖励不存在
err.kErrTaskDayRewardNotEnough		= 357462144		--日常任务积分不足
err.kErrTaskDayRewardAlreadyGot		= 248704276		--日常任务积分奖励已领取

-- 任务-黄少卿
base.reg( 'SUserTask', nil,
    {
        { 'task_id', 'uint32' },
        { 'cond', 'uint32' },		-- 任务条件完成值
        { 'create_time', 'uint32' },		-- 任务接受时间
    }
)

-- 用于保存 主线任务,支线任务,活动任务 的任务记录( 日常任务不保存完成记录 )
base.reg( 'SUserTaskLog', nil,
    {
        { 'task_id', 'uint32' },
        { 'create_time', 'uint32' },		-- 任务接受时间
        { 'finish_time', 'uint32' },		-- 任务完成时间
    }
)

-- 日常任务记录(每天清空)
base.reg( 'SUserTaskDay', nil,
    {
        { 'task_id', 'uint32' },
        { 'create_time', 'uint32' },		-- 任务接受时间
        { 'finish_time', 'uint32' },		-- 任务完成时间
    }
)

-- @@请求任务列表
base.reg( 'PQTaskList', 'SMsgHead',
    {
    }, 848369111
)

base.reg( 'PRTaskList', 'SMsgHead',
    {
        { 'list', { 'indices', 'SUserTask' } },
    }, 1480421482
)

-- @@请求任务记录列表
base.reg( 'PQTaskLogList', 'SMsgHead',
    {
    }, 690366673
)

base.reg( 'PRTaskLogList', 'SMsgHead',
    {
        { 'list', { 'indices', 'SUserTaskLog' } },
    }, 1234819902
)

-- @@请求接受任务
base.reg( 'PQTaskAccept', 'SMsgHead',
    {
        { 'task_id', 'uint32' },
    }, 896801999
)

-- @@任务完成
base.reg( 'PQTaskFinish', 'SMsgHead',
    {
        { 'task_id', 'uint32' },
    }, 403585854
)

-- @@任务自动完成
base.reg( 'PQTaskAutoFinish', 'SMsgHead',
    {
        { 'task_id', 'uint32' },
    }, 869618664
)

-- @@任务数据更新
base.reg( 'PQTaskSet', 'SMsgHead',
    {
        { 'task_id', 'uint32' },
        { 'cond', 'uint32' },		-- 任务条件完成值( 部分任务由客户端主动提交数值修改 )
    }, 3607773
)

base.reg( 'PRTaskSet', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectDel, kObjectUpdate
        { 'data', 'SUserTask' },
    }, 2040321963
)

-- 返回任务完成记录( 只增不删 )
base.reg( 'PRTaskLog', 'SMsgHead',
    {
        { 'data', 'SUserTaskLog' },
    }, 2119306534
)

-- 返回单个日常任务记录( 只增改 )
base.reg( 'PRTaskDay', 'SMsgHead',
    {
        { 'data', 'SUserTaskDay' },
    }, 1238179220
)

-- 返回日常任务记录列表
base.reg( 'PRTaskDayList', 'SMsgHead',
    {
        { 'data', { 'indices', 'SUserTaskDay' } },
    }, 1843551594
)

-- 日常活动积分领奖
base.reg( 'PQTaskDayValReward', 'SMsgHead',
    {
        { 'id', 'uint32' },
    }, 994921066
)

base.reg( 'PRTaskDayValReward', 'SMsgHead',
    {
        { 'id', 'uint32' },
        { 'err', 'uint32' },
    }, 1981998351
)

-- 日常活动积分奖励列表
base.reg( 'PRTaskDayValRewardList', 'SMsgHead',
    {
        { 'id_list', { 'array', 'uint32' } },
    }, 1705235466
)


