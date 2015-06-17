local const = trans.const
local err = trans.err
local base = trans.base

const.kTotemTypeDaDi		= 1		-- 大地
const.kTotemTypeHuoYan		= 2		-- 火焰
const.kTotemTypeShuiLiu		= 3		-- 水流
const.kTotemTypeKongQi		= 4		-- 空气
const.kTotemSkillTypeSpeed		= 1		--  速度
const.kTotemSkillTypeFormationAdd		= 2		--  阵法加成 
const.kTotemSkillTypeWake		= 3		--  觉醒
const.kTotemFormationAddPosition		= 1		--  阵法加成，按位置加成
const.kTotemFormationAddType		= 2		--  阵法加成，按类型加成
const.kTotemFormationAddTypeFrontRow		= 1		--  加成图腾所在列的前排英雄
const.kTotemFormationAddTypeBackRow		= 2		--  加成图腾所在列的后排英雄
const.kTotemFormationAddTypeColumn		= 3		--  加成图腾所在列的一列英雄
const.kTotemFormationAddTypeTotem		= 4		--  加成图腾自身
const.kTotemEmbedGlyphMaxCount		= 4		--  图腾最多镶嵌的雕文数量
const.kTotemPacketNormal		= 0		--  普通图腾背包
const.kTotemPacketYesterday		= 1		--  昨天的图腾，用于大墓地
const.kPathTotemUserInit		= 556093447		--  用户创建时赠送
const.kPathTotemTrain		= 532779750		--  图腾培养
const.kPathTotemAccelerate		= 1679177212		--  图腾加速
const.kPathTotemGlyphMerge		= 818430494		--  图腾雕文合成
const.kPathTotemGlyphEmbed		= 345869345		--  图腾雕文镶嵌
const.kPathTotemActivate		= 696632415		--  图腾激活

err.kErrUnkownTotem		= 803178191		-- 未知图腾
err.kErrTotemAlreadyExist		= 2135017583		-- 已存在该图腾
err.kErrTotemNoExist		= 1988007228		-- 不存在该图腾
err.kErrTotemDuringEnergy		= 366864623		-- 已有同系别图腾正在充能

--  图腾
base.reg( 'STotem', nil,
    {
        { 'guid', 'uint32' },		--  guid
        { 'id', 'uint32' },		--  图腾id
        { 'level', 'uint32' },		--  图腾等级
        { 'speed_lv', 'uint32' },		--  速度等级
        { 'formation_add_lv', 'uint32' },		--  阵法加成等级
        { 'wake_lv', 'uint32' },		--  觉醒等级
        { 'energy_time', 'uint32' },		--  充能时间
        { 'accelerate_count', 'uint32' },		--  加速次数
    }
)

--  图腾雕文
base.reg( 'STotemGlyph', nil,
    {
        { 'guid', 'uint32' },		--  guid
        { 'id', 'uint32' },		--  图腾雕文id
        { 'totem_guid', 'uint32' },		--  如果镶嵌，对应图腾的guid
        { 'attr_list', { 'array', 'S2UInt32' } },		--  属性
        { 'hide_attr_list', { 'array', 'S2UInt32' } },		--  隐藏属性
    }
)

base.reg( 'STotemInfo', nil,
    {
        { 'totem_list', { 'array', 'STotem' } },		--  图腾列表
        { 'glyph_list', { 'array', 'STotemGlyph' } },		--  雕文列表，即雕文背包
    }
)

--  图腾信息
base.reg( 'PQTotemInfo', 'SMsgHead',
    {
    }, 414732507
)

base.reg( 'PRTotemInfo', 'SMsgHead',
    {
        { 'info', 'STotemInfo' },
    }, 2008807582
)

--  图腾激活
base.reg( 'PQTotemActivate', 'SMsgHead',
    {
        { 'totem_id', 'uint32' },		--  需要激活的图腾id
    }, 936233025
)

base.reg( 'PRTotemActivate', 'SMsgHead',
    {
        { 'is_success', 'uint32' },
        { 'totem_id', 'uint32' },
    }, 1522640888
)

--  技能祝福
base.reg( 'PQTotemBless', 'SMsgHead',
    {
        { 'totem_guid', 'uint32' },
        { 'skill_type', 'uint32' },		--  kTotemSkillTypeXXX
    }, 402450518
)

base.reg( 'PRTotemBless', 'SMsgHead',
    {
        { 'totem', 'STotem' },
    }, 1929801727
)

--  充能
base.reg( 'PQTotemAddEnergy', 'SMsgHead',
    {
        { 'totem_guid', 'uint32' },
    }, 624722301
)

base.reg( 'PRTotemAddEnergy', 'SMsgHead',
    {
        { 'totem', 'STotem' },
    }, 1996672069
)

--  充能加速
base.reg( 'PQTotemAccelerate', 'SMsgHead',
    {
        { 'totem_guid', 'uint32' },
        { 'is_free', 'uint32' },		--  0-花钱，1-免费
    }, 261979214
)

base.reg( 'PRTotemAccelerate', 'SMsgHead',
    {
        { 'totem', 'STotem' },
    }, 1616213530
)

--  雕文合成
base.reg( 'PQTotemGlyphMerge', 'SMsgHead',
    {
        { 'guids', 'S2UInt32' },		--  需要合成的两个雕文guid
    }, 763950635
)

base.reg( 'PRTotemGlyphMerge', 'SMsgHead',
    {
        { 'is_success', 'uint32' },		--  非0表示成功
        { 'deleted_guid', 'uint32' },		--  删除的雕文guid
        { 'result_glyph', 'STotemGlyph' },		--  剩下的雕文
    }, 1411759523
)

--  雕文镶嵌
base.reg( 'PQTotemGlyphEmbed', 'SMsgHead',
    {
        { 'glyph_guid', 'uint32' },		--  雕文guid
        { 'totem_guid', 'uint32' },		--  图腾guid
    }, 476898429
)

base.reg( 'PRTotemGlyphEmbed', 'SMsgHead',
    {
        { 'glyph_guid', 'uint32' },		--  雕文guid, 来自PQTotemGlyphEmbed
        { 'totem_guid', 'uint32' },		--  图腾guid, 来自PQTotemGlyphEmbed
        { 'is_new', 'uint32' },		--  将glyph_guid的雕文的totem_guid设置为totem_guid, 如果非新增，删除deleted_guid的雕文
        { 'deleted_guid', 'uint32' },		--  删除的雕文guid
    }, 1323933723
)


