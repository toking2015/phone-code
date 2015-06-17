local const = trans.const
local err = trans.err
local base = trans.base

const.kPathTeamLevelUp		= 308776875		-- 战队等级升级
const.kPathChangeName		= 1924174318		-- 修改名字
const.kPathChangeAvatar		= 84965152		-- 修改头像

err.kErrTeamNameHave		= 1579822034		--该名字已经被占用
err.kErrTeamNameLong		= 1145027880		--名字太长
err.kErrTeamNameInvalid		= 1747010135		--名字中有不合法的字符
err.kErrTeamAvatarNoExist		= 449384382		--头像不存在

-- ==========================通迅结构==========================
base.reg( 'STeamInfo', nil,
    {
        { 'can_change_name', 'uint32' },		-- 是否可以改名
        { 'change_name_count', 'uint32' },		-- 改名的次数
    }
)

-- @@请求升级
base.reg( 'PQTeamLevelUp', 'SMsgHead',
    {
    }, 239622908
)

base.reg( 'PRTeamLevelUp', 'SMsgHead',
    {
        { 'old_strength', 'uint16' },		-- 旧体力
        { 'old_level', 'uint16' },		-- 旧等级
        { 'new_level', 'uint16' },		-- 新等级
    }, 1901312684
)

base.reg( 'PQTeamChangeName', 'SMsgHead',
    {
        { 'name', 'string' },		-- 修改的名字
    }, 57344587
)

base.reg( 'PRTeamChangeName', 'SMsgHead',
    {
        { 'name', 'string' },		-- 修改OK的名字
    }, 1105012732
)

base.reg( 'PQTeamChangeAvatar', 'SMsgHead',
    {
        { 'avatar', 'uint32' },		-- 头像id
    }, 374520175
)


