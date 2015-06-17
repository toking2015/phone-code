local const = trans.const
local err = trans.err
local base = trans.base

const.kPathGutCommit		= 1186291935		-- 剧情提交
const.kPathGutFinish		= 853097368		-- 剧情完成
const.kGutTypeTalk		= 1		-- 对话
const.kGutTypeBox		= 3		-- 宝箱 [ objid: packet_id ], [val: reward_id ]
const.kGutTypeReward		= 4		-- 奖励 [ objid: reward_id ]
const.kGutTypeVideo		= 5		-- 视频
const.kGutTypeSpecial		= 6		-- 特殊( 针对性代码编写 )

err.kErrGutNotExisit		= 2052760207		--剧情不存在
err.kErrGutIndex		= 875561975		--剧情索引错误
err.kErrGutRewardNotExist		= 1414475475		--剧情奖励不存在
err.kErrGutEventOrder		= 883288564		--剧情事件序列错误

-- 剧情-黄少卿
base.reg( 'SGutInfo', nil,
    {
        { 'gut_id', 'uint32' },
        { 'index', 'int32' },		-- 当前事件索引, 从0开始( 不保存数据库 )
        { 'event', { 'array', 'S3UInt32' } },		-- 剧情列表, cate见 kGutTypeXXX
    }
)

-- @@请求剧情事件
base.reg( 'PQGutInfo', 'SMsgHead',
    {
    }, 364170231
)

base.reg( 'PRGutInfo', 'SMsgHead',
    {
        { 'data', 'SGutInfo' },
    }, 1993357244
)

-- 事件验证基类
base.reg( 'PQGutCommitEvent', 'SMsgHead',
    {
        { 'index', 'int32' },		-- 剧情事件会包含多个处理步骤(从0开始) 
    }, 813604863
)


