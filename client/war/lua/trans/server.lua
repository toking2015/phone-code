local const = trans.const
local err = trans.err
local base = trans.base



-- ============================数据中心========================
base.reg( 'CServer', nil,
    {
        { 'server_ids', { 'array', 'uint32' } },		-- 服务器id列表( 合服后有效 )
        { 'key_value', { 'map', 'string' } },		-- 服务器系统变量
    }
)

-- 打开服务
base.reg( 'PRServerOpen', 'SMsgHead',
    {
    }, 1555277531
)

-- 关闭服务
base.reg( 'PRServerClose', 'SMsgHead',
    {
    }, 1985312526
)

-- 名称列表处理
base.reg( 'PQServerNameList', 'SMsgHead',
    {
    }, 328709501
)

base.reg( 'PRServerNameList', 'SMsgHead',
    {
        { 'user_name_id', { 'map', 'uint32' } },
        { 'guild_name_id', { 'map', 'uint32' } },
    }, 1696743470
)

-- 服务器变量修改通知
base.reg( 'PQServerNotify', 'SMsgHead',
    {
        { 'key', 'string' },
        { 'value', 'string' },
    }, 311682074
)

-- 服务器变量列表处理
base.reg( 'PQServerInfoList', 'SMsgHead',
    {
    }, 993184889
)

base.reg( 'PRServerInfoList', 'SMsgHead',
    {
        { 'key_value', { 'map', 'string' } },
    }, 1430484165
)

base.reg( 'PQServerFriendList', 'SMsgHead',
    {
        { 'level', 'uint32' },		-- team_level >= level的数据全要
    }, 1011284555
)

base.reg( 'PRServerFriendList', 'SMsgHead',
    {
        { 'user_id_friend', { 'indices', 'SFriendData' } },
    }, 1624405534
)


