local const = trans.const
local err = trans.err
local base = trans.base

const.kMaterialCollectMaxTime		= 30		-- 资源点最大可采集次数
const.kMaterialRefreshInterval		= 300		-- 资源点增加次数时间间隔
const.kPathPaperSkillLevelUp		= 458509659		-- 升级手工技能
const.kPathPaperSkillForget		= 30404056		-- 遗忘手工技能
const.kPathPaperCreate		= 1326081307		-- 制造装备图纸
const.kPathCopyCollect		= 2979731		-- 副本原料采集
const.kPathActiveScoreReset		= 458473657		-- 清零活跃值上限

err.kErrPaperWrongSkillType		= 2128884591		--未学习对应的手工技能
err.kErrPaperCreateLevelLimit		= 2073047348		--手工技能等级不足
err.kErrPaperCollectTimeLimit		= 1973576321		--原料采集技能次数不足

-- 副本原料
base.reg( 'SUserCopyMaterial', nil,
    {
        { 'collect_level', 'uint32' },		-- 资源点等级
        { 'left_collect_times', 'uint32' },		-- 剩余可采集次数
        { 'del_timestamp', 'uint32' },		-- 满次数时的采集时间戳
    }
)

-- @@升级手工技能
base.reg( 'PQPaperLevelUp', 'SMsgHead',
    {
        { 'skill_type', 'uint32' },		-- 技能类型（仅用于第一次学习）
    }, 1036717831
)

-- @@遗忘
base.reg( 'PQPaperForget', 'SMsgHead',
    {
    }, 125886294
)

-- @@制作图纸
base.reg( 'PQPaperCreate', 'SMsgHead',
    {
        { 'paper_id', 'uint32' },		-- 图纸id
    }, 795415437
)

base.reg( 'PRPaperCreate', 'SMsgHead',
    {
        { 'paper_id', 'uint32' },		-- 图纸id
    }, 1861819907
)

-- @@采集
base.reg( 'PQPaperCollect', 'SMsgHead',
    {
        { 'collect_level', 'uint32' },		-- 资源点等级
    }, 893714413
)

-- 资源点更新
base.reg( 'PRPaperCopyMaterialPoint', 'SMsgHead',
    {
        { 'info', 'SUserCopyMaterial' },		-- 采集数据
    }, 1793480676
)

-- 采集成功
base.reg( 'PRPaperCollect', 'SMsgHead',
    {
        { 'item_id', 'uint32' },
        { 'num', 'uint32' },
    }, 1843830073
)

-- 资源点列表更新
base.reg( 'PRPaperCopyMaterial', 'SMsgHead',
    {
        { 'material_list', { 'array', 'SUserCopyMaterial' } },
    }, 1531515678
)


