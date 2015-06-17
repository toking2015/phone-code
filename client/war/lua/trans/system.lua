local const = trans.const
local err = trans.err
local base = trans.base

const.kPathSystemAuto		= 1447752712		-- 系统处理
const.kPlacardFlagScene		= 1		-- 场景公告(跑马灯)
const.kPlacardFlagChat		= 2		-- 聊天框公告
const.kPlacardFlagMsgBox		= 4		-- 弹出框公告

err.kErrSystem		= 477806953
err.kErrSystemBusy		= 191323984		--系统繁忙
err.kErrSystemSession		= 437223085		--session错误
err.kErrSystemRemoteLogin		= 1458683342		--异地登录
err.kErrSystemUnusualError		= 572359966		--系统异常错误
err.kErrSystemResend		= 195292953		--重发请求异常

-- =========================数据中心===========================
base.reg( 'CSystem', nil,
    {
        { 'sessions', { 'indices', 'uint32' } },
    }
)

-- 测试用
base.reg( 'PQSystemTest', 'SMsgHead',
    {
    }, 62312086
)

base.reg( 'PRSystemTest', 'SMsgHead',
    {
    }, 2094876465
)

-- ping 包, 检测连接用
base.reg( 'PQSystemPing', 'SMsgHead',
    {
    }, 660488974
)

base.reg( 'PRSystemPing', 'SMsgHead',
    {
        { 'server_time', 'uint32' },		-- 服务器时间
    }, 1271524422
)

-- 客户端每10分钟发送一次, 服务器30分钟超时作为离线判断
base.reg( 'PQSystemOnline', 'SMsgHead',
    {
    }, 374822355
)

-- 客户端请求数据包重发
base.reg( 'PQSystemResend', 'SMsgHead',
    {
        { 'server_order', 'uint32' },		-- 重发起始 order
    }, 513134002
)

base.reg( 'PRSystemResend', 'SMsgHead',
    {
        { 'result', 'uint32' },
    }, 1554760060
)

-- 网络连接成功
base.reg( 'PRSystemNetConnected', 'SMsgHead',
    {
    }, 1761556093
)

-- 网络连接断开
base.reg( 'PRSystemNetDisconnected', 'SMsgHead',
    {
    }, 1462459954
)

-- 测试有效连接( 用于网络重连后检查 )
base.reg( 'PQSystemSessionCheck', 'SMsgHead',
    {
    }, 788199199
)

base.reg( 'PRSystemSessionCheck', 'SMsgHead',
    {
    }, 1098350912
)

-- 帐号验证
base.reg( 'PQSystemAuth', 'SMsgHead',
    {
        { 'outside_sock', 'int32' },		-- 外部连接号
    }, 143043716
)

base.reg( 'PRSystemAuth', 'SMsgHead',
    {
        { 'outside_sock', 'int32' },		-- 外部连接号
    }, 1935943368
)

-- 角色登录
base.reg( 'PQSystemLogin', 'SMsgHead',
    {
        { 'outside_sock', 'int32' },		-- 客户端连接号(服务器中转用)
    }, 27628880
)

base.reg( 'PRSystemLogin', 'SMsgHead',
    {
        { 'open_time', 'uint32' },		--  开服时间
        { 'server_time', 'uint32' },		-- 服务器时间
        { 'minuteswest', 'int32' },
        { 'dsttime', 'int32' },
        { 'outside_sock', 'int32' },		-- 客户端连接号(服务器中转用)
    }, 2063899790
)

-- game 进程sql线程到逻辑线程的数据返回包
base.reg( 'PRSystemUserLoad', 'SMsgHead',
    {
        { 'guid', 'uint32' },
        { 'created', 'uint8' },		-- 新创建使用
        { 'data', 'SUserData' },
    }, 1461797166
)

-- game 进程sql线程到逻辑线程的数据返回包
base.reg( 'PRSystemGuildLoad', 'SMsgHead',
    {
        { 'guid', 'uint32' },
        { 'created', 'uint8' },		-- 新创建工会
        { 'data', 'SGuildData' },
    }, 1175337528
)

-- 更新用户session, auth->game, auth->access
base.reg( 'PRSystemUserUpdateSession', 'SMsgHead',
    {
    }, 1340090719
)

-- 错误通知协议
base.reg( 'PRSystemErrCode', 'SMsgHead',
    {
        { 'err_no', 'uint32' },
        { 'err_desc', 'uint32' },
    }, 1465167678
)

-- 协议包序列同步
base.reg( 'PQSystemOrder', 'SMsgHead',
    {
    }, 123883356
)

base.reg( 'PRSystemOrder', 'SMsgHead',
    {
        { 'min', 'uint32' },
        { 'max', 'uint32' },
    }, 1801311003
)

-- 踢人
base.reg( 'PQSystemKick', 'SMsgHead',
    {
    }, 14859210
)

base.reg( 'PRSystemKick', 'SMsgHead',
    {
    }, 1542389995
)

-- 文本广播
base.reg( 'PQSystemPlacard', 'SMsgHead',
    {
        { 'order', 'uint8' },		-- 优先级, 值越大越高级, 最高255, 默认为0
        { 'flag', 'uint8' },		-- 广播类型( 位移 ), kPlacardFlagXXX
        { 'text', 'string' },
    }, 394623921
)

base.reg( 'PRSystemPlacard', 'SMsgHead',
    {
        { 'order', 'uint8' },		-- 优先级, 值越大越高级, 最高255, 默认为0
        { 'flag', 'uint8' },		-- 广播类型( 位移 ), kPlacardFlagXXX
        { 'text', 'string' },
    }, 1396856249
)


