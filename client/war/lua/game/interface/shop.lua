--by weihao
-- 商店

-- 购买
Command.bind( 'buy thing', 
    function(_id ,_count)
        LogMgr.debug("xuweihao buy thing")
        LogMgr.debug("id ".. _id )
        LogMgr.debug("count " .. _count)
        trans.send_msg( 'PQShopBuy', {id = _id ,count = _count})
    end 
)

-- 刷新每日商品
Command.bind( 'refresh meiri', 
    function()
--        LogMgr.debug("xuweihao refresh")
        trans.send_msg( 'PQShopRefresh',{})
    end 
)

-- 请求购买纪录
Command.bind( 'buy log', 
    function()
--        LogMgr.debug("xuweihao buylog")
        trans.send_msg( 'PQShopLog',{})
    end 
)

-- 大墓地商店 刷新请求
Command.bind( 'refresh tomb', 
    function()
--        LogMgr.debug("xuweihao buylog")
        trans.send_msg( 'PQShopTombRefresh',{})
    end 
)

