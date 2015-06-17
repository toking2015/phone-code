local const = trans.const
local err = trans.err
local base = trans.base

const.kSoldierTypeCommon		= 1		-- 普通
const.kSoldierTypeYesterday		= 2		-- jjc昨天
const.kSoldierTypeTombSelf		= 3		-- 墓地自己
const.kSoldierTypeTombTarget		= 4		-- 墓地别人
const.kPathSoldierQualityUp		= 1768905208		-- 武将品质升级
const.kPathSoldierLvUp		= 1029450723		-- 武将等级升级
const.kPathSoldierStarUp		= 1854145592		-- 武将星级升级
const.kPathSoldierAdd		= 1147998484		-- 武将添加
const.kPathSoldierDel		= 616304367		-- 武将删除
const.kPathSoldierMove		= 1631393222		-- 武将移动
const.kPathSoldierRecruit		= 1266828872		-- 武将招募
const.kPathSoldierEquip		= 382737524		-- 武将装备
const.kPathSoldierSkillReset		= 1272384774		-- 武将技能重置
const.kPathSoldierSkillLvUp		= 1043530847		-- 武将技能升级
const.kPathSoldierQualityXpAdd		= 534240037		-- 武将品质经验添加
const.kPathSoldierEquipSkill		= 257383971		-- 武将装备技能书
const.kSoldierSkillMax		= 4		-- 技能数量
const.kSoldierOccuPaladin		= 1		-- 圣骑士
const.kSoldierOccuDeathKnight		= 2		-- 死亡骑士
const.kSoldierOccuWorrier		= 3		-- 战士
const.kSoldierOccuHunter		= 4		-- 猎人
const.kSoldierOccuShaman		= 5		-- 萨满
const.kSoldierOccuDruid		= 6		-- 德鲁伊
const.kSoldierOccuRogue		= 7		-- 潜行者
const.kSoldierOccuMonk		= 8		-- 武僧
const.kSoldierOccuMage		= 9		-- 法师
const.kSoldierOccuWarlock		= 10		-- 术士
const.kSoldierOccuPriest		= 11		-- 牧师
const.kSoldierQualityInitLv		= 1		-- 初始化品质

err.kErrSoldierGuidNotExist		= 903005699		--武将guid不存在
err.kErrSoldierDataNotExist		= 1086935047		--武将id不存在
err.kErrSoldierQualityNotExist		= 411098803		--武将品质不存在或者已经升级到最大值
err.kErrSoldierQualityLvLimit		= 901151154		--武将等级限制
err.kErrSoldierLvNotExist		= 2107585344		--武将等级数据不存在或者已经升级到最大值
err.kErrSoldierStarNotExist		= 759754821		--武将星级数据不存在或者已经升级到最大值
err.kErrSoldierHave		= 1430609125		--武将已经存在
err.kErrSoldierTeamLevel		= 777163145		--武将不能超过战队等级
err.kErrSoldierQualityLevel		= 365779413		--武将等级 品质不够
err.kErrSoldierEquipHave		= 1036776371		--武将已经装备这件装备
err.kErrSoldierEquipMismatch		= 1959484393		--武将装备不匹配
err.kErrSoldierNoSkillPoint		= 307615193		--无技能点可用
err.kErrSoldierSkillLvLimit		= 1923412656		--技能等级不能超过英雄等级
err.kErrSoldierQualityXpCoinNoExist		= 785050053		--升级需要的材料不存在
err.kErrSoldierQualityXpCoinWrong		= 1906325959		--升级需要的材料错误
err.kErrSoldierLvNotXp		= 1899931062		--经验不够
err.kErrSoldierQualityXpNotEqual		= 2135125154		--经验不匹配
err.kErrSoldierQualityXpLimit		= 2072921884		--经验满级了

-- 武将-技能等级
base.reg( 'SSoldierSkill', nil,
    {
        { 'id', 'uint32' },		-- 技能id
        { 'level', 'uint32' },		-- 技能等级
    }
)

-- 武将-印佳
base.reg( 'SUserSoldier', nil,
    {
        { 'guid', 'uint32' },		-- 惟一标识
        { 'soldier_id', 'uint32' },		-- 武将ID
        { 'soldier_type', 'uint32' },		-- 武将类型
        { 'soldier_index', 'uint16' },		-- 索引
        { 'level', 'uint16' },		-- 等级
        { 'xp', 'uint32' },		-- XP
        { 'quality', 'uint16' },		-- 品质
        { 'quality_lv', 'uint32' },		-- 不再使用
        { 'quality_xp', 'uint32' },		-- 品质经验
        { 'star', 'uint16' },		-- 星级
        { 'hp', 'uint32' },		-- HP
        { 'mp', 'uint32' },		-- MP
        { 'skill_list', { 'array', 'SSoldierSkill' } },		-- 技能LIST
    }
)

-- @@请求武将列表
base.reg( 'PQSoldierList', 'SMsgHead',
    {
        { 'soldier_type', 'uint32' },		-- 武将类型 kSoldierTypeCommon:1
    }, 961013796
)

-- 返回武将列表
base.reg( 'PRSoldierList', 'SMsgHead',
    {
        { 'soldier_type', 'uint32' },		-- 武将类型
        { 'soldier_map', { 'indices', 'SUserSoldier' } },		-- 武将列表
    }, 1666924443
)

-- @@添加武将
base.reg( 'PQSoldierAdd', 'SMsgHead',
    {
        { 'soldier_id', 'uint16' },		-- 武将id
    }, 717748738
)

-- 返回武将
base.reg( 'PRSoldierSet', 'SMsgHead',
    {
        { 'set_type', 'uint32' },		-- set_type
        { 'set_path', 'uint32' },		-- set_path
        { 'soldier', 'SUserSoldier' },		-- 武将
    }, 1949745294
)

-- @@删除武将
base.reg( 'PQSoldierDel', 'SMsgHead',
    {
        { 'soldier_type', 'uint32' },		-- 武将类型
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
    }, 1026501369
)

-- @@移动武将
base.reg( 'PQSoldierMove', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
        { 'index', 'S2UInt32' },		-- 位置 first:武将背包类型 second:位置
    }, 61793682
)

-- @@品质增加经验
base.reg( 'PQSoldierQualityAddXp', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
        { 'coin_list', { 'array', 'S3UInt32' } },		-- 消耗的物品
    }, 374239288
)

-- @@品质升级
base.reg( 'PQSoldierQualityUp', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
    }, 878179539
)

-- @@等级升级
base.reg( 'PQSoldierLvUp', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
    }, 915576268
)

-- @@星级升级
base.reg( 'PQSoldierStarUp', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
    }, 212308155
)

-- @@武将招募
base.reg( 'PQSoldierRecruit', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 招募ID
    }, 47531286
)

base.reg( 'PRSoldierRecruit', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 招募ID
    }, 1678160619
)

-- @@装备穿戴
base.reg( 'PQSoldierEquip', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
        { 'item', 'S2UInt32' },		-- 物品
    }, 949928079
)

-- @@洗点
base.reg( 'PQSoldierSkillReset', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
    }, 56411694
)

-- @@技能升级
base.reg( 'PQSoldierSkillLvUp', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
        { 'skill_id', 'uint32' },		-- 需要升级的技能
    }, 9167997
)

-- @@请求武将装备二级属性
base.reg( 'PQSoldierEquipExt', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
    }, 76490040
)

base.reg( 'PRSoldierEquipExt', 'SMsgHead',
    {
        { 'soldier', 'S2UInt32' },		-- 武将 first:武将背包类型 second:武将guid
        { 'able', 'SFightExtAble' },		-- 装备二级属性
    }, 1961337467
)


