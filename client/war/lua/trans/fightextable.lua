local const = trans.const
local err = trans.err
local base = trans.base



-- 二级属性-印佳
base.reg( 'SFightExtAbleInfo', nil,
    {
        { 'guid', 'uint32' },		-- guid
        { 'attr', 'uint32' },		-- 玩家
        { 'able', 'SFightExtAble' },		-- 二级属性 
    }
)

-- @@请求好友列表
base.reg( 'PQFightExtAbleList', 'SMsgHead',
    {
        { 'attr', 'uint32' },		-- 武将
    }, 1006064479
)

base.reg( 'PRFightExtAbleList', 'SMsgHead',
    {
        { 'attr', 'uint32' },		-- 武将
        { 'fightextable_list', { 'array', 'SFightExtAbleInfo' } },		-- 二级属性
    }, 1830637631
)

base.reg( 'PRFightExtAbleSet', 'SMsgHead',
    {
        { 'set_type', 'uint32' },
        { 'fightextable', 'SFightExtAbleInfo' },
    }, 1763962368
)


