local const = trans.const
local err = trans.err
local base = trans.base

const.kPathGuildInit		= 440539142		-- 公会初始化
const.kPathGuildLoad		= 741151118		-- 公会加载
const.kPathGuildCreate		= 195444527		-- 创建公会
const.kPathGuildJoin		= 1603195559		-- 加入公会
const.kPathGuildExit		= 1927710242		-- 退出公会
const.kPathGuildJobChange		= 810820358		-- 公会职位变更
const.kPathGuildContribute		= 94677408		-- 公会捐献
const.kPathGuildLevelup		= 1021453233		-- 公会升级
const.kGuild		= 241034201
const.kGuildJobCommon		= 1		-- 普通成员
const.KGuildJobVip		= 2		-- 贵宾
const.kGuildJobMaster		= 3		-- 会长
const.kGuildLogMax		= 20
const.kGuildLogJoin		= 1		-- 加入
const.kGuildLogQuit		= 2		-- 退出
const.kGuildLogKick		= 3		-- 踢出
const.kGuildLogContribute		= 4		-- 贡献
const.kGuildLogLevelup		= 5		-- 升级
const.kGuildLogMasterChange		= 6		-- 会长转让

err.kErrGuild		= 140824409
err.kErrGuildExist		= 128580917		--公会已存在
err.kErrGuildNameEmpty		= 583620925		--公会名称不能为空
err.kErrGuildNameSpecial		= 836211315		--公会名称不能存在特殊字符
err.kErrGuildNameExist		= 772632695		--公会名称已存在
err.kErrGuildNoExist		= 828404836		--公会不存在
err.kErrGuildExitMaster		= 1588120539		--公会会长不允许退出公会
err.kErrGuildJobChangeSelf		= 1450063457		--不能对自己职务进行更改
err.kErrGuildJobChangePurview		= 1835575541		--职务修改权限不足
err.kErrGuildMemberNoExist		= 1736414275		--公会成员不存在
err.kErrGuildApplyMax		= 1315486980		--申请数量已达上限
err.kErrGuildAuthority		= 1641952783		--权限不足
err.kErrGuildApplyFull		= 1722585395		--公会申请人数过多
err.kErrGuildData		= 1196514008		--数据错误
err.kErrGuildApplyNotFound		= 1909325558		--找不到申请人
err.kErrGuildMemberMax		= 1328370256		--公会人数已满
err.kErrGuildContributeTimeLimit		= 1215606341		--捐献次数已用完
err.kErrGuildLevelupXpLack		= 1782616349		--升级经验不足

-- 公会简易信息结构
base.reg( 'SGuildSimple', nil,
    {
        { 'guid', 'uint32' },
        { 'name', 'string' },
        { 'level', 'uint16' },		-- 军团等级
        { 'creator_id', 'uint32' },		-- 创建人role_id
    }
)

-- 公会日志
base.reg( 'SGuildLog', nil,
    {
        { 'type', 'uint32' },
        { 'time', 'uint32' },
        { 'params', 'string' },
    }
)

-- 公会基本信息结构
base.reg( 'SGuildInfo', nil,
    {
        { 'create_time', 'uint32' },		-- 创建日期
        { 'xp', 'uint32' },		-- 经验
        { 'post_msg', 'string' },		-- 公告
    }
)

base.reg( 'SGuildProtect', nil,
    {
        { 'lock_time', 'uint32' },		-- 用于临时锁定用户可能产生冲突的操作, 例如: 创建公会, 角色改名等
    }
)

-- 公会浏览面板信息结构
base.reg( 'SGuildPanel', nil,
    {
        { 'simple', 'SGuildSimple' },
        { 'info', 'SGuildInfo' },
    }
)

-- 公会成员信息结构
base.reg( 'SGuildMember', nil,
    {
        { 'role_id', 'uint32' },
        { 'job', 'uint32' },		-- 公会职位
        { 'join_time', 'uint32' },
        { 'daily_contribute', 'uint32' },
        { 'history_contribute', 'uint32' },
    }
)

-- 公会存储数据库的所有数据结构
base.reg( 'SGuildData', nil,
    {
        { 'simple', 'SGuildSimple' },
        { 'info', 'SGuildInfo' },
        { 'protect', 'SGuildProtect' },
        { 'log_list', { 'array', 'SGuildLog' } },		-- 动态日志
        { 'member_list', { 'array', 'SGuildMember' } },		-- 成员列表
    }
)

-- 公会扩展信息结构( 不保存至数据库,只用于服务器内部临时保存 )
base.reg( 'SGuildExt', nil,
    {
        { 'check', { 'map', 'S4Int32' } },		-- 公会数据一致性校验
        { 'operate_time', 'uint32' },		-- 最后操作时间
        { 'meet_time', 'uint32' },		-- 最后访问时间
        { 'save_time', 'uint32' },		-- 最后保存时间
        { 'apply_users', { 'array', 'uint32' } },		-- 申请人列表
    }
)

-- 公会数据集合
base.reg( 'SGuild', nil,
    {
        { 'guid', 'uint32' },
        { 'data', 'SGuildData' },
        { 'ext', 'SGuildExt' },
    }
)

-- ============================数据中心========================
base.reg( 'CGuildMap', nil,
    {
        { 'guild_map', { 'indices', 'SGuild' } },		-- 公会数据集合
        { 'simple_map', { 'indices', 'SGuildSimple' } },		-- 公会基本数据集合
        { 'order_member_count', { 'array', 'uint32' } },		-- 根据成员总数排序的公会id列表
        { 'save_index', 'int32' },		-- 数据保存索引
        { 'guild_name_id', { 'map', 'uint32' } },		-- 名称映射id
        { 'guild_id_name', { 'indices', 'string' } },		-- id映射名称
    }
)

-- 公会基本数据请求
base.reg( 'PQGuildSimple', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
    }, 285286939
)

base.reg( 'PRGuildSimple', 'SMsgHead',
    {
        { 'data', 'SGuildSimple' },
    }, 1548333934
)

-- 公会显示信息请求
base.reg( 'PQGuildPanel', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
    }, 886617734
)

base.reg( 'PRGuildPanel', 'SMsgHead',
    {
        { 'data', 'SGuildPanel' },
    }, 1350056808
)

-- 公会成员请求
base.reg( 'PQGuildMemberList', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 公会id
    }, 761414498
)

base.reg( 'PRGuildMemberList', 'SMsgHead',
    {
        { 'list', { 'array', 'SGuildMember' } },
    }, 1797061462
)

-- 公会列表请求
base.reg( 'PQGuildList', 'SMsgHead',
    {
        { 'index', 'uint32' },		-- 从索引开始请求, 索引从0开始
        { 'count', 'uint32' },		-- 请求数量
    }, 660873787
)

base.reg( 'PRGuildList', 'SMsgHead',
    {
        { 'index', 'uint32' },		-- 返回的数据从索引index处开始, 索引从0开始
        { 'sum', 'uint32' },		-- 总长度( 全服列表总数 )
        { 'list', { 'array', 'uint32' } },		-- 公会 id 列表
    }, 1358762892
)

-- 所有公会基本信息列表请求(用于服务器初始化)
base.reg( 'PQGuildSimpleList', 'SMsgHead',
    {
    }, 433483323
)

base.reg( 'PRGuildSimpleList', 'SMsgHead',
    {
        { 'list', { 'array', 'SGuildSimple' } },		-- 公会基本信息列表数据
    }, 1305794030
)

-- 创建公会
base.reg( 'PQGuildCreate', 'SMsgHead',
    {
        { 'name', 'string' },		-- 公会名称
    }, 217782399
)

base.reg( 'PRGuildCreate', 'SMsgHead',
    {
        { 'guild_id', 'uint32' },		-- 公会id
        { 'name', 'string' },		-- 公会名称
        { 'create_time', 'uint32' },		-- 创建时间
    }, 1833501751
)

-- 邀请
base.reg( 'PQGuildInvite', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 被邀请人
    }, 785871036
)

-- 申请
base.reg( 'PQGuildApply', 'SMsgHead',
    {
        { 'set_type', 'uint32' },		-- [kObjectAdd,kObjectDel]
        { 'guild_id', 'uint32' },
    }, 747175929
)

-- 申请人更新
base.reg( 'PRGuildApplySet', 'SMsgHead',
    {
        { 'set_type', 'uint32' },
        { 'target_id', 'uint32' },
    }, 1471431520
)

-- 申请人列表
base.reg( 'PRGuildApply', 'SMsgHead',
    {
        { 'apply_list', { 'array', 'uint32' } },
    }, 1972373836
)

-- 审批
base.reg( 'PQGuildApprove', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'is_accept', 'int8' },
    }, 148826004
)

-- 退团
base.reg( 'PQGuildQuit', 'SMsgHead',
    {
    }, 128922739
)

-- 踢人
base.reg( 'PQGuildKick', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
    }, 271473681
)

-- 任命
base.reg( 'PQGuildSetJob', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'job', 'uint8' },
    }, 992226334
)

-- 成员数据更新
base.reg( 'PRGuildMemberSet', 'SMsgHead',
    {
        { 'set_type', 'uint32' },
        { 'member', 'SGuildMember' },
    }, 1816172323
)

-- 贡献
base.reg( 'PQGuildContribute', 'SMsgHead',
    {
        { 'id', 'uint32' },
    }, 886345701
)

-- 公会升级
base.reg( 'PQGuildLevelup', 'SMsgHead',
    {
    }, 253962101
)

-- 等级经验更新
base.reg( 'PRGuildLevel', 'SMsgHead',
    {
        { 'level', 'uint32' },
        { 'xp', 'uint32' },
    }, 1322202085
)

-- 公告
base.reg( 'PQGuildPost', 'SMsgHead',
    {
        { 'content', 'string' },
    }, 573031854
)

base.reg( 'PRGuildPost', 'SMsgHead',
    {
        { 'content', 'string' },
    }, 1300943509
)


