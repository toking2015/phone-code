local const = trans.const
local err = trans.err
local base = trans.base

const.kPathFormationSet		= 1268724712		-- 布阵改变
const.kFormationPosMax		= 9		-- 阵型最大数量
const.kFormationTypeCommon		= 1		-- 普通
const.kFormationTypeSingleArenaAct		= 2		-- 竞技场攻
const.kFormationTypeSingleArenaDef		= 3		-- 竞技场防
const.kFormationTypeTrialSurvival		= 4		-- 试炼生存
const.kFormationTypeTrialStrength		= 5		-- 试炼力量
const.kFormationTypeTrialAgile		= 6		-- 试炼敏捷
const.kFormationTypeIntelligence		= 7		-- 试炼智力
const.kFormationTypeYesterday		= 8		-- JJC昨天
const.kFormationTypeTomb		= 9		-- 墓地
const.kFormationTypeTombTarget		= 10		-- 墓地别人


-- 阵型-印佳
base.reg( 'SUserFormation', nil,
    {
        { 'guid', 'uint32' },		-- guid
        { 'attr', 'uint32' },		-- 玩家属性
        { 'formation_type', 'uint32' },		-- 阵型类型
        { 'formation_index', 'uint32' },		-- 阵型索引
    }
)

-- @@请求物品列表
base.reg( 'PQFormationList', 'SMsgHead',
    {
        { 'formation_type', 'uint32' },		-- 阵型类型
    }, 776361237
)

-- 返回物品列表
base.reg( 'PRFormationList', 'SMsgHead',
    {
        { 'formation_type', 'uint32' },		-- 所处背包类型
        { 'formation_list', { 'array', 'SUserFormation' } },		-- 好友列表
    }, 1602266981
)

-- @@请求阵型移动
base.reg( 'PQFormationMove', 'SMsgHead',
    {
        { 'formation_type', 'uint32' },		-- kFormationTypeCommon
        { 'guid', 'uint32' },		-- guid
        { 'attr', 'uint32' },		-- kAttrSoldier
        { 'index', 'uint32' },		-- index[0-8]
    }, 75458213
)

base.reg( 'PQFormationSet', 'SMsgHead',
    {
        { 'formation_type', 'uint32' },
        { 'formation_list', { 'array', 'SUserFormation' } },
    }, 323879387
)


