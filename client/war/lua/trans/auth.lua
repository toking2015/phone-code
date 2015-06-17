local const = trans.const
local err = trans.err
local base = trans.base

const.kAuthRunJsonFlagError		= 0		-- 错误
const.kAuthRunJsonFlagSucceed		= 1		-- 完成执行
const.kAuthRunJsonFlagDefer		= 2		-- 延迟执行
const.kAuthRunJsonFlagLoop		= 3		-- 循环执行


-- =========================通迅结构============================
base.reg( 'SAuthRunTime', nil,
    {
        { 'guid', 'uint32' },		-- 运行时id
        { 'data', 'string' },
    }
)

-- 用于全局循环执行指令数据
base.reg( 'SAuthRunData', nil,
    {
        { 'guid', 'uint32' },		-- 唯一guid, 由 mysql insert 时生成
        { 'loop_id', 'uint32' },		-- AddLoop 后生成的 loop_id
        { 'json_string', 'string' },		-- 执行数据
    }
)

-- =========================数据中心============================
base.reg( 'CAuth', nil,
    {
        { 'loop_map', { 'indices', 'SAuthRunData' } },		-- < guid, 执行指令数据 >
        { 'online_data', { 'indices', 'uint32' } },		-- < guid, 在线时长( 每天清空 ) >
    }
)

-- =========================通迅协议============================
base.reg( 'PQAuthRunJson', 'SMsgHead',
    {
        { 'outside_sock', 'int32' },		-- 外部连接
        { 'json_string', 'string' },		-- 执行字符串
    }, 110123182
)

-- 定时执行记录设置
base.reg( 'PQAuthRunTimeSet', 'SMsgHead',
    {
        { 'outside_sock', 'int32' },		-- 外部连接
        { 'set_type', 'uint8' },		-- kObjectAdd, kObjectDel
        { 'cmd', 'string' },
        { 'run_time', 'SAuthRunTime' },
    }, 149382596
)

base.reg( 'PRAuthRunTimeSet', 'SMsgHead',
    {
        { 'outside_sock', 'int32' },		-- 外部连接
        { 'set_type', 'uint8' },
        { 'run_time', 'SAuthRunTime' },
    }, 1140596663
)

base.reg( 'PQAuthRunTimeList', 'SMsgHead',
    {
    }, 337467577
)

base.reg( 'PRAuthRunTimeList', 'SMsgHead',
    {
        { 'list', { 'array', 'SAuthRunTime' } },
    }, 1110885674
)


