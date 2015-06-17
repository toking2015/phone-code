local const = trans.const
local err = trans.err
local base = trans.base

const.kPathSingleArena		= 1865316154		-- 竞技场
const.kSingleArenaObjectAdd		= 0		-- 添加
const.kSingleArenaObjectDel		= 1		-- 删除

err.kErrSingleArenaNotExist		= 555715440		--竞技场未开放
err.kErrSingleArenaCD		= 904351219		--挑战时间未到
err.kErrSingleArenaTimes		= 271605967		--挑战次数不够
err.kErrSingleArenaGold		= 657319880		--元宝不足
err.kErrSingleArenaNoLoad		= 1756011234		--竞技场数据加载未完成

-- 竟技场-王子浪
base.reg( 'SSingleArenaOpponent', nil,
    {
        { 'target_id', 'uint32' },		-- 对手guid, 少于7位数的为假人
        { 'name', 'string' },		-- 对手名字
        { 'avatar', 'uint16' },		-- 对手头像
        { 'team_level', 'uint32' },		-- 战队等级
        { 'rank', 'uint32' },		-- 对手名次
        { 'fight_value', 'uint32' },		-- 战力，假人
        { 'formation_list', { 'array', 'SUserFormation' } },		-- 阵型     //如果此结构体做为排行榜数据，这list总为空
    }
)

base.reg( 'SSingleArenaLog', nil,
    {
        { 'target_id', 'uint32' },		-- 拥有者role_id <因为要保存到DB>
        { 'fight_id', 'uint32' },		-- 战斗log
        { 'ack_id', 'uint32' },		-- 进攻者id
        { 'def_id', 'uint32' },		-- 防御者id
        { 'ack_level', 'uint32' },		-- 进攻者等级
        { 'def_level', 'uint32' },		-- 防御者等级
        { 'ack_name', 'string' },		-- 进攻者名字
        { 'ack_avatar', 'uint16' },		-- 进攻者头像
        { 'def_name', 'string' },		-- 防御者名字
        { 'def_avatar', 'uint16' },		-- 防御者头像
        { 'win_flag', 'uint32' },		-- 1,进攻者羸 2，反之
        { 'log_time', 'uint32' },		-- 战斗记录时间
        { 'rank_num', 'int32' },		-- 名次的变动
    }
)

base.reg( 'SSingleArenaInfo', nil,
    {
        { 'opponent_list', { 'array', 'SSingleArenaOpponent' } },		-- 对手    
        { 'fightlog_list', { 'array', 'SSingleArenaLog' } },		-- 战斗log
        { 'cur_rank', 'uint32' },		-- 当前排名
        { 'max_rank', 'uint32' },		-- 历史最高排名
        { 'fight_value', 'uint32' },		-- 当前战力
        { 'time_cd', 'uint32' },		-- 挑战CD
        { 'add_times', 'uint32' },		-- 增加的挑战次数
        { 'cur_times', 'uint32' },		-- 当前挑战次数
    }
)

-- ============================数据中心========================
base.reg( 'CSingleArenaMap', nil,
    {
        { 'singlearena_info_map', { 'indices', 'SSingleArenaInfo' } },		-- 玩家信息
        { 'singlearena_rank_map', { 'indices', 'SSingleArenaOpponent' } },		-- 排行榜信息
        { 'singlearena_show_map', { 'indices', 'SSingleArenaOpponent' } },		-- 用来显示的排行榜信息<暂定前50名>
        { 'id_rank_map', { 'indices', 'uint32' } },		-- id 与排名 对应表
        { 'target_guid', 'uint32' },		-- 假人的guid递增
        { 'load_log', 'uint32' },		-- 从DB加载数据标志,2 加载完成
    }
)

-- 获取基本信息
base.reg( 'PQSingleArenaInfo', 'SMsgHead',
    {
    }, 355315651
)

base.reg( 'PRSingleArenaInfo', 'SMsgHead',
    {
        { 'info', 'SSingleArenaInfo' },
    }, 1421308713
)

-- 刷新对手
base.reg( 'PQSingleArenaRefresh', 'SMsgHead',
    {
    }, 616762807
)

base.reg( 'PRSingleArenaRefresh', 'SMsgHead',
    {
        { 'opponent_list', { 'array', 'SSingleArenaOpponent' } },		-- 对手，固定四个
    }, 1936653648
)

-- 申请挑战CD
base.reg( 'PQSingleArenaReplyCD', 'SMsgHead',
    {
    }, 956089270
)

base.reg( 'PRSingleArenaReplyCD', 'SMsgHead',
    {
        { 'time_cd', 'uint32' },		-- CD时间， 用现在的时间与此时间作比较，
    }, 1609156980
)

-- 清空挑战CD
base.reg( 'PQSingleArenaClearCD', 'SMsgHead',
    {
    }, 2781945
)

base.reg( 'PRSingleArenaClearCD', 'SMsgHead',
    {
        { 'time_cd', 'uint32' },		-- CD时间， 其实，只要监听到此协议，就代表清空CD成功
    }, 2133531346
)

-- 增加挑战次数
base.reg( 'PQSingleArenaAddTimes', 'SMsgHead',
    {
    }, 461113896
)

-- add_times  + Level.xls中的singlearena_times - cur_times就是今天还可以挑战的次数
base.reg( 'PRSingleArenaAddTimes', 'SMsgHead',
    {
        { 'add_times', 'uint32' },		-- 增加的挑战次数
        { 'cur_times', 'uint32' },		-- 当前挑战次数
    }, 1896427484
)

-- 申请最近的竞技log
base.reg( 'PQSingleArenaLog', 'SMsgHead',
    {
    }, 506821747
)

base.reg( 'PRSingleArenaLog', 'SMsgHead',
    {
        { 'fightlog_list', { 'array', 'SSingleArenaLog' } },		-- 战斗log
    }, 1355019612
)

-- 申请排行榜数据
base.reg( 'PQSingleArenaRank', 'SMsgHead',
    {
        { 'index', 'uint32' },		-- 从第几名开始
        { 'count', 'uint32' },		-- 数量
    }, 133216982
)

base.reg( 'PRSingleArenaRank', 'SMsgHead',
    {
        { 'list', { 'array', 'SSingleArenaOpponent' } },
    }, 1158409725
)

base.reg( 'PRSingleBattleReply', 'SMsgHead',
    {
        { 'cur_rank', 'uint32' },		-- 当前排名（最高排名也是这）
        { 'win_flag', 'uint32' },		-- 羸：kFightLeft 输: kFightRight
        { 'add_rank', 'uint32' },		-- 增加的名次
        { 'coin', 'S3UInt32' },		-- 奖励
    }, 1876563788
)

-- 申请自己竞技场的当前排名<没有开放的话就不会有 PRSingleArenaMyRank 返回>
base.reg( 'PQSingleArenaMyRank', 'SMsgHead',
    {
    }, 309320719
)

base.reg( 'PRSingleArenaMyRank', 'SMsgHead',
    {
        { 'rank', 'uint32' },		-- 当前排名
    }, 1122082782
)

-- 如果自己被玩家打败将会收到此协议作提醒
base.reg( 'PRSingleArenaBattleed', 'SMsgHead',
    {
    }, 2093837737
)

-- 战斗结束后，发掉落包
base.reg( 'PRSingleArenaBattleEnd', 'SMsgHead',
    {
        { 'win_flag', 'uint32' },		-- 1,赢 2,输
        { 'coins', { 'array', 'S3UInt32' } },		-- 奖励
    }, 1539999730
)

-- 申请玩家竞技场当前四个对手的中真人竞技防御阵里所有的武将id与图腾id
base.reg( 'PQUserSingleArenaPre', 'SMsgHead',
    {
    }, 595760048
)

base.reg( 'PRUserSingleArenaPre', 'SMsgHead',
    {
        { 's_map', { 'indices', 'array', 'S2UInt32' } },		-- 武将
        { 't_map', { 'indices', 'array', 'S2UInt32' } },		-- 图腾
    }, 1897770585
)

-- 对手排名有变动
base.reg( 'PRSingleArenaCheck', 'SMsgHead',
    {
        { 'flag', 'uint8' },		-- 0 代表战斗开始前就检测到对手排名已改变   1 代表战斗结束后检测到对手排名已改变
    }, 1321816909
)

-- ==============================服务器用========================
base.reg( 'PQSingleArenaSave', 'SMsgHead',
    {
        { 'set_type', 'uint8' },		-- kSingleArenaObjectAdd
        { 'data', 'SSingleArenaOpponent' },
    }, 985805389
)

-- 加载排行榜数据
base.reg( 'PQSingleArenaRankLoad', 'SMsgHead',
    {
    }, 351363324
)

base.reg( 'PRSingleArenaRankLoad', 'SMsgHead',
    {
        { 'list', { 'array', 'SSingleArenaOpponent' } },
    }, 2121841526
)

base.reg( 'PQSingleArenaLogLoad', 'SMsgHead',
    {
    }, 862327907
)

base.reg( 'PRSingleArenaLogLoad', 'SMsgHead',
    {
        { 'list', { 'array', 'SSingleArenaLog' } },
    }, 1482603583
)

base.reg( 'PQSingleArenaLogSave', 'SMsgHead',
    {
        { 'target_id', 'uint32' },
        { 'list', { 'array', 'SSingleArenaLog' } },
    }, 912156268
)

-- 引导过后发送此协议，可获得奖励等
base.reg( 'PQSingleArenaGetFirstReward', 'SMsgHead',
    {
    }, 327353176
)


