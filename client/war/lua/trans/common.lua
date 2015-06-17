local const = trans.const
local err = trans.err
local base = trans.base



-- 协议包头
base.reg( 'SMsgHead', nil,
    {
        { 'msg_cmd', 'uint32' },		-- 协议号
        { 'role_id', 'uint32' },		-- 角色ID
        { 'session', 'uint32' },		-- 登陆游戏sessionid
        { 'order', 'uint32' },		-- 协议包处理顺序
        { 'action', 'uint32' },		-- 用户行为号
        { 'broad_cast', 'uint16' },		-- 广播id
        { 'broad_type', 'uint16' },		-- 广播二级标识
        { 'broad_id', 'uint32' },		-- 广播三级标识
    }
)

-- 压缩数据
base.reg( 'SCompressData', nil,
    {
        { 'size', 'uint32' },		-- 原文长度
        { 'data', 'bytes' },		-- 压缩内容
    }
)

base.reg( 'SInteger', nil,
    {
        { 'value', 'uint32' },
    }
)

base.reg( 'S2UInt16', nil,
    {
        { 'first', 'uint16' },
        { 'second', 'uint16' },
    }
)

base.reg( 'S2Int16', nil,
    {
        { 'first', 'int16' },
        { 'second', 'int16' },
    }
)

base.reg( 'S2UInt32', nil,
    {
        { 'first', 'uint32' },
        { 'second', 'uint32' },
    }
)

base.reg( 'S2Int32', nil,
    {
        { 'first', 'int32' },
        { 'second', 'int32' },
    }
)

base.reg( 'S2Float', nil,
    {
        { 'first', 'float' },
        { 'second', 'float' },
    }
)

base.reg( 'S3UInt32', nil,
    {
        { 'cate', 'uint32' },		-- 类型
        { 'objid', 'uint32' },		-- 扩展Id
        { 'val', 'uint32' },		-- 数值
    }
)

base.reg( 'S4Int32', nil,
    {
        { 'v1', 'int32' },
        { 'v2', 'int32' },
        { 'v3', 'int32' },
        { 'v4', 'int32' },
    }
)

-- 地图结构
base.reg( 'SMapVal', nil,
    {
        { 'id', 'uint16' },		-- ID
        { 'x', 'uint8' },		-- X
        { 'y', 'uint8' },		-- Y
    }
)

base.reg( 'SKeyValue', nil,
    {
        { 'key', 'string' },
        { 'val', 'uint32' },
    }
)

base.reg( 'S2String', nil,
    {
        { 'first', 'string' },
        { 'second', 'string' },
    }
)


