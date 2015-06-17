local const = trans.const
local err = trans.err
local base = trans.base

const.kRankingObjectAdd		= 0		-- 添加
const.kRankingObjectDel		= 1		-- 删除
const.kRankingObjectUpdate		= 2		-- 更新
const.kRankAttrReal		= 1		-- 实时排行榜
const.kRankAttrCopy		= 2		-- 记录排行榜
const.kRankCycDay		= 1		-- 天循环
const.kRankCycWeek		= 2		-- 周循环
const.kRankCycMonth		= 3		-- 月循环
const.kRankingTypeSingleArena		= 1		-- 竞技场真人排行榜
const.kRankingTypeSoldier		= 2		-- 英雄
const.kRankingTypeTotem		= 3		-- 图腾
const.kRankingTypeCopy		= 4		-- 副本
const.kRankingTypeMarket		= 5		-- 拍卖行
const.kRankingTypeEquip		= 6		-- 装备
const.kRankingTypeTeamLevel		= 7		-- 战队等级
const.kRankingTypeTemple		= 8		-- 神殿


-- 用户排行榜基本信息
base.reg( 'SRankInfo', nil,
    {
        { 'id', 'uint32' },		-- 用户id, 军团id
        { 'avatar', 'uint16' },		-- 头像
        { 'name', 'string' },		-- 名字
        { 'team_level', 'uint32' },		-- 战队等级
        { 'limit', 'uint32' },		-- 分阶
        { 'first', 'uint32' },		-- 排行值1
        { 'second', 'uint32' },		-- 排行值2
        { 'index', 'uint32' },		-- 记录排行榜的名次
    }
)

-- 用户排行榜数据
base.reg( 'SRankData', nil,
    {
        { 'info', 'SRankInfo' },
        { 'data', { 'map', 'uint32' } },		-- 排行榜自定义数据
    }
)

-- 排行榜数据
base.reg( 'CRank', nil,
    {
        { 'id_data', { 'indices', 'SRankData' } },		-- 对象数据
        { 'rank', { 'array', 'SRankInfo' } },		-- 排行榜列表
    }
)

-- ============================数据中心========================
base.reg( 'CRankCenter', nil,
    {
        { 'real_map', { 'indices', 'CRank' } },		-- 即时排行榜
        { 'copy_map', { 'indices', 'CRank' } },		-- 记录排行榜
    }
)

-- 将记录排行榜数据进行保存
base.reg( 'PQRankCopySave', 'SMsgHead',
    {
        { 'rank_type', 'uint8' },		-- kRankingTypeXXXX
        { 'set_type', 'uint8' },		-- kObjectDel, kObjectAdd
        { 'list', { 'array', 'SRankData' } },		-- 排行数据
    }, 479530750
)

-- 请求读取记录排行榜数据
base.reg( 'PQRankLoad', 'SMsgHead',
    {
        { 'rank_type', 'uint8' },		-- kRankingTypeXXX
        { 'rank_attr', 'uint8' },		-- kRankAttrYYY
    }, 810078193
)

-- 返回记录排行榜数据
base.reg( 'PRRankLoad', 'SMsgHead',
    {
        { 'rank_type', 'uint8' },		-- kRankingTypeXXX
        { 'rank_attr', 'uint8' },		-- kRankAttrYYY
        { 'list', { 'array', 'SRankData' } },		-- 排行数据
    }, 2011706770
)

-- 请求指定id在指定排行榜中的索引位置(从0开始)
base.reg( 'PQRankIndex', 'SMsgHead',
    {
        { 'limit', 'uint32' },		-- 分阶
        { 'rank_type', 'uint8' },		-- kRankingTypeXXX
        { 'rank_attr', 'uint8' },		-- kRankAttrYYY
        { 'target_id', 'uint32' },		-- 查询id
    }, 534066083
)

-- 返回指定id在排行榜中的位置
base.reg( 'PRRankIndex', 'SMsgHead',
    {
        { 'limit', 'uint32' },		-- 分阶
        { 'rank_type', 'uint8' },		-- kRankingTypeXXX
        { 'rank_attr', 'uint8' },		-- kRankAttrYYY
        { 'target_id', 'uint32' },		-- 查询id
        { 'index', 'int32' },		-- 顺位索引( 从0开始, 不存在返回 -1 )
        { 'data', 'SRankData' },
    }, 1385163042
)

-- 请求排行榜列表
base.reg( 'PQRankList', 'SMsgHead',
    {
        { 'limit', 'uint32' },		-- 分阶
        { 'rank_type', 'uint8' },		-- kRankingTypeXXX
        { 'index', 'uint32' },		-- 获取起始偏移索引
        { 'count', 'uint8' },		-- 获取条数( 不建议一次过请求超过100条 )
    }, 612777078
)

-- 请求排行榜列表
base.reg( 'PQRankListType', 'SMsgHead',
    {
        { 'limit', 'uint32' },		-- 分阶
        { 'rank_type', 'uint8' },		-- kRankingTypeXXX
        { 'data_type', 'uint8' },		-- kRankAttrReal 即时　 kRankAttrCopy　记录
        { 'index', 'uint32' },		-- 获取起始偏移索引
        { 'count', 'uint8' },		-- 获取条数( 不建议一次过请求超过100条 )
    }, 164901211
)

-- 返回排行榜列表
base.reg( 'PRRankList', 'SMsgHead',
    {
        { 'limit', 'uint32' },		-- 分阶
        { 'rank_type', 'uint8' },		-- kRankingTypeXXX
        { 'index', 'uint32' },		-- 获取起始偏移索引
        { 'sum', 'uint32' },		-- 排行榜总条数
        { 'list', { 'array', 'SRankData' } },		-- 返回数据集
    }, 2140059588
)

base.reg( 'PRRankClearData', 'SMsgHead',
    {
        { 'rank_type', 'uint8' },		-- kRankingTypeXXX
    }, 1386335833
)


