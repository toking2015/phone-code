local const = trans.const
local err = trans.err
local base = trans.base

const.kPathStrengthTimer		= 1617518012		-- 定时回复
const.kPathStrengthBuy		= 1248765147		-- 体力购买

err.kErrStrengthFull		= 1856008462		--体力已满
err.kErrStrengthBuyTimesMax		= 1017465030		--体力购买次数已满

-- =========================通迅协议============================
base.reg( 'PQStrengthBuy', 'SMsgHead',
    {
    }, 1063403861
)

base.reg( 'PRStrengthBuy', 'SMsgHead',
    {
        { 'value', 'uint32' },		-- 购买获得体力
    }, 1814060550
)


