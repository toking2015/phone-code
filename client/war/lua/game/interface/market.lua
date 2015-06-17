
-- @@请求买方列表 (刷新调用)
Command.bind( 'buylist', 
    function()
        trans.send_msg( 'PQMarketBuyList', {})
    end 
)

--刷新买方列表
Command.bind( 'refreshbuylist', 
    function( type , equip ,level ) 
        local list = {20, 35, 50, 65, 80, 95, 110, 125, 140, 155}
        level = list[level]
        trans.send_msg( 'PQMarketCustomBuyList', { equip = equip,level = level})
    end 
)

-- @@请求卖方列表
Command.bind( 'salelist', 
    function()
        trans.send_msg( 'PQMarketSellList', {})
    end 
)

-- 请求上架货物
Command.bind( 'shangjia', 
    function(coin , percent)
        trans.send_msg( 'PQMarketCargoUp', {coin = coin ,percent = percent})
    end 
)

-- 请求下架
Command.bind('xiajia' ,
    function (cargo_id)
        trans.send_msg( 'PQMarketCargoDown', {cargo_id = cargo_id})
    end 
)
-- 购买货物
Command.bind('auction buy',
    function (guid , count , value,percent)
        AuctionData.buyflag = true
        trans.send_msg( 'PQMarketBuy', {guid = guid ,count = count, value = value,percent = percent})
    end
)

-- 批量购买
Command.bind('auction buy list',
    function (_coins, _path )
        trans.send_msg( 'PQMarketBatchBuy', {cargos = _coins, path = _path})
    end
)

-- 批量获取购买数据
Command.bind('auction match list',
    function (_coins)
        trans.send_msg( 'PQMarketBatchMatch', {coins = _coins})
    end
)

-- 批量购买
-- 批量购买列表      cate->guid用户内唯一, objid->count购买数量, val->value需要花费的金币
Command.bind('auction buy all',
    function (coins, percent,value)
        trans.send_msg( 'PQMarketBuyAll', {coins = coins ,percent = percent , value = value })
    end
)

-- 请求货物修改
Command.bind('marketxiugai',
    function (cargo_id,percent)
        LogMgr.debug("修改")
        trans.send_msg( 'PQMarketCargoChange', {cargo_id = cargo_id ,percent = percent})
    end
)