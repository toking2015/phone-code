local const = trans.const
local err = trans.err
local base = trans.base

const.kBackObserver		= 1		-- 观察者指令, 如: 查看当前数据(在线等)
const.kBackExecutor		= 2		-- 执行者指令, 如: 数据操作, 发布公告 
const.kBackGrounder		= 4		-- 后台指令, 如: 开关服, 修改其它GM权限
const.kBackInnerAcc		= 8		-- 内部账号 
const.kBackInstructor		= 16		-- 指导员 
const.kBackGameMaster		= 32		-- GM


-- @@请求日志记录
base.reg( 'PQBackLog', 'SMsgHead',
    {
        { 'log_title', 'string' },
        { 'log_text', 'string' },
        { 'log_time', 'uint32' },
    }, 883558710
)


