local const = trans.const
local err = trans.err
local base = trans.base

const.kPathOpenTargetBuy		= 448618963		-- 开服目标购买半价物品
const.kPathOpenTargetTake		= 1789308928		-- 开服目标领取奖励
const.kOpenTargetActionTypeBuy		= 4		-- 半价抢购
const.kOpenTargetIfTypeLogin		= 1		-- 登录
const.kOpenTargetIfTypeAddPay		= 2		-- 累积充值
const.kOpenTargetIfTypeMainCopy		= 3		-- 主线副本
const.kOpenTargetIfTypePefectCopy		= 4		-- 精英副本
const.kOpenTargetIfTypeTeamLevel		= 5		-- 战队等级
const.kOpenTargetIfTypeEquip		= 6		-- 装备
const.kOpenTargetIfTypeSoldier		= 7		-- 英雄
const.kOpenTargetIfTypeSingleare		= 8		-- 竞技场
const.kOpenTargetIfTypeTomb		= 9		-- 大墓地
const.kOpenTargetIfTypeTotem		= 10		-- 图腾
const.kOpenTargetIfTypeSoldierTeam		= 11		-- 英雄组合
const.kOpenTargetIfTypeGlyph		= 12		-- 雕纹
const.kOpenTargetIfTypeAll		= 100		-- 全部条件


-- 领取奖励
base.reg( 'PQOpenTargetTake', 'SMsgHead',
    {
        { 'day', 'uint32' },		-- 天      OpenTarget.xls中的day
        { 'guid', 'uint32' },		-- 唯一id  OpenTarget.xls中的id
    }, 989782867
)

base.reg( 'PROpenTargetTake', 'SMsgHead',
    {
        { 'day', 'uint32' },
        { 'guid', 'uint32' },
    }, 1126082129
)

-- 购买半价物品
base.reg( 'PQOpenTargetBuy', 'SMsgHead',
    {
        { 'day', 'uint32' },
        { 'guid', 'uint32' },
    }, 605587023
)

base.reg( 'PROpenTargetBuy', 'SMsgHead',
    {
        { 'day', 'uint32' },
        { 'guid', 'uint32' },
    }, 1092130525
)


