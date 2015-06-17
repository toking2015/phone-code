local const = trans.const
local err = trans.err
local base = trans.base

const.kCastUni		= 0		-- 个人[ broad_id:角色Id ]
const.kCastServer		= 1		-- 全服
const.kCastCopy		= 2		-- 副本( 暂不使用 )
const.kCastGuild		= 3		-- 公会[ broad_id:工会Id ]


-- 频道标识
base.reg( 'SUserChannel', nil,
    {
        { 'broad_cast', 'uint16' },		-- kCastXXX
        { 'broad_type', 'uint16' },		-- 二级标识
        { 'broad_id', 'uint32' },		-- 三级标识
    }
)

-- 请求广播频道列表
base.reg( 'PQBroadCastList', 'SMsgHead',
    {
    }, 100870329
)

base.reg( 'PRBroadCastList', 'SMsgHead',
    {
        { 'channel_list', { 'array', 'SUserChannel' } },
    }, 1558437242
)

-- @@设置频道监听, SUserChannel 的所有成员已包含在父类协议中
base.reg( 'PQBroadCastSet', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectDel
    }, 884232017
)


