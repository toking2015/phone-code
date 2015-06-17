local const = trans.const
local err = trans.err
local base = trans.base

const.kPathEquipReplace		= 983812305		-- 装备替换
const.kPathEquipSelect		= 1


-- =========================常量声明=======================
base.reg( 'SUserEquipGrade', nil,
    {
        { 'equip_type', 'uint32' },
        { 'level', 'uint32' },
        { 'grade', 'uint32' },
    }
)

-- @@合成
base.reg( 'PQEquipMerge', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 物品合成的ID
    }, 499293600
)

base.reg( 'PREquipMerge', 'SMsgHead',
    {
        { 'item', 'SUserItem' },
    }, 1112608984
)

-- @@装备替换
base.reg( 'PQEquipReplace', 'SMsgHead',
    {
        { 'is_replace', 'int8' },		-- [0:保留,1:替换]
        { 'equip_guid', 'uint32' },		-- 新装备的guid
    }, 109236104
)

base.reg( 'PREquipReplace', 'SMsgHead',
    {
        { 'is_replace', 'int8' },		-- [0:保留,1:替换]
    }, 1478196340
)

-- @@选择套装生效等级
base.reg( 'PQEquipSelectSuit', 'SMsgHead',
    {
        { 'equip_type', 'uint32' },		-- 装备[甲]类型 
        { 'select_level', 'uint32' },		-- 选择的等级[EquipSuit.xls的level]
    }, 479388940
)

-- 套装选择列表更新
base.reg( 'PREquipSelectSuits', 'SMsgHead',
    {
        { 'select_suits', { 'array', 'uint32' } },
    }, 1083849332
)


