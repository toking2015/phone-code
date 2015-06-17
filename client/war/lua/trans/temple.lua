local const = trans.const
local err = trans.err
local base = trans.base

const.kTempleHoleMaxCount		= 8		--  最大神符格数量
const.kTempleScoreSoldierCollect		= 1		--  英雄收集
const.kTempleScoreSoldierLevelUp		= 2		--  英雄升级
const.kTempleScoreSoldierQuality		= 3		--  英雄进阶
const.kTempleScoreSoldierStar		= 4		--  英雄升星
const.kTempleScoreTotemCollect		= 5		--  图腾收集
const.kTempleScoreTotemLevelUp		= 6		--  图腾升星
const.kTempleScoreTotemSkillLevelUp		= 7		--  图腾升级
const.kTempleScoreGroupCollect		= 8		--  组合收集
const.kTempleScoreGroupLevelUp		= 9		--  组合升级
const.kPathTemple		= 626346520		--  神殿
const.kPathTempleScoreReward		= 486298842		--  积分奖励
const.kPathTempleOpenHole		= 563037377		--  开孔 
const.kPathTempleGroupLevelUp		= 83421914		--  组合升级 
const.kPathTempleEmbedGlyph		= 1802264557		--  镶嵌神符 
const.kPathTempleTrainGlyph		= 31278397		--  培养培养神符 
const.kPathTempleGroupAdd		= 1560376085		--  新增组合 


--  神符
base.reg( 'STempleGlyph', nil,
    {
        { 'guid', 'uint32' },		--  guid
        { 'id', 'uint32' },		--  神符id
        { 'level', 'uint32' },		--  等级
        { 'exp', 'uint32' },		--  经验
        { 'embed_type', 'uint32' },		--  如果镶嵌，非0对应镶嵌的类型
        { 'embed_index', 'uint32' },		--  如果镶嵌，对应的序号，从0开始
    }
)

--  神殿组合
base.reg( 'STempleGroup', nil,
    {
        { 'id', 'uint32' },		--  id
        { 'level', 'uint32' },		--  等级
    }
)

--  神殿信息
base.reg( 'STempleInfo', nil,
    {
        { 'hole_cloth', 'uint32' },		--  布甲神符格数量
        { 'hole_leather', 'uint32' },		--  皮甲神符格数量
        { 'hole_mail', 'uint32' },		--  锁甲神符格数量
        { 'hole_plate', 'uint32' },		--  板甲神符格数量
        { 'group_list', { 'array', 'STempleGroup' } },		--  组合列表
        { 'glyph_list', { 'array', 'STempleGlyph' } },		--  神符列表
        { 'score_taken_list', { 'array', 'uint32' } },		--  积分奖励领取列表
        { 'score_current', { 'indices', 'S2UInt32' } },		--  当前积分，key为kTempleScoreXXX，first为次数，second为积分
        { 'score_yesterday', { 'indices', 'S2UInt32' } },		--  昨日积分，key为kTempleScoreXXX，first为次数，second为积分
    }
)

--  神殿信息
base.reg( 'PQTempleInfo', 'SMsgHead',
    {
    }, 892087342
)

base.reg( 'PRTempleInfo', 'SMsgHead',
    {
        { 'info', 'STempleInfo' },
    }, 1890641118
)

--  升级组合
base.reg( 'PQTempleGroupLevelUp', 'SMsgHead',
    {
        { 'group_id', 'uint32' },		--  需要升级的组合id
    }, 452599552
)

base.reg( 'PRTempleGroupLevelUp', 'SMsgHead',
    {
        { 'group', 'STempleGroup' },
    }, 1805247991
)

--  开神符孔
base.reg( 'PQTempleOpenHole', 'SMsgHead',
    {
        { 'hole_type', 'uint32' },		--  神符类型，kEquipXXX
        { 'is_use_item', 'uint32' },		--  是否使用道具开，否则使用钻石
    }, 515062735
)

base.reg( 'PRTempleOpenHole', 'SMsgHead',
    {
    }, 2030485707
)

--  镶嵌神符
base.reg( 'PQTempleEmbedGlyph', 'SMsgHead',
    {
        { 'hole_type', 'uint32' },		--  神符类型，kEquipXXX
        { 'hole_index', 'uint32' },		--  镶嵌序号
        { 'glyph_guid', 'uint32' },		--  神符guid
    }, 312492137
)

base.reg( 'PRTempleEmbedGlyph', 'SMsgHead',
    {
    }, 1866259123
)

--  神符升级
base.reg( 'PQTempleGlyphTrain', 'SMsgHead',
    {
        { 'main_guid', 'uint32' },		--  吞噬神符guid
        { 'eated_guid', 'uint32' },		--  被吞噬神符guid
    }, 198720182
)

base.reg( 'PRTempleGlyphTrain', 'SMsgHead',
    {
        { 'old_lv', 'uint32' },
        { 'new_lv', 'uint32' },
    }, 1477567015
)

--  领取积分奖励
base.reg( 'PQTempleTakeScoreReward', 'SMsgHead',
    {
        { 'reward_id', 'uint32' },		--  奖励id
    }, 174141501
)

base.reg( 'PRTempleTakeScoreReward', 'SMsgHead',
    {
    }, 1627535597
)


