local const = trans.const
local err = trans.err
local base = trans.base



-- 阵型-印佳
base.reg( 'SUserBias', nil,
    {
        { 'bias_id', 'uint32' },		-- 掉落id
        { 'use_count', 'uint32' },		-- 使用次数
        { 'day_count', 'uint32' },		-- 一天获得次数
    }
)


