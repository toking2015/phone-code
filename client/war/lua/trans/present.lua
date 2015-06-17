local const = trans.const
local err = trans.err
local base = trans.base

const.kPathPresentGlobalTake		= 882915109		-- 激活码礼包领取

err.kErrPresentCodeEmpty		= 1104043789		--激活码不能为空
err.kErrPresentCodeFormation		= 907162480		--激活码格式错误
err.kErrPresentSqlInvaild		= 332109503		--数据库不可用
err.kErrPresentNoExist		= 1388585550		--礼包key不存在
err.kErrPresentTaken		= 41828412		--礼包已领取
err.kErrPresentSame		= 1800883874		--已领取过相同的礼包

-- @@请求获取全局礼包领取
base.reg( 'PQPresentGlobalTake', 'SMsgHead',
    {
        { 'platform', 'string' },		-- 平台key(服务器自动修改, 客户端不用填写)
        { 'code', 'string' },		-- 激活礼包key
    }, 244129486
)

base.reg( 'PRPresentGlobalTake', 'SMsgHead',
    {
        { 'err_code', 'uint32' },		-- 错误码
        { 'reward_id', 'uint32' },		-- 礼包reward
    }, 1336200323
)


