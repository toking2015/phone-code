local const = trans.const
local err = trans.err
local base = trans.base

const.kPathCopyPass		= 487341379		-- 副本通关
const.kPathCopyPassEquip		= 1603270542		-- 副本通关指定装备奖励
const.kPathCopyGroupPass		= 1668870455		-- 副本集群通关
const.kPathCopyBossFight		= 331226124		-- 副本boss挑战奖励
const.kPathCopySearch		= 44267644		-- 副本探索
const.kPathCopyFightMeet		= 636723069		-- 副本迎敌战
const.kPathCopyBossMopup		= 1955292224		-- 副本BOSS扫荡
const.kPathCopyCommit		= 1577068634		-- 副本提交验证
const.kPathCopyMopupReset		= 541069187		-- 副本扫荡重置
const.kPathCopyAreaPass		= 784566122		-- 副本区域通关
const.kPathCopyAreaPresentTake		= 731592263		-- 副本区域满星通关
const.kCopyEventTypeRandom		= 1		-- 随机事件
const.kCopyEventTypeBox		= 2		-- 宝箱 [ objid: packet_id ], [ val: reward_id ]
const.kCopyEventTypeReward		= 3		-- 奖励 [ objid: reward_id ]
const.kCopyEventTypeGut		= 4		-- 剧情 [ objid: gut_id ]
const.kCopyEventTypeShop		= 5		-- 商人
const.kCopyEventTypeFight		= 6		-- 战斗 [ objid: monster_id ], [ val: fight_id ], Monster.strength 消耗体力
const.kCopyEventTypeFightMeet		= 7		-- 迎敌战 [ objid: monster_id ], [ val: fight_id ], Monster.strength 消耗体力
const.kCopyFightLogMaxCount		= 5		-- 副本LOG长度
const.kCopyStateBossCol		= 1		-- (已废弃)
const.kCopyStateEventEnd		= 2		-- 副本事件已完全(不表示完成度全满)
const.kCopyTypeGeneral		= 0		-- 普通副本
const.kCopyTypeBoss		= 1		-- BOSS副本(可扫荡)
const.kCopyMopupTypeNormal		= 1		-- 普通副本
const.kCopyMopupTypeElite		= 2		-- 精英副本
const.kCopyMaterial		= 3		-- 副本资源点
const.kCopyMopupAttrRound		= 1		-- 阵亡人数
const.kCopyMopupAttrTimes		= 2		-- 扫荡次数
const.kCopyMopupAttrReset		= 3		-- 重置次数
const.kCopyAreaAttrPass		= 1		-- 副本区域通关
const.kCopyAreaAttrFullStar		= 2		-- 副本区域满星

err.kErrCopyParam		= 1179085069		--副本参数错误
err.kErrCopyData		= 1235614006		--副本数据错误
err.kErrCopyExist		= 562277816		--副本已存在
err.kErrCopyMopupNotExist		= 231064026		--副本扫荡数据不存在
err.kErrCopyNotExist		= 1727485652		--副本不存在
err.kErrCopyEnded		= 328303350		--副本已通关
err.kErrCopyNotPass		= 1831653469		--副本未通关
err.kErrCopyFront		= 1502938991		--副本前置条件不足
err.kErrCopyUndone		= 739119366		--副本存在未通关记录
err.kErrCopyNotEnd		= 923922869		--副本未结束
err.kErrCopyEventOrder		= 1393005650		--副本事件序列错误
err.kErrCopyEventIndex		= 1796537224		--副本事件进度索引错误
err.kErrCopyRewardNotExist		= 66067667		--副本奖励数据不存在
err.kErrCopyBossNotExist		= 1932494041		--副本BOSS不存在
err.kErrCopyStrengthNotEnought		= 1403771026		--副本体力不足
err.kErrCopyBossMopupScore		= 1388140752		--副本BOSS扫荡评分不足
err.kErrCopyChunkIndexExsit		= 508069909		--副本探索块索引数据已存在
err.kErrCopyChunkCateNull		= 859452038		--副本探索块类型数据错误
err.kErrCopyMopupRefTimesNotEnough		= 1518472622		--副本扫荡重置次数不足
err.kErrCopyMopupTimesFull		= 802418475		--不需要重置扫荡次数
err.kErrCopyMopupTimesNotEnough		= 7497487		--副本扫荡次数不足
err.kErrCopyAreaNotExist		= 36091843		--副本区域数据不存在
err.kErrCopyAreaPresentTaked		= 1689716357		--副本区域奖励已领取
err.kErrCopyAreaNoPass		= 774445435		--副本区域未通关
err.kErrCopyAreaNoFullStar		= 1718634511		--副本区域未达到全星要求
err.kErrCopyBossExist		= 1222807567		--副本BOSS已存在
err.kErrCopyFightIdNotEqual		= 561122740		--副本战斗id不匹配

-- 副本结构
base.reg( 'SUserCopy', nil,
    {
        { 'copy_id', 'uint32' },		-- 副本Id
        { 'posi', 'int32' },		-- 当前进度(从0开始)
        { 'index', 'int32' },		-- 当前进度内的步骤索引
        { 'status', 'uint32' },		-- 副本状态[ kCopyStateXXX ]
        { 'chunk', { 'array', 'S3UInt32' } },		-- 事件列表, cate 见 kCopyEvnetXYZ
        { 'reward', { 'array', 'S3UInt32' } },		-- 奖励列表, [ cate: [0不要体力, 1需要体力], objid: reward_id, val: 完成度 ]
        { 'coins', { 'array', 'array', 'S3UInt32' } },		-- 掉落列表
        { 'fight', { 'indices', 'SFight' } },		-- chunk 对应的战斗Id
        { 'seed', { 'indices', 'SInteger' } },		-- chunk 对应的战斗种子
        { 'gut', { 'indices', 'SGutInfo' } },		-- 剧情列表
    }
)

-- 副本记录, 只有 SUserCopy.status 带有 kCopyStateBossCol 状态并且通关后才会该记录
base.reg( 'SCopyLog', nil,
    {
        { 'copy_id', 'uint32' },		-- 通关副本Id
        { 'time', 'uint32' },		-- 通关时间
    }
)

-- 副本战斗记录
base.reg( 'SCopyFightLog', nil,
    {
        { 'copy_id', 'uint32' },		-- 副本id
        { 'fight_id', 'uint32' },		-- 战斗log
        { 'ack_id', 'uint32' },		-- 进攻者id
        { 'ack_level', 'uint32' },		-- 进攻者等级
        { 'ack_name', 'string' },		-- 进攻者名字
        { 'ack_avatar', 'uint16' },		-- 进攻者头像
        { 'log_time', 'uint32' },		-- 战斗记录时间
        { 'star', 'uint32' },		-- 星级
        { 'fight_value', 'uint32' },		-- 战斗力
    }
)

-- 区域通关记录
base.reg( 'SAreaLog', nil,
    {
        { 'area_id', 'uint32' },		-- 区域id( copy_id / 1000 )
        { 'normal_full_take_time', 'uint32' },		-- 普通区域满星领奖时间
        { 'elite_full_take_time', 'uint32' },		-- 精英区域满星领奖时间
        { 'normal_pass_take_time', 'uint32' },		-- 普通区域通关领奖时间
        { 'elite_pass_take_time', 'uint32' },		-- 精英区域通关领奖时间
    }
)

base.reg( 'SCopyMopup', nil,
    {
        { 'normal_round', { 'indices', 'uint32' } },		-- 普通副本boss击杀最小阵亡人数
        { 'elite_round', { 'indices', 'uint32' } },		-- 精英副本boss击杀最小阵亡人数
        { 'normal_times', { 'indices', 'uint32' } },		-- 普通副本boss扫荡次数, < boss_id, 次数 >
        { 'elite_times', { 'indices', 'uint32' } },		-- 精英副本boss扫荡次数, < boss_id, 次数 >
        { 'normal_reset', { 'indices', 'uint32' } },		-- 普通副本boss重置次数
        { 'elite_reset', { 'indices', 'uint32' } },		-- 精英副本boss重置次数
    }
)

-- 副本BOSS挑战临时结构
base.reg( 'SCopyBossFight', nil,
    {
        { 'mopup_type', 'uint8' },		-- 副本扫荡类型
        { 'boss_id', 'uint32' },		-- 挑战boss monster id
        { 'fight_id', 'uint32' },
        { 'seed', 'uint32' },
        { 'coins', { 'array', 'S3UInt32' } },		-- 战斗掉落记录
    }
)

-- =========================数据中心========================
base.reg( 'CCopy', nil,
    {
        { 'boss_fight', { 'indices', 'SCopyBossFight' } },
        { 'copy_log_map', { 'indices', 'array', 'SCopyFightLog' } },		-- 副本战斗记录保存
        { 'is_load_copyfight_log', 'uint32' },		-- 是否已经load副本记录
    }
)

-- @@
base.reg( 'PQCopyOpen', 'SMsgHead',
    {
        { 'copy_id', 'uint32' },		-- 副本Id
    }, 443612719
)

base.reg( 'PRCopyOpen', 'SMsgHead',
    {
        { 'data', 'SCompressData' },		-- 副本数据
        { 'result', 'int32' },
    }, 1180545869
)

base.reg( 'PRCopyData', 'SMsgHead',
    {
        { 'data', 'SCompressData' },		-- 副本数据
    }, 2097723839
)

-- 关闭当前副本
base.reg( 'PQCopyClose', 'SMsgHead',
    {
    }, 684499077
)

base.reg( 'PRCopyClose', 'SMsgHead',
    {
        { 'result', 'int32' },		-- 0为正常, != 0 为错误码
    }, 1145076953
)

-- 事件验证基类
base.reg( 'PQCopyCommitEvent', 'SMsgHead',
    {
        { 'posi', 'int32' },		-- 进度索引(从0开始)
        { 'index', 'int32' },		-- 同一进度事件内的序列, 剧情事件会包含多个处理步骤(从0开始)
    }, 463078305
)

-- 失败返回
base.reg( 'PRCopyCommitEvent', 'SMsgHead',
    {
        { 'posi', 'int32' },
        { 'index', 'int32' },
        { 'result', 'int32' },		-- 0为正常, !=0 为错误码
    }, 1829634408
)

-- 事件验证--战斗
base.reg( 'PQCopyCommitEventFight', 'PQCopyCommitEvent',
    {
        { 'fight_id', 'uint32' },		-- 战斗id
        { 'order_list', { 'array', 'SFightOrder' } },		-- 战斗技能出手LOG
        { 'fight_info_list', { 'array', 'SFightPlayerSimple' } },		-- 战斗结束时候的信息
    }, 750802594
)

-- 失败返回
base.reg( 'PRCopyCommitEventFight', 'PRCopyCommitEvent',
    {
        { 'fight_id', 'uint32' },		-- 战斗id
        { 'order_list', { 'array', 'SFightOrder' } },
        { 'fight_info_list', { 'array', 'SFightPlayerSimple' } },
    }, 1091587271
)

-- 刷新副本数据( 战斗属性更新等, 不影响已提交验证的事件 )
base.reg( 'PQCopyRefurbish', 'SMsgHead',
    {
    }, 778525585
)

base.reg( 'PRCopyRefurbish', 'SMsgHead',
    {
        { 'data', 'SCompressData' },		-- 副本数据
    }, 1260538048
)

-- 请求副本记录
base.reg( 'PQCopyLog', 'SMsgHead',
    {
        { 'copy_id', 'uint32' },
    }, 942268467
)

-- 返回副本记录
base.reg( 'PRCopyLog', 'SMsgHead',
    {
        { 'data', 'SCopyLog' },
    }, 1481077064
)

-- 请求副本记录列表
base.reg( 'PQCopyLogList', 'SMsgHead',
    {
    }, 729938598
)

-- 返回副本记录列表
base.reg( 'PRCopyLogList', 'SMsgHead',
    {
        { 'data', { 'indices', 'SCopyLog' } },
    }, 1520184157
)

-- 挑战boss
base.reg( 'PQCopyBossFight', 'SMsgHead',
    {
        { 'mopup_type', 'uint8' },		-- 挑战boss类型 [ kCopyMopupTypeNormal, kCopyMopupTypeElite ]
        { 'boss_id', 'uint32' },		-- 挑战boss的 monster_id
    }, 257944230
)

-- 返回挑战boss战斗数据
base.reg( 'PRCopyBossFight', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },		-- 战斗Id
        { 'seed', 'uint32' },		-- 战斗随机种子
        { 'fight', 'SFight' },		-- 战斗数据
        { 'coins', { 'array', 'S3UInt32' } },		-- 战斗掉落记录
    }, 1415847306
)

-- 挑战boss战斗确认
base.reg( 'PQCopyBossFightCommit', 'SMsgHead',
    {
        { 'fight_id', 'uint32' },		-- 副本战斗Id
        { 'order_list', { 'array', 'SFightOrder' } },		-- 战斗技能出手LOG 
        { 'fight_info_list', { 'array', 'SFightPlayerSimple' } },		-- 战斗结束时候的信息
    }, 273326454
)

-- 副本区域通关协议返回
base.reg( 'PRCopyAreaData', 'SMsgHead',
    {
        { 'data', 'SAreaLog' },		-- 副本区域数据
    }, 1607507845
)

-- 副本区域全星通关奖励领取
base.reg( 'PQCopyAreaPresentTake', 'SMsgHead',
    {
        { 'mopup_type', 'uint8' },		-- 副本扫荡类型 [ kCopyMopupTypeNormal | kCopyMopupTypeElite ]
        { 'area_attr', 'uint8' },		-- 副本区域属性 [ kCopyAreaAttrPass | kCopyAreaAttrFullStar ]
        { 'area_id', 'uint32' },		-- 副本区域id( int( Copy.xls->id / 1000 ) )
    }, 302285013
)

base.reg( 'PRCopyAreaPresentTake', 'SMsgHead',
    {
        { 'mopup_type', 'uint8' },
        { 'area_attr', 'uint8' },
        { 'area_id', 'uint32' },
    }, 1845809709
)

-- 副本扫荡
base.reg( 'PQCopyBossMopup', 'SMsgHead',
    {
        { 'mopup_type', 'uint8' },		-- 副本扫荡类型 [ kCopyMopupTypeNormal | kCopyMopupTypeElite ]
        { 'boss_id', 'uint32' },		-- monster_id
        { 'count', 'uint32' },		-- 扫荡次数
    }, 730523402
)

-- 返回扫荡结果
base.reg( 'PRCopyBossMopup', 'SMsgHead',
    {
        { 'mopup_type', 'uint8' },
        { 'boss_id', 'uint32' },
        { 'coins', { 'array', 'array', 'S3UInt32' } },		-- 扫荡获得, 一维数组为扫荡次数索引
    }, 2079542214
)

-- 重置副本扫荡
base.reg( 'PQCopyMopupReset', 'SMsgHead',
    {
        { 'mopup_type', 'uint8' },		-- 副本扫荡类型 [ kCopyMopupTypeNormal | kCopyMopupTypeElite ]
        { 'boss_id', 'uint32' },
    }, 286952083
)

-- 返回副本扫荡记录
base.reg( 'PRCopyMopupData', 'SMsgHead',
    {
        { 'mopup_type', 'uint8' },		-- 副本扫荡类型 [ kCopyMopupTypeNormal | kCopyMopupTypeElite ]
        { 'mopup_attr', 'uint8' },		-- 副本值类型 [ kCopyMopupAttrRound | kCopyMopupAttrTimes | kCopyMopupAttrReset ]
        { 'boss_id', 'uint32' },		-- 0 为需要将相关类型所有扫荡次数同时重置为 value
        { 'value', 'uint32' },		-- 扫荡次数
    }, 1230975462
)

-- 申请最近的竞技log
base.reg( 'PQCopyFightLog', 'SMsgHead',
    {
    }, 773405342
)

base.reg( 'PRCopyFightLog', 'SMsgHead',
    {
        { 'fightlog_list', { 'indices', 'array', 'SCopyFightLog' } },		-- 战斗log
    }, 1224955052
)

base.reg( 'PQCopyFightLogLoad', 'SMsgHead',
    {
        { 'copy_id', 'uint32' },
    }, 860903992
)

base.reg( 'PRCopyFightLogLoad', 'SMsgHead',
    {
        { 'copy_id', 'uint32' },
        { 'list', { 'array', 'SCopyFightLog' } },
    }, 2002119907
)

base.reg( 'PQCopyFightLogSave', 'SMsgHead',
    {
        { 'copy_id', 'uint32' },
        { 'list', { 'array', 'SCopyFightLog' } },
    }, 252912344
)


