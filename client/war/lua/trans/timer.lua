local const = trans.const
local err = trans.err
local base = trans.base



-- 定时器事件--黄少卿
base.reg( 'PQTimerEvent', 'SMsgHead',
    {
        { 'time_id', 'uint32' },
        { 'time_key', 'string' },
        { 'time_param', 'string' },
        { 'time_sec', 'uint32' },
    }, 113037829
)


