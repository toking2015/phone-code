
--by weihao

-- 返回买方列表(购买的返回)
trans.call.PRMarketBuyList = function(msg)
--    print(debug.dump(msg.data))
    AuctionData.setStorelist(msg.data)
    if PopMgr.hasWindow("AuctionUI") then
        Command.run( 'refreshAuctionBuy')
        --顺便刷新购买纪录
        AuctionData.setSaleList(gameData.user.market_log)
    end 
end 

trans.call.PRMarketCustomBuyList = function(msg)
     AuctionData.setUntilList(msg)
--     print("msg .. " .. debug.dump(msg))
     if PopMgr.hasWindow("AuctionUI") then
        Command.run( 'refreshAuctionBuy')
        Command.run("loading wait hide","auctionui")
     end 
end 

-- 返回买方单数据
trans.call.PRMarketBuyData = function(msg)
    --    LogMgr.debug("修改价格后 我需要刷行上架信息，以及某个商品的价格")
    if msg.data ~= nil then 
        AuctionData.Changebuy(msg.data) 
    end 
    if AuctionData.buyflag == true then  
       --购买时候刷新购买列表
       AuctionData.setSaleList(gameData.user.market_log)
--       Command.run( 'refreshAuctionGM')
       
       AuctionData.buyflag = false 
    end 

 
end 

-- @@返回卖方列表 (上架信息返回)
trans.call.PRMarketSellList = function(msg)
    LogMgr.debug("xuweihao_PRMarketSellList返回卖方列表")
    AuctionData.setShangjialist(msg.data)
    if PopMgr.hasWindow("AuctionUI") then
        EventMgr.dispatch(EventType.AuctionSellView)
    end
end 

-- @@返回卖方数据（上架后的返回）
trans.call.PRMarketSellData = function(msg)
    LogMgr.debug("xuweihao_PRMarketSellData返回卖方data")
    LogMgr.debug(debug.dump(msg))
    if PopMgr.hasWindow("AuctionUI") then
        Command.run( 'salelist')  --上架数据改变
    end 
end 


-- 返回单条日志( 卖品售出后 )
trans.call.PRMarketLogData = function(msg)
--    LogMgr.error("xuweihao_PRMarketLogData返回单条日志( 卖品售出后 )")
--    LogMgr.error(debug.dump(msg))
    table.insert(gameData.user.market_log,msg.data)
    AuctionData.setSaleList(gameData.user.market_log)
    if PopMgr.hasWindow("AuctionUI") then
        EventMgr.dispatch(EventType.AuctionRecordView)
    end 
end 

trans.call.PRMarketBatchMatch = function (msg)
    EventMgr.dispatch( EventType.MarketBatchMatch, msg )
end

trans.call.PRMarketBatchBuy = function (msg)
    EventMgr.dispatch( EventType.MarketBatchBuy, msg )
    if PopMgr.hasWindow("AuctionUI") then
        Command.run( 'refreshbuylist', AuctionBuy.getSelectGounp() , AuctionBuy.getSelectType(), AuctionUI:getT()) 
        EventMgr.dispatch(EventType.AuctionSellView)
    end 
end

--广播
trans.call.PRMarketCargoChange = function (msg)
    LogMgr.debug("价格修改")  
    Command.run( 'salelist')    
end 

--全部购买的返回
trans.call.PRMarketBuyAll = function(msg)
    if msg.result == 0 then
       TipsMgr.showError('购买成功')
    else 
       TipsMgr.showError('购买失败')
    end  
    if PopMgr.hasWindow("AuctionUI") then
       Command.run( 'refreshbuylist', AuctionBuy.getSelectGounp() , AuctionBuy.getSelectType(), AuctionUI:getT()) 
       EventMgr.dispatch(EventType.AuctionSellView)
    end 
end 

trans.call.PRMarketBuy = function (msg)
    local function showMarketTip(str)
        showMsgBox( "[image=alert.png][font=ZH_10]" .. str.. "[btn=one]confirm.png", function()
            if PopMgr.hasWindow("AuctionUI") then
                Command.run( 'refreshbuylist', AuctionBuy.getSelectGounp() , AuctionBuy.getSelectType(), AuctionUI:getT()) 
                Command.run( 'salelist')
                EventMgr.dispatch(EventType.AuctionSellView)
            end 
        end)
    end 
   
   local str = nil 
   if msg.result == err.kErrMarketNotService then 
    --拍卖行服务未开启
--        LogMgr.debug("拍卖行服务未开启")
        str = "拍卖行服务未开启"
   elseif msg.result == err.kErrMarketCargoNoExist then 
    --货物不存在
        str = "货物不存在"
   elseif msg.result == err.kErrMarketCargoNoExchange then 
    --货物不可交易
        str = "货物不可交易"
   elseif msg.result == err.kErrMarketPercentRound then 
    --货物上架价格指数范围错误
        str = "货物上架价格指数范围错误"
   elseif msg.result == err.kErrMarketCargoCate then 
    --货物类型错误
        str = "货物类型错误"
   elseif msg.result == err.kErrMarketCargoNotEnough then 
    --货物售卖数量不足
        str = "货物售卖数量不足"
   elseif msg.result == err.kErrMarketCargoPurview then
    --操作权限不足
        str = "操作权限不足"
   elseif msg.result == err.kErrMarketCargoChange then
    --数据变更
        str = "数据变更,请重新购买"
   elseif msg.result == err.kErrMarketParam then
    --参数不合法
        str = "参数不合法"
   elseif msg.result == err.kErrMarketNotPaperSkill then
    --还没选择手工技能
        str = "还没选择手工技能"
   elseif msg.result == err.kErrMarketRefNotToTime then
    --免费刷新时间未到
        str = "免费刷新时间未到"
   else
        Command.run("loading wait hide","auctionui")
        TipsMgr.showSuccess("购买成功", nil, nil, nil)
        if PopMgr.hasWindow("AuctionUI") then
            Command.run( 'refreshbuylist', AuctionBuy.getSelectGounp() , AuctionBuy.getSelectType(), AuctionUI:getT()) 
            Command.run( 'salelist')
        end

   end   
   if str ~= nil then 
      Command.run("loading wait hide","auctionui")
      showMarketTip(str)
   end 

end 