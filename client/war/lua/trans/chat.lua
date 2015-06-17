local const = trans.const
local err = trans.err
local base = trans.base

const.kPathGameMasterCommand		= 25800757

err.kErrChatSoundNotExist		= 82271493		--语音已失效

-- @@请求发送, 发送类型与对象参考 broadcast 模块相关说明
base.reg( 'PQChatContent', 'SMsgHead',
    {
        { 'avater', 'uint32' },		-- 角色头像
        { 'text', 'string' },		-- 文本内容
        { 'text_ext', 'string' },		-- 文本扩展
        { 'sound_data', 'bytes' },		-- 语音数据
        { 'sound_length', 'uint32' },		-- 语音长度(ms)
        { 'sound_index', 'uint32' },		-- 语音索引, 由客户端构造(自增值在登录时由客户端随机初始化0~65535)
    }, 1012322907
)

base.reg( 'PRChatContent', 'SMsgHead',
    {
        { 'name', 'string' },		-- 角色名
        { 'level', 'uint32' },		-- 等级
        { 'avater', 'uint32' },		-- 角色头像
        { 'text', 'string' },
        { 'text_ext', 'string' },		-- 文本扩展
        { 'sound_length', 'uint32' },		-- 语音长度(ms)
        { 'sound_index', 'uint32' },		-- 语音索引, 由客户端构造(自增值在登录时由客户端随机初始化0~65535)
    }, 2089793380
)

-- @@请求语音播放
base.reg( 'PQChatSound', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 请求用户角色id
        { 'sound_index', 'uint32' },		-- 请求语音数据
    }, 810765027
)

base.reg( 'PRChatSound', 'SMsgHead',
    {
        { 'result', 'uint32' },		-- 0为正常, 非0 为错误码
        { 'target_id', 'uint32' },
        { 'sound_index', 'uint32' },		-- 请求语音数据
        { 'sound_data', 'bytes' },		-- 语音内容
    }, 1516629421
)

base.reg( 'PQChatBan', 'SMsgHead',
    {
        { 'end_time', 'uint32' },		-- 结束时间
    }, 511928501
)

-- 图腾
base.reg( 'PQChatGetTotem', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'totem_guid', 'uint32' },
    }, 490478920
)

base.reg( 'PRChatGetTotem', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'totem_data', 'STotem' },
    }, 1814824376
)

-- 英雄
base.reg( 'PQChatGetSoldier', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'soldier_guid', 'uint32' },
    }, 557377059
)

base.reg( 'PRChatGetSoldier', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'soldier_data', 'SUserSoldier' },
        { 'ext_able', 'SFightExtAble' },
    }, 1530883110
)

-- 装备
base.reg( 'PQChatGetEquip', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'equip_type', 'uint32' },
        { 'equip_level', 'uint32' },
    }, 839851394
)

base.reg( 'PRChatGetEquip', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'equip_type', 'uint32' },
        { 'equip_level', 'uint32' },
        { 'item_list', { 'array', 'SUserItem' } },
    }, 1265884710
)


