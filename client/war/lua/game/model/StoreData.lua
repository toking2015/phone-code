--write by weihao 
StoreData = {}
local djlist = {} --地精数据
local youxilist = {} --游戏数据
local xunzhanlist = {} --勋章数据
local meirilist = {} --每日数据
local achlist = {} -- 竞技场成就数据
local achlist1 = {} -- 大墓地成就数据
--local baselist = {}
local autolist ={} --自动贩卖数据
local wintime = 0 --竞技场胜利多少次
local redflag = {} --红点标记符号
local yongqineed = 20
--VarData.getVar( 'user_step' )

StoreData.Achieve = "MD"
StoreData.isShowAuto = true 
StoreData.TypeXZ = 1  -- 土
StoreData.Type ={
   XZ = 1 , --勋章商店
   YX = 2 , --游戏商店
   MR = 3 , --每日商店
   DJ = 4 , --勇气商店
   GH = 5 , --公会商店
   JJ = 6 , --竞技场成就
   MD = 7   --大墓地成就
}
-- StoreData.SelectType = StoreData.Type.DJ --选择显示那个商店
-- Command.run("ui show", "Store", PopUpType.SPECIAL)

StoreData.SelectType = StoreData.Type.XZ --默认勋章
StoreData.StoreDataType = StoreData.Type.XZ 
StoreData.yongqiflag = false 

function StoreData.getYongqineed()
    yongqineed = VarData.getVar( 'tomb_refreshed_times' )
    return yongqineed
end 
function StoreData.setAutoList()
    autolist ={}
    local itemList = ItemData.getTable( const.kBagFuncCommon )
    for i ,v in pairs(itemList) do 
        if v~= nil then 
           local itemid = v.item_id
           local item = findItem(itemid)
           if item and item.auto_sell ~= nil and item.auto_sell == 1 then 
               local count = v.count
               local guid = v.guid
               local name = item.name
               local coin = item.coin
               local quality = item.quality
               table.insert(autolist,{quality = quality ,coin = coin,name = item.name,itemid = itemid ,count = count , guid = guid})
           end 
        end 
    end 
end 

function StoreData.setWinTime(time)
    wintime = time 
end 

function StoreData.getWinTime()
   return wintime 
end 

--排序
function StoreData.rescort(list)
   local totemlist = {}
   local wupinlist = {}
   local diaowenlist = {}
   for l,v in pairs(list) do 
      if v.goods.cate == const.kCoinItem then --物品
          table.insert (wupinlist,v)
      elseif v.goods.cate == const.kCoinTotem then --图腾
          table.insert (totemlist,v)
      elseif v.goods.cate == const.kCoinGlyph then   --雕文 
          table.insert (diaowenlist,v)
      end 
   end 
   list = {}
   for l ,v in pairs(totemlist)  do 
       table.insert (list,v)
   end 
   for l ,v in pairs(diaowenlist)  do 
       table.insert (list,v)
   end 
   for l ,v in pairs(wupinlist)  do 
       table.insert (list,v)
   end 
   return list 
end 
--独立更新每日
function StoreData.setDailyData(data)
        meirilist = {}
        for key , value1 in pairs(data) do
           local value = findVendible(value1.id) 
           local buyedcount = value1.buyed_count
           local limitcount = 0 
           if value ~= nil then 
              local limitcount = value.daily_limit_count
           end 
           limitcount = 1
           local inflag = true
           local item = 1
           local coinbg = 1
           local bgid = 1
           local coin = 1
           local id = 37 
           if value ~= nil then 
              id = value.goods.objid
           end  
           local leixin = const.kCoinItem
           if value ~= nil and value.goods.cate == const.kCoinItem then  --物品
               item = findItem( id) 
               leixin = const.kCoinItem
           elseif value ~= nil and value.goods.cate == const.kCoinTotem then  --图腾
               local tdata = TotemData.getData()
               if tdata ~= nil then 
                   for key ,value in pairs(tdata) do 
                       if id == value.id then 
                          inflag = false 
                       end 
                   end 
               end 
               item = findTotem( id) 
               leixin = const.kCoinTotem
           elseif value ~= nil and  value.goods.cate == const.kCoinGlyph then   --神符     
               local tdata = TotemData.getGlyphList()
               if tdata ~= nil then 
                   for key ,value in pairs(tdata) do 
                       if id == value.id then 
                       end 
                   end 
               end 
               item = findTempleGlyph( id) 
               leixin = const.kCoinGlyph
           end 
           if value ~= nil and item ~= nil then 
               coinbg =item.quality
               bgid = coinbg
               coin = id
               local count = value.goods.val
               local goods = value.goods
               local name = item.name 
               local moneyfake = tonumber(value.fake_price.val)
               local moneytype = tonumber(value.fake_price.cate)
               local moneyid = tonumber(value.fake_price.objid )
               local type = CoinType.xunzhan
               if moneyid == 0 and moneytype == const.kCoinMoney then 
                  type = CoinType.jinbi
               elseif moneyid == 0 and moneytype == const.kCoinGold then 
                  type = CoinType.zhuanshi
               else
                  type = CoinType.xunzhan
               end 
        
               local moneynow = tonumber(value.price.val)
               local moneynowtype = tonumber(value.price.cate)
               local moenynowid = tonumber(value.price.objid )
        
               local hislimit = value.history_limit_count
               local daylimit = value.daily_limit_count
               local winlimit = value.win_times_limit
               local serverlimit = value.server_limit_count 
               local buyed = value1.buyed_count
               local id = value1.id 
               if inflag == true then 
                table.insert(meirilist ,{serverlimit = serverlimit ,daylimit = daylimit ,hislimit = hislimit ,goods = goods ,winlimit = winlimit,count = count ,leixin = leixin,type = type,bgid = bgid,coinbg = coinbg,coin = coin,
                    name = name , oldmoney = moneyfake, nowmoney = moneynow,id = id ,buyedcount = buyedcount,
                    limitcount = limitcount})
                end 
            end
        end
--        meirilist = StoreData.rescort(meirilist)
        EventMgr.dispatch(EventType.ShowMeiriStore,meirilist)
end 

--独立更新勋章，地精，游戏
function StoreData.updateCount(data1)
    StoreData.setWinTime(gameData.user.other.single_arena_win_times)
    local list = {} 
    achlist = {} -- 竞技场成就数据
    achlist1 = {} -- 大墓地成就数据
    list = GetDataList( "Vendible" )
    local otherdata = {} 
    if data1 ~= nil then 
       otherdata = data1
    end 

    if StoreData.StoreDataType == StoreData.Type.XZ then
        xunzhanlist = {}
        for i = 1 , 4 do 
           xunzhanlist[i] = {}
        end 
    elseif StoreData.StoreDataType == StoreData.Type.YX then
        youxilist = {}
    elseif StoreData.StoreDataType == StoreData.Type.DJ then
        djlist = {}
    end 
    achlist ={}
--    print("gameData.user.shop_log .. " .. debug.dump(data1))
--    print("gameData.user.shop_log .. " .. debug.dump(gameData.user.shop_log))
    
    -- 更新已经购买的数据
    local flag = true 
    for key , value in pairs(otherdata) do 
        if value ~= nil then 
            for key1 , value1 in pairs(gameData.user.shop_log) do 
                if value.id == value1.id then 
                    table.remove(gameData.user.shop_log,key1)
                    table.insert( gameData.user.shop_log,value)
                    flag = false 
                end 
            end 
        end 
    end 
    if flag == true then 
       for key , value in pairs(otherdata) do 
           if value ~= nil then 
              table.insert( gameData.user.shop_log,value)
           end 
       end 
    end 
--    print("gameData.user.shop_log .. " .. debug.dump(gameData.user.shop_log))
    
    local keys = table.keys(list)
    table.sort(keys)
    for i = 1, #keys do
        local value = list[keys[i]]
        local buyedcount = 0
        local inflag = true 
        for buykey ,buyvalue in pairs(gameData.user.shop_log) do
            if buyvalue.id == value.id then 
                if buyvalue.daily_count ~= 0 then 
                   buyedcount = buyvalue.daily_count
                elseif buyvalue.history_count ~= 0 then  
                   buyedcount = buyvalue.history_count
                end 
            end 
        end 
        
        local item = 1
        local coinbg = 1
        local bgid = 1
        local coin = 1
        local limitcount = value.daily_limit_count
        local id = value.goods.objid 
        local leixin = const.kCoinItem
        if value.goods.cate == const.kCoinItem then  --物品
            item = findItem( id) 
            leixin = const.kCoinItem
        elseif value.goods.cate == const.kCoinTotem then  --图腾
            local tdata = TotemData.getData()
            for key ,value in pairs(tdata) do 
                if id == value.id then 
                   inflag = false 
                end 
            end 
            item = findTotem( id) 
            leixin = const.kCoinTotem
        elseif value.goods.cate == const.kCoinGlyph then   --雕文     
            local tdata = TotemData.getGlyphList()
            for key ,value in pairs(tdata) do 
                if id == value.id then 
--                    inflag = false 
                end 
            end 
            item = findTempleGlyph( id) 
            leixin = const.kCoinGlyph
        elseif value.goods.cate == const.kCoinMoney then   -- 金币
            item = {}
            item.quality = 1 
            item.name = "金币"
            leixin = const.kCoinMoney
        elseif value.goods.cate == const.kCoinGold then -- 钻石   
            item = {}
            item.quality = 1 
            item.name = "钻石"
            leixin = const.kCoinGold
        elseif value.goods.cate == const.kCoinWater then --圣水
            item = {}
            item.quality = 1 
            item.name = "圣水"
            leixin = const.kCoinWater
        else 
            item = {}
            item.quality = 1 
            item.name = "圣水"
            leixin = const.kCoinWater
        end
        coinbg =item.quality
        bgid = coinbg
        coin = id

        local goods = value.goods    
        local count = value.goods.val
        
        local name = item.name 
        local moneyfake = tonumber(value.fake_price.val)
        local moneytype = tonumber(value.fake_price.cate)
        local moneyid = tonumber(value.fake_price.objid )

        local moneynow = tonumber(value.price.val)
        local moneynowtype = tonumber(value.price.cate)
        local moenynowid = tonumber(value.price.objid )

        local hislimit = value.history_limit_count
        local daylimit = value.daily_limit_count
        local serverlimit = value.server_limit_count 
        local winlimit = value.win_times_limit
        local id = value.id 
        local  medal_type = value.medal_type
        
        local type = CoinType.xunzhan
        if moneyid == 0 and moneytype == const.kCoinMoney then 
            type = CoinType.jinbi
        elseif moneyid == 0 and moneytype == const.kCoinGold then 
            type = CoinType.zhuanshi
        elseif moneyid == 0 and moneytype == const.kCoinMedal then 
            type = CoinType.xunzhan
        elseif moneyid == 0 and moneytype == const.kCoinTomb then
            type = CoinType.mudi 
        end 
  
        if value.shop_type == StoreData.Type.XZ and StoreData.StoreDataType == StoreData.Type.XZ then
            if inflag == true then 
               table.insert(xunzhanlist[medal_type], {serverlimit = serverlimit ,daylimit = daylimit,hislimit = hislimit ,medal_type = medal_type,goods = goods ,winlimit = winlimit,count = count,leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,xunzhan = moneynow})
            end 
        elseif value.shop_type == StoreData.Type.YX and StoreData.StoreDataType == StoreData.Type.YX then
            table.insert(youxilist, {serverlimit = serverlimit ,daylimit = daylimit,hislimit = hislimit ,goods = goods,winlimit = winlimit,count = count,leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,xunzhan = moneynow,ctype = 0})
        elseif value.shop_type == StoreData.Type.DJ and StoreData.StoreDataType == StoreData.Type.DJ then
            table.insert(djlist, {serverlimit = serverlimit ,daylimit = daylimit,hislimit = hislimit ,goods = goods,winlimit = winlimit,count = count,leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,money = moneynow})
        end 
        if value.shop_type == StoreData.Type.JJ then 
            table.insert(achlist, {serverlimit = serverlimit ,daylimit = daylimit,hislimit = hislimit ,medal_type = medal_type,goods = goods ,winlimit = winlimit,count = count,leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,xunzhan = moneynow})
        end 
        if value.shop_type == StoreData.Type.MD then 
            table.insert(achlist1, {serverlimit = serverlimit ,daylimit = daylimit,hislimit = hislimit ,medal_type = medal_type,goods = goods ,winlimit = winlimit,count = count,leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,xunzhan = moneynow})
        end 
    end 
    if StoreData.StoreDataType == StoreData.Type.XZ then
--        xunzhanlist = StoreData.rescort(xunzhanlist)
        local data = {}
        if StoreData.TypeXZ == StorexunzhanType.HUO then
            LogMgr.debug("huo3")
            data = xunzhanlist[3]
        elseif StoreData.TypeXZ == StorexunzhanType.SHUI then
            LogMgr.debug("shui2")
            data = xunzhanlist[2]
        elseif StoreData.TypeXZ == StorexunzhanType.FENG then
            LogMgr.debug("feng4")
            data = xunzhanlist[4]
        elseif StoreData.TypeXZ == StorexunzhanType.TU then 
            LogMgr.debug("tu1")
            data = xunzhanlist[1]
        end 
        EventMgr.dispatch(EventType.UpdateStoreDataXZ,data)
    elseif StoreData.StoreDataType == StoreData.Type.YX then
--        youxilist = StoreData.rescort(youxilistzai
        EventMgr.dispatch(EventType.UpdateStoreDataYX,youxilist)
        
    elseif StoreData.StoreDataType == StoreData.Type.DJ then 
--        djlist = StoreData.rescort(djlist)
        EventMgr.dispatch(EventType.UpdateStoreDataDJ,djlist)
    end 
    
    
    
end 

function StoreData.updateData()

    --挑战次数
    if gameData.user.other.single_arena_win_times ~= nil then 
       StoreData.setWinTime(gameData.user.other.single_arena_win_times)
    end 
    local list = {} 
    achlist = {} -- 竞技场成就数据
    achlist1 = {} -- 大墓地成就数据
    list = GetDataList( "Vendible" )
    local data = gameData.user.mystery_goods_list
    local otherdata = gameData.user.shop_log
--    LogMgr.debug(debug.dump(data))
    if meirilist == nil or #meirilist == 0 then
         StoreData.setDailyData(data)
    end 
    xunzhanlist = {}
    for i = 1 , 4 do 
        xunzhanlist[i] = {}
    end 
    youxilist = {}
    djlist = {}
    
    local keys = table.keys(list)
    table.sort(keys)
    for i = 1, #keys do
        local value = list[keys[i]]    
        local inflag = true 
        local buyedcount = 0
        for buykey ,buyvalue in pairs(otherdata) do 
            if buyvalue.id == value.id then 
                if buyvalue.daily_count ~= 0 then 
                    buyedcount = buyvalue.daily_count
                elseif buyvalue.history_count ~= 0 then  
                    buyedcount = buyvalue.history_count
                end 
            end 
        end
        local limitcount = value.daily_limit_count
        local item = 1
        local coinbg = 1
        local bgid = 1
        local coin = 1
        local id = value.goods.objid 
        local leixin = const.kCoinItem
        if value.goods.cate == const.kCoinItem then  --物品
            item = findItem( id) 
            leixin = const.kCoinItem
        elseif value.goods.cate == const.kCoinTotem then  --图腾
        
            local tdata = TotemData.getData()
            if tdata ~= nil then 
                for key ,value in pairs(tdata) do 
                    if id == value.id then 
                        inflag = false 
                    end 
                end 
            end 
            item = findTotem( id) 
            leixin = const.kCoinTotem
        elseif value.goods.cate == const.kCoinGlyph then   --雕文     
            local tdata = TotemData.getGlyphList()
            if tdata ~= nil then 
                for key ,value in pairs(tdata) do 
                    if id == value.id then 
    --                    inflag = false 
                    end 
                end 
            end 
            item = findTempleGlyph( id)
            leixin = const.kCoinGlyph
        elseif value.goods.cate == const.kCoinMoney then   -- 金币
            item = {}
            item.quality = 1 
            item.name = "金币"
            leixin = const.kCoinMoney
        elseif value.goods.cate == const.kCoinGold then -- 钻石   
            item = {}
            item.quality = 1 
            item.name = "钻石"
            leixin = const.kCoinGold
        elseif value.goods.cate == const.kCoinWater then --圣水
            item = {}
            item.quality = 1 
            item.name = "圣水"
            leixin = const.kCoinWater
        else 
            item = {}
            item.quality = 1 
            item.name = "钻石"
            leixin = const.kCoinGold
        end
        
        if item ~= nil and value ~= nil then
           
            local count = value.goods.val
            local goods = value.goods
            if item == 1 then 
               print("")
            end 
            coinbg = item.quality
            bgid = coinbg
            coin = id
            local  medal_type = value.medal_type
            local name = item.name 
            local moneyfake = tonumber(value.fake_price.val)
            local moneytype = tonumber(value.fake_price.cate)
            local moneyid = tonumber(value.fake_price.objid )
    
            local moneynow = tonumber(value.price.val)
            local moneynowtype = tonumber(value.price.cate)
            local moenynowid = tonumber(value.price.objid )
    
            local hislimit = value.history_limit_count
            local daylimit = value.daily_limit_count
            local serverlimit = value.server_limit_count 
            local winlimit = value.win_times_limit
            local id = value.id 
            
            local type = CoinType.xunzhan
            if moneyid == 0 and moneytype == const.kCoinMoney then 
                type = CoinType.jinbi
            elseif moneyid == 0 and moneytype == const.kCoinGold then 
                type = CoinType.zhuanshi
            elseif moneyid == 0 and moneytype == const.kCoinMedal then 
                type = CoinType.xunzhan
            elseif moneyid == 0 and moneytype == const.kCoinTomb then
                type = CoinType.mudi 
            end 
            if inflag == true then 
            
                if value.shop_type == StoreData.Type.XZ then     
                    table.insert(xunzhanlist[medal_type], {serverlimit = serverlimit ,daylimit = daylimit ,hislimit = hislimit , medal_type = medal_type ,goods = goods ,winlimit = winlimit,count = count, leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,xunzhan = moneynow})
                elseif value.shop_type == StoreData.Type.YX then 
                    table.insert(youxilist, {serverlimit = serverlimit ,daylimit = daylimit ,hislimit = hislimit ,goods = goods ,winlimit = winlimit,count = count ,leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,xunzhan = moneynow,type = 0})
                elseif value.shop_type == StoreData.Type.DJ then 
                    table.insert(djlist, {serverlimit = serverlimit ,daylimit = daylimit ,hislimit = hislimit ,goods = goods ,winlimit = winlimit,count = count,leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,money = moneynow})
                elseif value.shop_type == StoreData.Type.JJ then -- 竞技场
                    table.insert(achlist,  {serverlimit = serverlimit ,daylimit = daylimit ,hislimit = hislimit , medal_type = medal_type ,goods = goods ,winlimit = winlimit,count = count, leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,xunzhan = moneynow})
                elseif value.shop_type == StoreData.Type.MD then -- 大墓地
                    table.insert(achlist1,{serverlimit = serverlimit ,daylimit = daylimit ,hislimit = hislimit , medal_type = medal_type ,goods = goods ,winlimit = winlimit,count = count, leixin = leixin ,type = type,buyedcount = buyedcount,limitcount = limitcount,id = id ,bgid = bgid ,coinbg = coinbg ,coin = coin ,name = name ,xunzhan = moneynow})
                end 
            end 
        end
    end 
--    xunzhanlist = StoreData.rescort(xunzhanlist)
--    youxilist = StoreData.rescort(youxilist)
--    djlist = StoreData.rescort(djlist)    
end 

function StoreData.refreshAchData()

end 

function StoreData.ingoreRedPoint(data) -- 忽略礼包
   if data ~= 1005 and data ~= 1006 and data ~= 1007 and data ~= 1008 and data ~= 1009 and data ~= 1010 and data ~= 1011 and data ~= 1012 then 
      return true  
   end 
   return false
end 

function StoreData.setRedPoint()
   redflag = {}
   for i = 1 ,4 ,1 do 
       redflag[i] = false
   end 
   for i = 1 , 4 ,1 do
       redflag[i] = false
       local data = xunzhanlist[i]
       if data ~= nil then 
           for key , value in pairs(data) do 
               if value ~= nil and value.coin ~= nil then  
                   if StoreData.ingoreRedPoint(value.coin) then  --礼包 不加红点
                       if value ~= nil and value.winlimit ~= nil and value.winlimit <= wintime then 
                          local coin = CoinData.getCoinByCate(value.type)
                          if coin >= value.xunzhan then  
                             redflag[i] = true
                          end 
                       elseif value ~= nil and value.winlimit == nil then 
                            local coin = CoinData.getCoinByCate(value.type)
                            if coin >= value.xunzhan then  
                                redflag[i] = true
                            end 
                       end 
                   end 
               end 
           end
       end  
   end 
   for i = 1 ,4 ,1 do   -- 屏蔽红点
       redflag[i] = false
   end 
end 

function StoreData.getRedPoint()
   StoreData.setWinTime(gameData.user.other.single_arena_win_times)
   StoreData.setRedPoint()
   return redflag
end 

function StoreData.getStoreRedPoint()
   if #xunzhanlist == nil or xunzhanlist == 0 or xunzhanlist[1] == nil then  
      StoreData.updateData()
   end 
   StoreData.getRedPoint()
   for i = 1 ,4 do
      if redflag[i] == true then
         return true
      end 
   end  
   return false    
end 

--初始化数据
function StoreData.initData()
    StoreData.updateData()
end 

----基本消息
--function StoreData.getBaseData()
--   return baselist
--end 
--
--function StoreData.setBaseData(data) 
--    baselist = data
--end  

--成就list
function StoreData.getAchData()
       return achlist
end 

--设置展示的data
function StoreData.getShowAchData()
   local showdata = {} 
   local list = {} 
   if StoreData.Achieve == "JJ" then 
      StoreData.StoreDataType = StoreData.Type.XZ
      list = achlist
   elseif StoreData.Achieve == "MD" then 
      StoreData.StoreDataType = StoreData.Type.DJ
      list = achlist1
   end 
   local nlist = {}
    if list ~= nil and #list ~= 0 then 
        for key,value in pairs(list) do
           if value ~= nil then  
               local data = findAchievementGoods(value.id) 
               if data ~= nil then 
                  local num1 = tonumber(data.cond.first)
                  local num2 = tonumber(data.cond.second)
                  if nlist[num1] == nil then 
                     nlist[num1] = {}
                  end 

                  local num = 0 
                  local empty = "  "
                  if num1 == 1 then 
                     num = gameData.user.other.single_arena_win_times -- 玩家竞技场战胜次数
                     value.string = empty .. "竞技场胜利" 
                     value.string1 = empty .. num2 .. "  " 
                     value.string2 = "次" 
                     value.string3 = empty .."" 
                  elseif num1 == 2 then 
                     num =  gameData.user.other.single_arena_rank -- 玩家竞技场最高排名
                     value.string = empty .. "竞技场进入" 
                     value.string1 =  empty .. num2 .. "    "
                     value.string2 = "名" 
                     value.string3 = empty .. ""
                  elseif num1 == 3 then 
                     num = VarData.getVar("medal_history_consume") -- 勋章消费
                     value.string = empty .. "消费勋章" 
                     value.string1 = empty .. num2 .. "      "
                     value.string2 =  "个" 
                     value.string3 = empty .. ""
                  elseif num1 == 4 then 
                     num = gameData.user.tomb_info.history_win_count -- 打通n关
                     value.string = empty .. "大墓地打通"
                     value.string1 = empty .. num2 .. " "
                     value.string2 = empty .. "关" 
                     value.string3 = empty .. "(" .. num .. "/" .. num2 .. ")"
                  elseif num1 == 5 then 
                     num = gameData.user.tomb_info.history_reset_count -- 历史重置次数
                     value.string = empty .. "大墓地重置"
                     value.string1 = empty .. num2 .. " "
                     value.string2 = empty .. "次" 
                     value.string3 = empty .. "(" .. num .. "/" .. num2 .. ")"
                  elseif num1 == 6 then 
                     num = gameData.user.tomb_info.history_pass_count -- 杀死怪次数
                     value.string = empty .. "杀死巫妖小克"
                     value.string1 = empty .. num2
                     value.string2 = empty .. "次" 
                     value.string3 = empty .. "(" .. num .. "/" .. num2 .. ")" 
                  end
                  
                  local level = tonumber(data.cond_level)
                  if value.buyedcount == 0 then 
                      -- 说明未被购买                  
                        if num1~= 2 and num2 <= num then 
                            value.open = true 
                            table.insert(showdata , value)
                        elseif num1== 2 and num2 >= num and num ~= 0 then 
                            value.open = true 
                            table.insert(showdata ,value)
                        else  
                            value.open = false 
                        end 
                        table.insert(nlist[num1] ,value)
                  end 
               end 
           end 
       end 
   end 
   for i = 1 ,#list do
       if nlist ~= nil and #nlist ~= 0 then  
           for j , value in pairs(nlist) do
               if nlist[j] ~= nil and nlist[j][i] ~= nil and nlist[j][i].open == false then 
                  table.insert(showdata ,nlist[j][i])
               end 
           end 
       end 
   end 
   return showdata
end 

function StoreData.setAchData(data)
   achlist = data 
end 

--游戏data 
function StoreData.getYXData()
    return youxilist 
end

function StoreData.setYXData(data)
    youxilist = data 
end 

function StoreData.getAutoList()
   return autolist
end 
--勋章data 
function StoreData.getXZData()
    return xunzhanlist 
end

function StoreData.setXZData(data)
    xunzhanlist = data 
end 

--每日data 
function StoreData.getMRData()
    return meirilist 
end

function StoreData.setMRData(data)
    meirilist = data 
end 

--地精data 
function StoreData.getDJData()
     return djlist 
end
 
function StoreData.setDJData(data)
    djlist = data 
end 