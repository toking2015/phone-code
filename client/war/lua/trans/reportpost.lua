local const = trans.const
local err = trans.err
local base = trans.base



-- 举报系统-王子浪
base.reg( 'SReportPostInfo', nil,
    {
        { 'target_id', 'uint32' },
        { 'report_time', 'uint32' },		-- 举报时间点，如果当前时间 大于 “举报时间限期”　+　report_time 就清空target_list
        { 'report_list', { 'array', 'uint32' } },		-- 举报者id
    }
)

-- ============================数据中心========================
base.reg( 'CReportPostMap', nil,
    {
        { 'reportpost_info_map', { 'indices', 'SReportPostInfo' } },		-- 玩家信息
    }
)

-- 获取基本信息
base.reg( 'PQReportPostInfo', 'SMsgHead',
    {
    }, 339976699
)

base.reg( 'PRReportPostInfo', 'SMsgHead',
    {
        { 'info', 'SReportPostInfo' },
    }, 1987315945
)

-- 举报
base.reg( 'PQReportPostMake', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 被举报者guid
    }, 411962653
)

-- 举报返回协议，作为是成功等提示
base.reg( 'PRReportPostMake', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 被举报者guid
    }, 1560889071
)

base.reg( 'PRReportPostBan', 'SMsgHead',
    {
    }, 1913283098
)

-- 加载
base.reg( 'PQReportPostInfoLoad', 'SMsgHead',
    {
    }, 1063669705
)

base.reg( 'PRReportPostInfoLoad', 'SMsgHead',
    {
        { 'info_map', { 'indices', 'SReportPostInfo' } },
    }, 1596177775
)

base.reg( 'PQReportPostUpdate', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- kObjecAdd, kObjecDel
        { 'target_id', 'uint32' },		-- 被举报者role_id
        { 'report_id', 'uint32' },		-- 举报者role_id
        { 'report_time', 'uint32' },		-- 举报者时间,　　其实内部处理只用SReportPostInfo.report_time
    }, 217565280
)


