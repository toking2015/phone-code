local const = trans.const
local err = trans.err
local base = trans.base


err.kErrAccessSockOpen		= 610073348		--连接已打开
err.kErrAccessSockClose		= 1989318792		--连接已关闭

-- =========================通迅协议============================
base.reg( 'PQAccessEvent', 'SMsgHead',
    {
        { 'sock', 'int32' },
        { 'code', 'uint32' },
    }, 1001173331
)

-- 请求广播频道列表
base.reg( 'PQAccessBroadCastList', 'SMsgHead',
    {
    }, 102430714
)

base.reg( 'PRAccessBroadCasetList', 'SMsgHead',
    {
        { 'channel_list', { 'array', 'uint32' } },
    }, 1700262094
)

-- @@设置频道监听
base.reg( 'PQAccessBroadCastSet', 'SMsgHead',
    {
        { 'channel', 'uint32' },
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectDel
    }, 195628525
)


