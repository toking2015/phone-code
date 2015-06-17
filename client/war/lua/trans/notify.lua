local const = trans.const
local err = trans.err
local base = trans.base



-- 货币修改通知( 仅通知, 数据修改在其它模板协议返回 )
base.reg( 'PRNotifyCoin', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectDel
        { 'path', 'uint32' },		-- kPathXXX
        { 'coins', { 'array', 'S3UInt32' } },		-- { cate = kCoinTypeXXX, objid = 扩展id( 可能物品需要 ), val = 操作数 }
    }, 1746730510
)


