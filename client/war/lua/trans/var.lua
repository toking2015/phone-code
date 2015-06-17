local const = trans.const
local err = trans.err
local base = trans.base

const.kVarFlagClientModifity		= 1		-- 允许客户端修改


-- =========================数据结构============================
base.reg( 'SUserVar', nil,
    {
        { 'value', 'uint32' },		-- 变量值
        { 'timelimit', 'uint32' },		-- 有效期( 结束时间截, 0 为永远有效 )
    }
)

-- @@请求变量列表
base.reg( 'PQVarMap', 'SMsgHead',
    {
    }, 308805923
)

base.reg( 'PRVarMap', 'SMsgHead',
    {
        { 'var_map', { 'map', 'SUserVar' } },
    }, 1399214952
)

-- @@请求变量修改
base.reg( 'PQVarSet', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- constant.[ kObjectDel or kObjectUpdate ]
        { 'var_key', 'string' },
        { 'var_value', 'uint32' },
        { 'timelimit', 'uint32' },		-- 有效期
    }, 280247880
)

base.reg( 'PRVarSet', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- constant.[ kObjectDel or kObjectUpdate ]
        { 'var_key', 'string' },
        { 'var_value', 'uint32' },
        { 'timelimit', 'uint32' },		-- 有效期
    }, 1608044845
)


