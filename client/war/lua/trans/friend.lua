local const = trans.const
local err = trans.err
local base = trans.base

const.kPathFriendSend		= 281860286		-- 好友赠送
const.kFriendGroupFriendMax		= 300		-- 好友上限
const.kFriendGroupStrangerMax		= 20		-- 陌生人上限
const.kFriendGroupBlackMax		= 100		-- 黑名单上限
const.kFriendGroupFriend		= 1		-- 好友
const.kFriendGroupStranger		= 2		-- 陌生人
const.kFriendGroupBlack		= 3		-- 黑名单
const.kFriendGroupMin		= 1		-- 好友分组最小值
const.kFriendGroupMax		= 3		-- 好友分组最大值
const.kFriendGiveOne		= 1		-- 赠送活跃度
const.kFriendGiveTwo		= 2		-- 赠送物品

err.kErrFriendNoExist		= 490289517		--好友数据不存在
err.kErrFriendExist		= 1695025934		--好友已存在
err.kErrFriendUpdateParam		= 766246230		--参数操作错误
err.kErrFriendGroupNotExist		= 124451776		--分组不存在
err.kErrFriendUpdateNoModified		= 2074697868		--无修改请求
err.kErrFriendNormalMax		= 818456875		--好友已达上限
err.kErrFriendBlackMax		= 343459166		--黑名单已达上限
err.kErrFriendSelf		= 2099224127		--不能加自己为好友
err.kErrFriendOffline		= 1655785705		--对方不在线
err.kErrFriendNotOpenForSelf		= 127496527		--未开启好友功能
err.kErrFriendNotOpen		= 190831468		--对方未开启好友功能
err.kErrFriendNoExistMine		= 160051431		--你非对方好友
err.kErrFriendActiveScoreNoEnough		= 308820968		--赠送的活跃度不够
err.kErrFriendActiveScoreLimit		= 1685755119		--现在还不能赠送活跃度
err.kErrFriendItemSendNumLimit		= 412669810		--赠送数量太多
err.kErrFriendItemMaxNumLimit		= 1582419102		--赠送数量太多
err.kErrFriendActiveScoreMaxNumLimit		= 1066440386		--对方人气很高哦，不能再赠送了
err.kErrFriendItemEorror		= 243558005		--物品赠送类型不符
err.kErrFriendItemNoNum		= 1326730937		--赠送物品数量不能为空
err.kErrFriendItemNumNoEnough		= 1624525327		--赠送物品数量不够
err.kErrFriendFightNoOpenSinglearenaOne		= 997390259		--竞技场未开放，不能挑战
err.kErrFriendFightNoOpenSinglearenaTwo		= 260992085		--对方竞技场未开放，不能挑战
err.kErrFriendSelfLevelLimit		= 723363019		--等级不够，不能添加好友
err.kErrFriendFrinedLevelLimit		= 1925873372		--对方等级不够，不能被添加好友

-- 好友-黄少卿
base.reg( 'SUserFriend', nil,
    {
        { 'friend_id', 'uint32' },
        { 'friend_favor', 'uint32' },		-- 好感度
        { 'friend_group', 'uint8' },		-- 好友分组
        { 'on_time', 'uint32' },		-- 上线时间( on_time == 0 为不在线 )
        { 'friend_avatar', 'uint16' },		-- 好友头像
        { 'friend_level', 'uint32' },		-- 好友战队等级
        { 'friend_name', 'string' },		-- 好友名字
        { 'friend_gname', 'string' },		-- 好友公会名字
    }
)

base.reg( 'SFriendLimit', nil,
    {
        { 'friend_id', 'uint32' },		-- 好友id
        { 'time_limit', 'uint32' },		-- 最后一次赠送时间点  针对活跃度
        { 'type_limit', 'uint32' },		-- 当天重置时间点    针对物品
        { 'num_limit', 'uint32' },		-- 数量限制
    }
)

base.reg( 'SFriendData', nil,
    {
        { 'target_id', 'uint32' },
        { 'target_avatar', 'uint16' },
        { 'target_level', 'uint32' },
        { 'target_name', 'string' },
    }
)

-- ============================数据中心========================
base.reg( 'CFriend', nil,
    {
        { 'user_id_friend', { 'indices', 'SFriendData' } },
    }
)

-- @@请求好友列表
base.reg( 'PQFriendList', 'SMsgHead',
    {
    }, 511240001
)

-- @@请求好友限制列表
base.reg( 'PQFriendLimitList', 'SMsgHead',
    {
    }, 961802699
)

-- @@加好友
base.reg( 'PQFriendMake', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 对方角色id
        { 'group', 'uint8' },		-- 好友分组
    }, 227513378
)

-- @@加好友
base.reg( 'PQFriendMakeByName', 'SMsgHead',
    {
        { 'target_name', 'string' },		-- 对方角色名字  默认为好友分组
    }, 606583061
)

-- @@全部加好友
base.reg( 'PQFriendMakeAll', 'SMsgHead',
    {
        { 'target_id_list', { 'array', 'uint32' } },		-- 对方角色id列表    默认为好友分组
    }, 698155518
)

-- @@好友分组修改
base.reg( 'PQFriendUpdate', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 对方角色id
        { 'set_type', 'uint8' },		-- 操作方式(只接受 kObjectUpdate, kObjectDel)
        { 'group', 'uint8' },		-- 分组修改
    }, 455135086
)

-- @@请求加好友
base.reg( 'PQFriendRequest', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 对方角色id
    }, 638251957
)

-- @@消息
base.reg( 'PQFriendMsg', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 对方角色id
        { 'msg', 'string' },		-- 消息正文
    }, 654453972
)

-- @@确定加好友
base.reg( 'PQFriendOK', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 发送加好友者id，对应SFriendRMake中targetid
    }, 518108368
)

-- @@好友推荐请求
base.reg( 'PQSFriendRecommend', 'SMsgHead',
    {
    }, 896220725
)

-- @@好友挑战
base.reg( 'PQFriendFightApply', 'SMsgHead',
    {
        { 'friend_id', 'uint32' },		-- 好友角色id
    }, 1017508629
)

-- @@赠送
base.reg( 'PQFriendGive', 'SMsgHead',
    {
        { 'friend_id', 'uint32' },		-- 好友角色id
        { 'give_type', 'uint8' },		-- kFriendGiveOne kFriendGiveTwo
        { 'active_score', 'uint32' },		-- 活跃度
        { 'item_list', { 'array', 'S3UInt32' } },		-- cate=为背包类型 objid=物品guid val=赠送数量
    }, 99204853
)

-- @@聊天
base.reg( 'PQFriendChatContent', 'SMsgHead',
    {
        { 'friend_id', 'uint32' },		-- 好友guid
        { 'text', 'string' },		-- 文本内容
        { 'sound', 'bytes' },		-- 声音内容
        { 'length', 'uint32' },		-- 声音长度(ms)
        { 'avater', 'uint32' },		-- 角色头像
        { 'text_ext', 'string' },		-- 文本扩展
    }, 952948261
)

-- @@拉黑
base.reg( 'PQFriendBlack', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 对方角色id
    }, 951417580
)

-- @@拉黑
base.reg( 'PQFriendBlackByName', 'SMsgHead',
    {
        { 'target_name', 'string' },		-- 对方角色名字
    }, 510925146
)

-- 返回好友列表
base.reg( 'PRFriendList', 'SMsgHead',
    {
        { 'friend_list', { 'array', 'SUserFriend' } },		-- 好友列表
    }, 1257022854
)

-- 返回好友限制列表
base.reg( 'PRFriendLimitList', 'SMsgHead',
    {
        { 'limit_list', { 'array', 'SFriendLimit' } },		-- 好友限制列表
    }, 2023511142
)

-- 被加好友通知
base.reg( 'PRFriendMake', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 对方角色id
        { 'info', 'SUserFriend' },		-- 好友数据
    }, 1500965640
)

-- 请求加好友
base.reg( 'PRFriendRequest', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 请求者角色id
        { 'info', 'SUserFriend' },
    }, 1217836923
)

-- 好友数据更新
base.reg( 'PRFriendUpdate', 'SMsgHead',
    {
        { 'info', 'SUserFriend' },		-- 好友数据
        { 'set_type', 'uint8' },		-- 修改类型
    }, 1160251020
)

-- 好友限制数据更新
base.reg( 'PRFriendLimitUpdate', 'SMsgHead',
    {
        { 'info', 'SFriendLimit' },		-- 好友限制数据
        { 'set_type', 'uint8' },		-- 修改类型
    }, 1518846405
)

-- 返回消息
base.reg( 'PRFriendMsg', 'SMsgHead',
    {
        { 'friend_id', 'uint32' },		-- 好友角色id
        { 'purview', 'uint8' },		-- 用户权限
        { 'msg', 'string' },		-- 消息正文
    }, 1577180918
)

-- 好友推荐回复
base.reg( 'PRFriendRecommend', 'SMsgHead',
    {
        { 'target_id_list', { 'array', 'uint32' } },		-- 好友列表，没有好友可推荐，则列表为空 <兼容>
        { 'friend_list', { 'array', 'SUserFriend' } },
    }, 1933510749
)

-- @@赠送
base.reg( 'PRFriendGive', 'SMsgHead',
    {
        { 'friend_id', 'uint32' },		-- 好友角色id
        { 'give_type', 'uint8' },		-- kFriendGiveOne
        { 'active_score', 'uint32' },		-- 活跃度
        { 'item_list', { 'array', 'S2UInt32' } },		-- 赠送数据 first = item_id   second = 数量
    }, 1458158398
)

base.reg( 'PRFriendChatContent', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 说话者id
        { 'name', 'string' },		-- 角色名
        { 'level', 'uint32' },		-- 等级
        { 'text', 'string' },
        { 'sound', 'bytes' },
        { 'length', 'uint32' },		-- 声音长度(ms)
        { 'avater', 'uint32' },		-- 角色头像
        { 'text_ext', 'string' },		-- 文本扩展
    }, 1507929832
)

-- 赠送时，如果对方不能接收时返回给赠送者的协议
base.reg( 'PRFriendGiveLimit', 'SMsgHead',
    {
        { 'target_id', 'uint32' },		-- 接受者id
        { 'target_name', 'string' },		-- 接受者名字
        { 'max_num', 'uint32' },		-- 接受者现在最多能接受的赠品数量
    }, 1699757452
)


