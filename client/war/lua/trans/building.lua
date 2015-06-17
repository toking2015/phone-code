local const = trans.const
local err = trans.err
local base = trans.base

const.kPathBuildingLeveUp		= 459958712		-- 建筑升级，建筑强行产出最大值
const.kPathBuildingGetOutput		= 1331875543		-- 领取建筑的产出
const.kPathBuildingSpeedOutput		= 873661828		-- 建筑加速产出
const.kBuildingTypeMajor		= 1		-- 主城
const.kBuildingTypeGoldField		= 2		-- 金矿
const.kBuildingTypeGoldBank		= 3		-- 金库
const.kBuildingTypeWoodField		= 4		-- 伐木厂
const.kBuildingTypeWoodBank		= 5		-- 木材仓库
const.kBuildingTypeWaterFactory		= 6		-- 大阳井
const.kBuildingTypeAspersorium		= 7		-- 圣水瓶
const.kBuildingTypeCampsite		= 8		-- 营地
const.kBuildingTypeTrainingGround		= 9		-- 训练营
const.kBuildingTypeShipField		= 10		-- 船坞
const.kBuildingTypeTavern		= 11		-- 酒馆
const.kBuildingTypePalace		= 12		-- 神殿
const.kBuildingTypeTechnology		= 13		-- 科技馆
const.kBuildingTypeToweringOldTrees		= 14		-- 天赋树
const.kBuildingTypeBlacksimith		= 15		-- 铁匠铺
const.kBuildingTypeAlter		= 16		-- 祭坛
const.kBuildingTypeLegion		= 17		-- 公会基地
const.kBuildingTypeDecorate		= 18		-- 装饰建筑
const.kBuildingTypeJumping		= 19		-- 传送门
const.kBuildingTypeSingleArena		= 20		-- 竞技场
const.kBuildingTypePVPBattle		= 21		-- 冰封王座
const.kBuildingTypePVEBattle		= 22		-- 大墓地
const.kBuildingTypeCopyOne		= 23		-- 哀嚎洞穴
const.kBuildingTypeCopyFive		= 24		-- 死亡矿井
const.kBuildingTypeCopyTen		= 25		-- 影牙城堡
const.kBuildingTypeCopyFifteen		= 26		-- 剃刀沼泽
const.kBuildingTypeCopyTwenty		= 27		-- 诺莫瑞根
const.kBuildingTypeCopyTwentyFive		= 28		-- 血色修道院

err.kErrBuildingGuidNotExist		= 1440276505		--建筑物不存在
err.kErrBuildingDataNotExist		= 470176097		--建筑类型不存在
err.kErrBuildingCountNotMax		= 705846841		--此类建筑数量已达到最大上限
err.kErrBuildingUpgrateNotMaterial		= 1021527684		--升级所需材料不够
err.kErrBuildingUpgrateNotLevel		= 1922807980		--当前建筑已达到最高级别
err.kErrBuildingSpeedError		= 44330487		--加速失败

-- 建筑基础信息
base.reg( 'SBuildingBase', nil,
    {
        { 'target_id', 'uint32' },		-- 拥有者id ( role_id )
        { 'info_id', 'uint32' },		-- 建筑id（ 同类型建筑,info_id 唯一）
        { 'info_type', 'uint8' },		-- 建筑类型
        { 'info_level', 'uint16' },		-- 建筑当前等级
        { 'info_position', 'S2UInt32' },		-- 建筑中心点位置
    }
)

base.reg( 'SBuildingExt', nil,
    {
        { 'production', 'uint32' },		-- 产出, 库存， 上限
        { 'time_point', 'uint32' },		-- 时间点，如金库：上次产出的时间点
    }
)

base.reg( 'SUserBuilding', nil,
    {
        { 'building_type', 'uint8' },		-- 建筑类型<等同data.info_type>
        { 'building_guid', 'uint32' },		-- 建筑id<等同data.info_id>
        { 'data', 'SBuildingBase' },
        { 'ext', 'SBuildingExt' },
    }
)

-- ## 获取建筑列表
base.reg( 'PQBuildingList', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 目标id ( role_id )
    }, 600622277
)

-- ## 激活建筑
base.reg( 'PQBuildingAdd', 'SMsgHead',
    {
        { 'building_type', 'uint8' },		-- 建筑类型
        { 'building_position', 'S2UInt32' },		-- 中心点
    }, 462722994
)

-- ## 升级建筑
base.reg( 'PQBuildingUpgrade', 'SMsgHead',
    {
        { 'building_type', 'uint8' },		-- 建筑类型
        { 'building_id', 'uint32' },		-- 建筑id       
    }, 600117215
)

-- ## 移动建筑
base.reg( 'PQBuildingMove', 'SMsgHead',
    {
        { 'building_type', 'uint8' },		-- 建筑类型
        { 'building_id', 'uint32' },		-- 建筑id       
        { 'building_position', 'S2UInt32' },		-- 中心点
    }, 346561621
)

-- ## 查询建筑
base.reg( 'PQBuildingQuery', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 目标id ( role_id )
        { 'building_type', 'uint8' },		-- 建筑类型
        { 'building_id', 'uint32' },		-- 建筑id
    }, 989836134
)

base.reg( 'PQBuildingGetOutput', 'SMsgHead',
    {
        { 'building_type', 'uint32' },		-- 建筑类型
    }, 493876112
)

base.reg( 'PQBuildingSpeedOutput', 'SMsgHead',
    {
        { 'building_type', 'uint32' },		-- 建筑类型
        { 'times', 'uint32' },		-- 加速次速 1 10
    }, 549718019
)

-- @@ 返回建筑列表
base.reg( 'PRBuildingList', 'SMsgHead',
    {
        { 'list', { 'array', 'SUserBuilding' } },		-- 建筑群
    }, 1774802370
)

-- @@
base.reg( 'PRBuildingSet', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectUpdate, kObjectDel
        { 'building', 'SUserBuilding' },
    }, 1484773370
)

-- @@
base.reg( 'PRBuildingQuery', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 目标id( role_id)
        { 'data', 'SUserBuilding' },		-- 请求的数据
    }, 1318423735
)

base.reg( 'PRBuildingSpeedOutput', 'SMsgHead',
    {
        { 'building_type', 'uint32' },		-- 建筑类型
        { 'list_crit_times', { 'array', 'uint32' } },		-- 暴击列表 
        { 'add_value', 'uint32' },		-- 加速得到的产出
    }, 1539609863
)


