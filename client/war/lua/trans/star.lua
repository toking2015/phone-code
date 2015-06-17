local const = trans.const
local err = trans.err
local base = trans.base



-- ==========================通迅结构==========================
base.reg( 'SUserStar', nil,
    {
        { 'copy', 'uint32' },		-- 副本获得星星总数
        { 'hero', 'uint32' },		-- 英雄系统星星总数
        { 'totem', 'uint32' },		-- 图腾系统星星总数
    }
)

base.reg( 'PRStarData', 'SMsgHead',
    {
        { 'data', 'SUserStar' },
    }, 1096302338
)


