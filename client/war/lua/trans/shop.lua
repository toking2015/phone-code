local const = trans.const
local err = trans.err
local base = trans.base

const.kShopTypeMedal		= 1		-- 勋章商店
const.kShopTypeCommon		= 2		-- 游戏商城
const.kShopTypeMystery		= 3		-- 神秘商店
const.kShopTypeTomb		= 4		-- 大墓地商店
const.kShopTypeGuild		= 5		-- 公会商店
const.kShopTypeAchievementMedal		= 6		-- 竞技场成就商店
const.kShopTypeAchievementTomb		= 7		-- 大墓地成就商店
const.kPathMedalShop		= 170991727		-- 勋章商店购买
const.kPathCommonShop		= 1271127800		-- 游戏商城购买
const.kPathMysteryShop		= 1773888049		-- 神秘商店购买
const.kPathTombShop		= 1977546372		-- 大墓地商店购买
const.kPathClearMasteryCD		= 1082442933		-- 清除商店CD
const.kPathTombShopRefresh		= 16753434		-- 清除大墓地商店限购记录
const.kPathGuildShop		= 1882356240		-- 公会商店购买
const.kPathAchievementMedalShop		= 2119033226		-- 竞技场成就商店购买
const.kPathAchievementTombShop		= 1536045941		-- 大墓地成就商店购买
const.kASCondArenaRank		= 1		-- 竞技场胜利次数达到n次
const.kASCondArenaWinTimes		= 2		-- 竞技场历史排名达到n名
const.kASCondMedalConsume		= 3		-- 竞技场勋章消费过n
const.kASCondTombWinTimes		= 4		-- 大墓地打通n关
const.kASCondTombReset		= 5		-- 大墓地重置n次
const.kASCondTombPass		= 6		-- 大墓地杀死巫妖小克n次


-- 购买记录
base.reg( 'SUserShopLog', nil,
    {
        { 'id', 'uint32' },		-- 商品id
        { 'daily_count', 'uint32' },		-- 本日购买数量
        { 'history_count', 'uint32' },		-- 历史购买数量
    }
)

-- 神秘商店商品
base.reg( 'SUserMysteryGoods', nil,
    {
        { 'id', 'uint32' },		-- 商品id
        { 'buyed_count', 'uint16' },		-- 已购买数量
    }
)

-- 购买
base.reg( 'PQShopBuy', 'SMsgHead',
    {
        { 'id', 'uint32' },		-- 商品id
        { 'count', 'uint32' },		-- 数量
    }, 355460715
)

base.reg( 'PRShopBuy', 'SMsgHead',
    {
        { 'status', 'int8' },		-- 0:失败，1:成功
        { 'id', 'uint32' },		-- 商品id
        { 'count', 'uint32' },		-- 数量
    }, 1696054534
)

-- 神秘商店刷新请求
base.reg( 'PQShopRefresh', 'SMsgHead',
    {
    }, 891445671
)

-- 请求购买记录
base.reg( 'PQShopLog', 'SMsgHead',
    {
    }, 842024592
)

base.reg( 'PRShopLog', 'SMsgHead',
    {
        { 'log', { 'array', 'SUserShopLog' } },
    }, 1391203940
)

-- 购买记录（单独更新）
base.reg( 'PRShopLogSet', 'SMsgHead',
    {
        { 'log', 'SUserShopLog' },
    }, 1510374863
)

-- 神秘商店商品列表
base.reg( 'PRShopMysteryGoods', 'SMsgHead',
    {
        { 'goods_list', { 'array', 'SUserMysteryGoods' } },
    }, 2075346742
)

-- 大墓地商店刷新
base.reg( 'PQShopTombRefresh', 'SMsgHead',
    {
    }, 756738156
)


