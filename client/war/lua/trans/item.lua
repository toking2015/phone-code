local const = trans.const
local err = trans.err
local base = trans.base

const.kPathItemDice		= 1324150315		-- 物品拆分
const.kPathItemMove		= 1142902209		-- 物品移动
const.kPathItemAdd		= 2027073428		-- 物品移动
const.kPathSell		= 1010394484		-- 物品删除
const.kPathRedeem		= 1351704370		-- 物品回购
const.kPathMerge		= 265266382		-- 物品合成
const.kPathItemUse		= 1028625609		-- 使用物品 
const.kPathMergeEquip		= 2025500073		-- 装备合成
const.kPathMergeBook		= 1554365024		-- 技能书合成
const.kItemRandMax		= 6		-- 物品随机属性最大数目
const.kItemSlotMax		= 3		-- 物品插孔最大数目
const.kBagFuncCommon		= 1		-- 普通背包
const.kBagFuncBank		= 2		-- 银行
const.kBagFuncRedeem		= 3		-- 回收站
const.kBagFuncSoldierEquip		= 4		-- 武将装备
const.kBagFuncSoldierEquipSkill		= 5		-- 武将装备技能书
const.kBagFuncSoldierEquipTemp		= 6		-- 武将装备合成缓存
const.kItemEquipTypeHead		= 1		-- 头
const.kItemEquipTypeChest		= 2		-- 身
const.kItemEquipTypeLegs		= 3		-- 腿
const.kItemEquipTypeShoulders		= 4		-- 肩
const.kItemEquipTypeHands		= 5		-- 手
const.kItemEquipTypeFeet		= 6		-- 脚
const.kItemTypeEquip		= 1		-- 装备
const.kItemTypeGift		= 2		-- 礼包
const.kItemTypeMaterial		= 3		-- 材料
const.kItemTypeSoulStone		= 4		-- 灵魂石
const.kItemClientTypeConsume		= 1		-- 消耗品
const.kItemClientTypeSoulStone		= 2		-- 灵魂石
const.kItemClientTypeMaterial		= 3		-- 材料
const.kItemUseAddRewardRandom		= 1		-- 随机获得一个奖励
const.kItemUseAddRewardIndex		= 2		-- 确定获得一个物品
const.kItemMergeTypeEquip		= 1		-- 装备
const.kItemMergeTypeSkillBook		= 2		-- 技能书

err.kErrItemDataNotExist		= 1155188034		--物品不存在
err.kErrItemGuidNotExist		= 541242787		--物品不存在
err.kErrItemMoveIllegalBag		= 1360543255		--不能移动到目的背包
err.kErrItemDiceCount		= 944967853		--拆分数目不正确
err.kErrItemNoSell		= 1088693056		--物品不能出售
err.kErrItemSpaceFull		= 256824735		--背包已经满  
err.kErrItemMergeLevel		= 159035261		--物品合成等级限制
err.kErrItemOpenRewardDataNoExitLevel		= 152412089		--物品奖励不存在
err.kErrItemUseLimitLevel		= 412854821		--物品使用等级限制

-- 物品-印佳
base.reg( 'SWildItem', nil,
    {
        { 'item_id', 'uint32' },		-- 物品ID
        { 'firm_level', 'uint8' },		-- 强化级别
        { 'count', 'uint32' },		-- 数量
        { 'due_time', 'uint32' },		-- 过期时间
        { 'main_attr_factor', 'uint32' },		-- 主属性品质系数
        { 'slave_attr_factor', 'uint32' },		-- 副属性品质系数
        { 'slave_attrs', { 'array', 'uint16' } },		-- 装备副属性索引
        { 'slotattr', { 'array', 'S2UInt16' } },		-- 插槽属性first:物品ID;second:插槽属性ID
        { 'flags', 'uint8' },		-- 位移属性
    }
)

-- 玩家物品
base.reg( 'SUserItem', 'SWildItem',
    {
        { 'guid', 'uint32' },		-- 惟一标识
        { 'item_index', 'uint16' },		-- 索引
        { 'soldier_guid', 'uint16' },		-- 武将GUID, 0为角色
        { 'bag_type', 'uint8' },		-- 所处背包类型
    }
)

-- ============================数据中心========================
base.reg( 'CUserItem', nil,
    {
    }
)

-- @@请求物品列表
base.reg( 'PQItemList', 'SMsgHead',
    {
        { 'bag_index', 'uint32' },		-- 所处背包类型
    }, 857480699
)

-- 返回物品列表
base.reg( 'PRItemList', 'SMsgHead',
    {
        { 'bag_index', 'uint32' },		-- 所处背包类型
        { 'item_list', { 'array', 'SUserItem' } },		-- 好友列表
    }, 1822834778
)

base.reg( 'PRItemSet', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- 修改类型 kObjectAdd、kObjectDel、kObjectUpdate
        { 'path', 'uint32' },		-- 修改系统
        { 'item', 'SUserItem' },
    }, 1778612727
)

-- @@添加一个物品
base.reg( 'PQItemAdd', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 添加物品的id
        { 'count', 'uint32' },		-- 添加物品的数量
    }, 731904243
)

-- @@物品整理
base.reg( 'PQItemSort', 'SMsgHead',
    {
        { 'bag_index', 'uint32' },		-- 所处背包类型
    }, 394473875
)

-- @@物品售出
base.reg( 'PQItemSell', 'SMsgHead',
    {
        { 'bag_type', 'uint32' },		-- kBag
        { 'item_list', { 'array', 'S2UInt32' } },		-- { [guid], count} 
    }, 222047555
)

-- @@物品赎回
base.reg( 'PQItemRedeem', 'SMsgHead',
    {
        { 'guid', 'uint32' },		-- 赎回id
    }, 88915416
)

-- @@物品合成
base.reg( 'PQItemMerge', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 物品合成的ID
        { 'count', 'uint32' },		-- 数量
    }, 319800917
)

base.reg( 'PRItemMerge', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 物品合成的ID
        { 'count', 'uint32' },		-- 数量
    }, 1847045381
)

-- @@装备穿戴
base.reg( 'PQItemEquip', 'SMsgHead',
    {
        { 'src', 'S2UInt32' },		-- 装备物品[first:bag_index, second:item_guid]
    }, 708926413
)

-- @@装备穿戴
base.reg( 'PQItemEquipSkill', 'SMsgHead',
    {
        { 'src', 'S2UInt32' },		-- 装备物品[first:bag_index, second:item_guid]
        { 'soldier_guid', 'uint32' },		-- 武将guid
    }, 103471093
)

base.reg( 'PRItemEquipSkill', 'SMsgHead',
    {
        { 'result', 'uint32' },		-- 结果
    }, 1691421581
)

-- @@装备使用 
base.reg( 'PQItemUse', 'SMsgHead',
    {
        { 'item', 'S2UInt32' },		-- 装备物品[first:bag_index, second:item_guid]
        { 'count', 'uint32' },		-- 数量
        { 'index', 'uint32' },		-- 指定index
    }, 1004860592
)

base.reg( 'PRItemUse', 'SMsgHead',
    {
        { 'item_id', 'uint32' },		-- 物品id    
        { 'count', 'uint32' },		-- 数量
    }, 1222770932
)


