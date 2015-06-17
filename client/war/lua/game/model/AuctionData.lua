
AuctionData = {}
local salelist = {} --出售纪录list
local wshangjialist = {} --未上架list
local shangjialist = {}  --上架list
local storelist = {}  --分别为1甲板，2锁甲，3皮甲，4布甲 再分t1，t2,t3,t4,t5,t6
local updata = {} --上架
local downdata = {} --下架
local buydata = {} --购买
local changelist = {} --修改价格列表
AuctionData.flag = false    --是否进入
AuctionData.buyflag = false -- 默认不是购买
AuctionData.Uppersent = 100
for i = 1,4,1 do
   storelist [i] = {}
   for k = 1 ,6 ,1 do 
      storelist[i][k] = {}
   end 
   
end 
function AuctionData.Changebuy(data) 
      for i = 1,4,1 do
           for k = 1 ,6 ,1 do 
               if storelist[i][k] ~= nil then 
                  for key ,v in pairs(storelist[i][k]) do 
                      if v~= nil then 
                          if v.guid == data.guid then 
                            v.percent = data.percent
                            v.count = data.coin.val 
                            local market = findMarket(data.coin.objid)
--                            local money = findGlobal("active_score_price").data
                            local money = 1 
                            v.money = money *market.value*v.percent/100
                            if v.count == 0 then 
                               table.remove(storelist[i][k],key)
                            end 
                          end 
                      end 
                  end 
               end 
           end 
       end  
end 

function AuctionData.getChange()
    return changelist
end 
function AuctionData.setAuctionTip( data)
    buydata = {}
    buydata = data 
    LogMgr.debug("buydata .. " .. debug.dump(buydata))
    AuctionTip:createView()
end 

function AuctionData.setAuctionDown(data)
    downdata = {}
    downdata = data
--    LogMgr.debug("downdata .. " .. debug.dump(downdata))
    Command.run('ui show' ,'AuctionDown', PopUpType.SPECIAL)
end 

function AuctionData.setAuctionUp(data)
   updata = {}
   updata = data
--   LogMgr.debug("updata .. " .. debug.dump(updata))
   Command.run('ui show' ,'AuctionUp', PopUpType.SPECIAL)
end 


function AuctionData.setAuctionStore() 
--    Command.run( 'buylist')
    -- 默认材料1，板甲4 ，t为n
    local t = 1
--    if PaperSkillData.getJSkill() ~= nil then 
--        t = PaperSkillData.getJSkill().collect_skill_level
--        t = 1 
--    end 
    local level = gameData.getSimpleDataByKey("team_level")
    if level >= 35 and level <= 49 then 
        t = 2
    elseif level >= 50 and level <= 64 then 
        t = 3
    elseif level >= 65 and level <= 79 then 
        t = 4
    elseif level >= 80 and level <= 94 then 
        t = 5
    elseif level >= 95 and level <= 109 then 
        t = 6
    end 
    Command.run( 'refreshbuylist', const.kMarketCargoTypeMaterial , 4, t)
    Command.run("loading wait show" , "auctionui")  
    AuctionData.setSaleList(gameData.user.market_log)
    Command.run( 'salelist')
    AuctionData.setWshangjiaList()
    
    EventMgr.dispatch(EventType.AuctionUIsetT, t )
end 

--出售纪录
function AuctionData.setSaleList(msg)
--      LogMgr.debug("intosetSaleList")
      salelist = {}
      for k ,data in pairs(msg) do 
          if data ~= nil then 
              local name = data.name 
              local coin = data.coin
              local item = findItem(coin.objid)
              local thingname = "物品"
              if item ~= nil then 
                 thingname = item.name 
              end 
              local count = coin.val
              local time = data.time
              local money = data.price
              local shuishou = money * 0.1
              local string = DateTools.toDateString(time)
              local string2 = DateTools.toTimeString(time)
              local timeid = string .. " " .. string2
--              local timeid = year .. "-" .. month .."-" .. day .. " " .. hour .. ":" .. minute .. ":" .. second    
              if count ~= nil and count ~= 0 and item ~= nil then 
                 table.insert(salelist , {time = timeid , name =name ,thingname = thingname,count = count ,money = money, suishou = shuishou})
              end 
          end 
      end 
--      salelist = {}
--      for i = 1 ,50 , 1 do 
--          local string = DateTools.toDateString(gameData.getServerTime())
--          local string2 = DateTools.toTimeString(gameData.getServerTime())
--          local timeid = string .. " " .. string2
--          table.insert(salelist , {time = timeid , name ="name" ,thingname = i,count = i ,money = i, suishou = i})
--      end 
end 

--未上架
function AuctionData.setWshangjiaList()
    local leixin = const.kCoinActiveScore
    local coinbg = 1
    local bgid = 1 
    local coin = 1 
    local name = ""
--    local money = findGlobal("active_score_price").data
    local money = 1
    local coincount = CoinData.getCoinByCate(const.kCoinActiveScore)
    local item = {}
    wshangjialist = {}
--    if coincount ~= 0 then 
--       table.insert(wshangjialist,{shangjia = 2 ,count = coincount ,bgid = bgid ,coinbg = coinbg ,coin = const.kCoinActiveScore ,name = "手工活力" , money = money , leixin = leixin ,biaoqian = 0})
--    end 
    local itemList = ItemData.getTable( const.kBagFuncCommon )
--    LogMgr.debug("itemList" .. debug.dump(itemList))
    if itemList ~= nil then 
        for k ,v in pairs(itemList) do 
            local cointype = const.kCoinMoney
            local id = v.item_id
            local count = v.count
            local list = findMarket(id)
            local flags = v.flags 
            local t = 1
--            LogMgr.debug ("flags .. " .. flags)
            if list ~= nil and flags == 0 then 
                local market = list
                t = AuctionData.getTByLevel(market)
                item = findItem(id)
                leixin = const.kCoinItem
                coinbg =item.quality
                bgid = coinbg 
                coin = id 
                name = item.name 
--                money = findGlobal("active_score_price").data
                money = 1 
                money = list.value * money
                leixin = const.kCoinItem
                table.insert(wshangjialist,{shangjia = 2 ,cointype = cointype,t = t,count = count , bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name , money = money , leixin = leixin ,biaoqian = 0})
            end 
        end 
    end 
    LogMgr.debug(debug.dump(wshangjialist))
end 

--进入修改界面
function AuctionData.setModifylist(msg)
    changelist = msg
    Command.run('ui show' ,'AuctionModify', PopUpType.SPECIAL)
end 

function AuctionData.getModifylist()
    return changelist
end 

-- 通过登记获得level
function AuctionData.getTByLevel(list)
    local t = 1
    local market = list
    if market.level >= 20 and market.level < 35 then 
        t = 1
    elseif market.level >= 35 and market.level < 50 then 
        t = 2
    elseif market.level >= 50 and market.level < 65 then 
        t = 3 
    elseif market.level >= 65 and market.level < 80 then 
        t = 4 
    elseif market.level >= 80 and market.level < 95 then 
        t = 5
    elseif market.level >= 95 and market.level < 110 then 
        t = 6
    elseif market.level >= 110 and market.level < 125 then 
        t = 7
    elseif market.level >= 125 and market.level < 140 then 
        t = 8
    elseif market.level >= 140 and market.level < 155 then 
        t = 9
    elseif market.level >= 155 then 
        t = 10
    end 
    return t
end 

--上架
function AuctionData.setShangjialist(msg)
        AuctionData.setWshangjiaList()
        shangjialist = {}
--        LogMgr.debug("shangjia " .. debug.dump(msg) )
        for k ,v in pairs(msg) do
            local cointype = const.kCoinMoney
            local coinbg = 1
            local t = 1
            local name = "手工活力"
            local leixin = const.kCoinItem
--            local money = findGlobal("active_score_price").data
            local money = 1
            if v.coin.cate == const.kCoinActiveScore then
                 name = "手工活力"
                 leixin = const.kCoinActiveScore
            elseif v.coin.cate == const.kCoinItem then 
                local item = findItem(v.coin.objid) 
                coinbg = item.quality
                name = item.name 
                leixin = const.kCoinItem
--                LogMgr.debug("debug .." .. debug.dump(v.coin))
                local list = findMarket(v.coin.objid)
                t = AuctionData.getTByLevel(list)
                money = list.value
            end    
        
            money = money * v.percent /100
            local count = v.coin.val 
            local bgid = coinbg
            local coin = v.coin.objid 
            local percent = v.percent 
            local cargo_id = v.cargo_id
            local role_id = v.role_id
            local start_time = v.start_time
            if count ~= nil and count ~= 0 and money ~= 0 then 
            table.insert(shangjialist,{t = t ,cointype = cointype ,count = count,start_time = start_time,role_id = role_id ,cargo_id = cargo_id,percent = percent ,shangjia = 1 ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name =name , money = money , leixin = leixin ,biaoqian = 0})
            end 
        end     
end 


--局部t 请求更新
function AuctionData.setUntilList(msg)
    local list = {20, 35, 50, 65, 80, 95, 110, 125, 140, 155}
    --转化level
    for key ,value in pairs(list) do
        if msg.level == value then 
           msg.level = key 
           break
        end 
    end 
    storelist[1][msg.equip][msg.level] = {} -- 归为一类
    local data = msg.data 
    for k ,v in pairs(data) do
        if v ~= nil then 
            local market = findMarket(v.coin.objid)
            if market ~= nil then 
                local t = 1
                t = AuctionData.getTByLevel(market)
                local type = market.type
                local value = v
                local leixin = const.kCoinItem
                local count = v.coin.val 
                local percent = v.percent
                local coin = v.coin.objid
                local cointype = const.kCoinMoney
                local guid = v.cargo_id
                --            LogMgr.debug("coin .. " .. debug.dump(v.coin))
                local item = findItem(v.coin.objid) 
                local coinbg = 1 
                local name = "name"
                if item ~= nil then 
                    coinbg =item.quality
                    name = item.name
                end 
                local bgid = coinbg 

                local market = findMarket(v.coin.objid)
                local money = 1
                if market ~= nil then 
                    money = market.value * money * percent/100
                end 
                local cargo_id = v.cargo_id
                local roleid = v.role_id
                if item ~= nil and count~= 0 and money ~= 0 then 
                    table.insert(storelist[1][msg.equip][msg.level], {t = t ,roleid = roleid, cointype= cointype ,value = value ,percent = percent , cargo_id = cargo_id, shangjia = 3 ,guid = guid ,count = count , bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name , money = money , leixin = leixin ,biaoqian = 0})
                end 
            end 
        end 
    end 

end 

--所有t
function AuctionData.setStorelist(msg)
    local maxT = 1 
    for j = 1 , 2 do 
        storelist[j] = {}
        for i = 1,4,1 do
            storelist [j][i] = {}
            for k = 1 ,6 ,1 do 
                storelist[j][i][k] = {}
            end 
        end 
    end 
    for k ,v in pairs(msg) do
        if v ~= nil then 
            local market = findMarket(v.coin.objid)
            if market ~= nil then 
                local t = 1
                t = AuctionData.getTByLevel(market)
                local type = market.type
                if maxT < type then 
                   maxT = type
                end 
                local value = v
                local leixin = const.kCoinItem
                local count = v.coin.val 
                local percent = v.percent
                local coin = v.coin.objid
                local cointype = const.kCoinMoney
                local guid = v.cargo_id
    --            LogMgr.debug("coin .. " .. debug.dump(v.coin))
                local item = findItem(v.coin.objid) 
                local coinbg = 1 
                local name = "name"
                if item ~= nil then 
                   coinbg =item.quality
                   name = item.name
                end 
                local bgid = coinbg 
          
                local market = findMarket(v.coin.objid)
                local money = findGlobal("active_score_price").data
                local money = 1
                if market ~= nil then 
                   money = market.value * money * percent/100
                end 
                local cargo_id = v.cargo_id
                local roleid = v.role_id
                if item ~= nil and count~= 0 and money ~= 0 then 
                   table.insert(storelist[market.group][type][t], {t = t ,roleid = roleid, cointype= cointype ,value = value ,percent = percent , cargo_id = cargo_id, shangjia = 3 ,guid = guid ,count = count , bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name , money = money , leixin = leixin ,biaoqian = 0})
                end 
            end 
        end 
    end 
end 

function AuctionData.getMarketOne(item_id,count)
   local list = {}
   local hasCount = 0
   local price = 0
   if storelist ~= nil then 
      for k1 , v1 in pairs (storelist) do 
          if v1 ~= nil then 
             for k2 ,v2 in pairs(v1) do 
                 if v2 ~= nil then 
                     for k3 ,v3 in pairs(v2) do 
                         if v3 ~= nil and v3.coin == item_id then
                            hasCount = hasCount + v3.count
                            if hasCount >= count then 
                              table.insert( list, {first=v3.value.guid, second=v3.count-( hasCount - count ) } )
                              price = price + ( v3.count-( hasCount - count ) ) * v3.percent
                              return list, price
                            else
                              table.insert( list, {first=v3.value.guid, second=v3.count} )
                              price = price + v3.count * v3.percent
                            end
                         end 
                     end 
                 end  
             end 
          end 
      end 
   end 
   return nil 
end 

function AuctionData.sendRefresh () 
--   Command.run( 'buyref', flag)
--    Command.run( 'buylist')
end 

function AuctionData.refreshtime()
   local time = VarData.getVar( 'market_ref_time' ) 
--   time = 0
   return time 
end 

function AuctionData.getAuctionTip()
    return buydata
end

function AuctionData.getAuctionDown()
    return downdata
end 

function AuctionData.getAuctionUp()
   return updata
end 

function AuctionData.getStoreList(data)
    if data ~= nil then 
       data[1] = 1
       return storelist[data[1]][data[2]][data[3]]
    end 
end 

function AuctionData.getSaleList()
--    salelist = {}
--    for i = 1 ,50 , 1 do 
--        local string = DateTools.toDateString(gameData.getServerTime())
--        local string2 = DateTools.toTimeString(gameData.getServerTime())
--        local timeid = string .. " " .. string2
--        table.insert(salelist , {time = timeid , name ="name" ,thingname = i,count = i ,money = i, suishou = i})
--    end 
    return salelist 
end 

function AuctionData.getWshangjiaList()
    AuctionData.setWshangjiaList()
    return wshangjialist 
end 

function AuctionData.getShangjialist()
    return shangjialist
end 
