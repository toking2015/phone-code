local const = trans.const
local err = trans.err
local base = trans.base

const.kPathActivityClose		= 1417400276		-- 活动关闭
const.kPathActivityOpen		= 677971819		-- 活动打开
const.kPathActivityReward		= 1700752458		-- 活动奖励
const.kActivityTimeTypeBound		= 1		-- 固定时间范围内开启 
const.kActivityTimeTypeOpen		= 2		-- 根据开服时间开启 
const.kActivityTimeTypeUnite		= 3		-- 根据合服时间开启 
const.kActivityTimeTypeLevel		= 4		-- 根据玩家等级开启 
const.kActivityTimeTypePersonal		= 5		-- 根据个人变量确定活动开启时间  //暂不实现
const.kActivityTimeTypeLimitOpen		= 12		-- 根据开服时间排斥 
const.kActivityTimeTypeLimitUnite		= 13		-- 根据合服时间排斥 
const.kActivityDataTypeMax		= 30		-- 最大值       //图标类型
const.kActivityFactorTypeFirstPay		= 1		-- 首充X
const.kActivityFactorTypeAddPay		= 2		-- 累积充值X
const.kActivityFactorTypeLevel		= 3		-- 等级达到X级
const.kActivityFactorTypeSerialLogin		= 4		-- 连续登录X天
const.kActivityFactorTypeGetSoldier		= 5		-- 搜集X个英雄
const.kActivityFactorTypeUpSoldier		= 6		-- 进阶X个英雄到X品质
const.kActivityFactorTypeGetTotem		= 7		-- 搜集X个图腾
const.kActivityFactorTypeMaxStartTotem		= 8		-- 图腾总星级达到X级
const.kActivityFactorTypePassTomb		= 9		-- 大墓地通过第X关
const.kActivityFactorTypeVipLevel		= 10		-- VIP等级达到X级
const.kActivityFactorTypeTimeTatalGold		= 11		-- 活动期间累计消耗XX钻石
const.kActivityFactorTypeDayTatalGold		= 12		-- 每日消耗XX钻石
const.kActivityFactorTypeTimeTatalMoney		= 13		-- 活动期间累计消耗XX金币
const.kActivityFactorTypeDayTatalMoney		= 14		-- 每日消耗XX金币
const.kActivityFactorTypeTimeTatalBetGold		= 15		-- 活动期间进行X次钻石抽卡
const.kActivityFactorTypeDayTatalBetGold		= 16		-- 每日进行X次钻石抽卡
const.kActivityFactorTypeTimeTatalBetMoney		= 17		-- 活动期间进行X次普通抽卡
const.kActivityFactorTypeDayTatalBetMoney		= 18		-- 每日进行X次普通抽卡
const.kActivityFactorTypeDayTimesPayTimesGold		= 19		-- 每日第X次单笔充值X
const.kActivityFactorTypeMax		= 20		-- 最大值

err.kErrActivitySqlInvaild		= 2085082349		--数据库存不可用

-- 活动时间数据
base.reg( 'SActivityOpen', nil,
    {
        { 'guid', 'uint32' },
        { 'group', 'string' },		-- 平台   NULL所有平台
        { 'name', 'string' },
        { 'data_id', 'uint32' },		-- <对应 SActivityData中的guid>
        { 'type', 'uint32' },		-- kActivityTimeTypeBound
        { 'first_time', 'string' },
        { 'second_time', 'string' },
        { 'show_time', 'uint32' },
        { 'hide_time', 'uint32' },
    }
)

-- 活动数据
base.reg( 'SActivityData', nil,
    {
        { 'guid', 'uint32' },		-- 唯一
        { 'group', 'string' },
        { 'type', 'uint32' },		-- kActivityDataTypeFirtPay
        { 'cycle', 'uint32' },		-- 周期      天
        { 'name', 'string' },
        { 'desc', 'string' },
        { 'value_list', { 'array', 'string' } },		-- 条件奖励值  1%2    1=if_map.key   2=reward_map.key   
    }
)

-- 活动条件
base.reg( 'SActivityFactor', nil,
    {
        { 'guid', 'uint32' },		-- 唯一
        { 'group', 'string' },
        { 'desc', 'string' },
        { 'type', 'uint32' },		-- kActivityFactorTypeFirstPay
        { 'value', 'uint32' },
        { 'value1', 'uint32' },
    }
)

-- 活动奖励
base.reg( 'SActivityReward', nil,
    {
        { 'guid', 'uint32' },		-- 唯一
        { 'group', 'string' },
        { 'value_list', { 'array', 'string' } },
    }
)

base.reg( 'SActivityInfo', nil,
    {
        { 'name', 'string' },		-- 活动标志
        { 'start_time', 'uint32' },		-- 活动开启时间
        { 'end_time', 'uint32' },		-- 活动结束时间
    }
)

-- =========================数据中心==========================
base.reg( 'CActivity', nil,
    {
        { 'open_map', { 'indices', 'SActivityOpen' } },		-- 活动时间
        { 'data_map', { 'indices', 'SActivityData' } },		-- 活动内容
        { 'factor_map', { 'indices', 'SActivityFactor' } },		-- 活动条件
        { 'reward_map', { 'indices', 'SActivityReward' } },		-- 活动奖励
        { 'open_name_map', { 'map', 'uint32' } },		-- 活动名字表        
    }
)

-- 从share 加载数据 -SActivityOpen
base.reg( 'PQActivityOpenLoad', 'SMsgHead',
    {
    }, 812917395
)

base.reg( 'PRActivityOpenLoad', 'SMsgHead',
    {
        { 'list', { 'array', 'SActivityOpen' } },
    }, 2080405480
)

-- 从share 加载数据 -SActivityData
base.reg( 'PQActivityDataLoad', 'SMsgHead',
    {
    }, 441874233
)

base.reg( 'PRActivityDataLoad', 'SMsgHead',
    {
        { 'list', { 'array', 'SActivityData' } },
    }, 1519164061
)

-- 从share 加载数据 - SActivityFactor
base.reg( 'PQActivityFactorLoad', 'SMsgHead',
    {
    }, 244536826
)

base.reg( 'PRActivityFactorLoad', 'SMsgHead',
    {
        { 'list', { 'array', 'SActivityFactor' } },
    }, 1405068803
)

-- 从share 加载数据 -SActivityReward
base.reg( 'PQActivityRewardLoad', 'SMsgHead',
    {
    }, 173095659
)

base.reg( 'PRActivityRewardLoad', 'SMsgHead',
    {
        { 'list', { 'array', 'SActivityReward' } },
    }, 1427341341
)

-- 活动接入--黄少卿
base.reg( 'PQActivityList', 'SMsgHead',
    {
    }, 255414195
)

base.reg( 'PRActivityList', 'SMsgHead',
    {
        { 'activity_open_list', { 'array', 'SActivityOpen' } },
        { 'activity_data_list', { 'array', 'SActivityData' } },
        { 'activity_factor_list', { 'array', 'SActivityFactor' } },
        { 'activity_reward_list', { 'array', 'SActivityReward' } },
    }, 1239021585
)

-- 进行中的活动
base.reg( 'PQActivityInfoList', 'SMsgHead',
    {
    }, 707651935
)

base.reg( 'PRActivityInfoList', 'SMsgHead',
    {
        { 'list', { 'array', 'SActivityInfo' } },
    }, 1390946469
)

base.reg( 'PQActivityTakeReward', 'SMsgHead',
    {
        { 'open_guid', 'uint32' },
        { 'index', 'uint32' },		-- 第几个条件 从0开始
    }, 378704425
)

base.reg( 'PRActivityTakeReward', 'SMsgHead',
    {
        { 'open_guid', 'uint32' },
        { 'index', 'uint32' },		-- 第几个条件 从0开始
    }, 1687101483
)


