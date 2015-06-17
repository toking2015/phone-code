local const = trans.const
local err = trans.err
local base = trans.base

const.kCoinNone		= 0		-- 非货币
const.kCoinMoney		= 1		-- 金币
const.kCoinTicket		= 2		-- 礼券
const.kCoinGold		= 3		-- 钻石
const.kCoinItem		= 4		-- 物品
const.kCoinSoldier		= 5		-- 武将
const.kCoinBuilding		= 6		-- 建筑产物   objid为building.seq中对应 kBuildingTypeMajor
const.kCoinTeamXp		= 7		-- 战队经验(主经验) 
const.kCoinVipXp		= 8		-- vip经验
const.kCoinTeamLevel		= 9		-- 战队等级(主等级)
const.kCoinVipLevel		= 10		-- vip等级
const.kCoinStrength		= 11		-- 体力
const.kCoinWater		= 12		-- 圣水
const.kCoinTotem		= 13		-- 图腾
const.kCoinStar		= 14		-- 星星
const.kCoinActiveScore		= 15		-- 活跃值
const.kCoinMedal		= 16		-- 勋章
const.kCoinGlyph		= 17		-- 神符
const.kCoinTomb		= 18		-- 墓地
const.kCoinTempleScore		= 19		-- 神殿积分
const.kCoinArenaWinCount		= 20		-- 竞技场赢的次数
const.kCoinEquipWhite		= 21		-- 白装
const.kCoinEquipGreen		= 22		-- 绿装
const.kCoinEquipBlue		= 23		-- 蓝装
const.kCoinEquipPurple		= 24		-- 紫装
const.kCoinEquipOrange		= 25		-- 橙装
const.kCoinBox		= 26		-- 宝箱
const.kCoinGuildContribute		= 27		-- 公会贡献度
const.kCoinDayTaskVal		= 28		-- 日常任务积分
const.kCoinFlagBind		= 1		-- 货币绑定
const.kCoinFlagOverflow		= 2		-- 增加货币时忽略货币最大值
const.kCoinFlagQuiet		= 4		-- 安静处理, 不作用户知通, 不用事件回调的处理操作

err.kErrCoinLack		= 33754927		--货币不足

-- 基本货币-黄少卿, 所有货币基本值都必须使用 uint32
base.reg( 'SUserCoin', nil,
    {
        { 'money', 'uint32' },		-- 游戏内第一交易货币
        { 'gold', 'uint32' },		-- 充值货币, 主要用作交易
        { 'ticket', 'uint32' },		-- 一般用作充值货币的代替品, 不允许交易
        { 'water', 'uint32' },		-- 圣水
        { 'star', 'uint32' },		-- 星星
        { 'active_score', 'uint32' },		-- 活跃值
        { 'medal', 'uint32' },		-- 勋章
        { 'tomb', 'uint32' },		-- 墓地
        { 'guild_contribute', 'uint32' },		-- 公会贡献度
        { 'day_task_val', 'uint32' },		-- 日常任务积分
    }
)


