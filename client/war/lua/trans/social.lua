local const = trans.const
local err = trans.err
local base = trans.base



-- =========================数据中心============================
base.reg( 'SSocialRole', nil,
    {
        { 'role_id', 'uint32' },
        { 'level', 'uint32' },
        { 'name', 'string' },
    }
)

base.reg( 'CSocial', nil,
    {
        { 'initialized', 'uint32' },		-- 数据初始化标识, kTrue, kFlase
        { 'server_socket', { 'indices', 'uint32' } },
        { 'socket_server', { 'indices', 'uint32' } },
        { 'last_recv_time', 'uint32' },		-- 最后数据接收时间( gamesvr 用 )
        { 'user_map', { 'indices', 'SSocialRole' } },
    }
)

-- Ping包
base.reg( 'PQSocialServerPing', 'SMsgHead',
    {
    }, 513725054
)

base.reg( 'PRSocialServerPing', 'SMsgHead',
    {
    }, 1770462687
)

-- 角色列表请求
base.reg( 'PQSocialServerRoleList', 'SMsgHead',
    {
    }, 30914989
)

base.reg( 'PRSocialServerRoleList', 'SMsgHead',
    {
        { 'list', { 'array', 'SSocialRole' } },
    }, 1129914150
)

-- 服务器标识绑定
base.reg( 'PQSocialServerBind', 'SMsgHead',
    {
        { 'sid', 'uint32' },		-- 服务器标识号
    }, 941776562
)

-- 角色信息
base.reg( 'PQSocialServerRole', 'SMsgHead',
    {
        { 'role', 'SSocialRole' },
    }, 283687696
)


