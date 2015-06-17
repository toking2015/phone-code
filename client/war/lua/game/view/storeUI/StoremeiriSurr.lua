-- write by weihao 

local prepath = "image/ui/StoreUI/"
local url = prepath .. "StoremeiriSurr.ExportJson"
local updatekey = "storemeiriupdate" 
require("lua/game/view/storeUI/StoremeiriUntil")
StoremeiriSurr = class("StoremeiriSurr", function()
    return getLayout(url)
end)

function StoremeiriSurr:ctor()
    local data = StoreData.getMRData()
    self:refreshData(data)
    local bottom = self.bottombg
    createScaleButton(bottom.refreshbtn)
    
    local function confirmHandler()
        StoreCommon.intoVip()
    end
    bottom.refreshbtn:addTouchEnded(function()
        ActionMgr.save( 'UI', 'StoremeiriSurr click refreshbtn') 
        local refreshcount = ItemData.getItemCount(8,const.kBagFuncCommon)
        local str = ""
        if refreshcount >= 1 then 
           str = "[image=refreshthing.png][br][font=ZH_3]  本次刷新需要消耗 1 张刷新符"
        else 
           str = "[image=refreshthing.png][br][image=diamond.png][font=ZH_3]  本次刷新需要消耗 50 钻石"
        end 
        showMsgBox(str,function ()
             local refreshcount = ItemData.getItemCount(8,const.kBagFuncCommon)
             if refreshcount >=1 then 
                Command.run( 'refresh meiri')
                return 
             end 
             local dim = CoinData.getCoinByCate(const.kCoinGold)
             if dim >= 50 then 
                Command.run( 'refresh meiri')
             else 
                local str1 = "[image=tip.png][br][image=diamond.png][font=ZH_5]  钻石[font=ZH_3] 不足,是否前往"
                showMsgBox(str1, confirmHandler)
             end 
        end )

    end )
    bottom.num.positionx = bottom.num:getPositionX()
    bottom.num:setVisible(false)
    bottom.kuo1.positionx = bottom.kuo1:getPositionX()
    bottom.kuo2.positionx = bottom.kuo2:getPositionX()
    bottom.neednumlabel:setString("50")
    local time = DateTools.getHour( gameData.getServerTime())
    local timeid = 12 
    if time < 12 then 
        timeid = 12
    elseif time >= 12 and time < 18 then 
        timeid = 18
    elseif time >= 18 and time < 21 then 
        timeid = 21
    elseif time >=21 then
        timeid = 12 
    end 
    local year = DateTools.getYearInt(gameData.getServerTime())
    local month = DateTools.getMonth(gameData.getServerTime())
    local day = DateTools.getDay(gameData.getServerTime())
    bottom.needtimelabel:setVisible(false)
    local ttime = gameData.parseServerTime(year, month, day, timeid, 0, 0, false)
    if time >= 21 then 
        ttime = ttime + 24 * 60 * 60
    end 
    local update = function ()
        local time = DateTools.getHour( gameData.getServerTime())
        local timeid = 12 
        if time < 12 then 
            timeid = 12
        elseif time >= 12 and time < 18 then 
            timeid = 18
        elseif time >= 18 and time < 21 then 
            timeid = 21
        elseif time >=21 then
            timeid = 12 
        end 
        local year = DateTools.getYearInt(gameData.getServerTime())
        local month = DateTools.getMonth(gameData.getServerTime())
        local day = DateTools.getDay(gameData.getServerTime())
        bottom.needtimelabel:setVisible(false)
        local ttime = gameData.parseServerTime(year, month, day, timeid, 0, 0, false)
        if time >= 21 then 
            ttime = ttime + 24 * 60 * 60
        end 
        local timestring = DateTools.secondToStringTwo(ttime - gameData.getServerTime(), 3)
--        local timestring = DateTools.toTimeString(ttime - gameData.getServerTime())
        bottom.needtimelabel:setString("剩余刷新时间: " .. timestring  .. "")
        bottom.needtimelabel:setVisible(true)
        local refreshcount = ItemData.getItemCount(8,const.kBagFuncCommon)
        bottom.num:setVisible(true)
        if refreshcount > 0 then 
            bottom.num:setString(refreshcount)
            bottom.num:setColor(cc.c3b( 173, 254, 0)) -- 绿色
        else 
            bottom.num:setString("0")
            bottom.num:setColor(cc.c3b( 255,48,0)) -- 红色
        end 
        if refreshcount >= 100 then 
           bottom.num:setPositionX( bottom.num.positionx+5)
           bottom.kuo2:setPositionX(bottom.kuo2.positionx+10)
        end 
    end 
    TimerMgr.addTimeFun(updatekey, update)
    EventMgr.addListener(EventType.ShowMeiriStore, self.refreshData,self)
end 

function StoremeiriSurr:refreshData(data)
    local list = {}
    local viewlist = {}
    if nil ~= data and #data ~= 0 then 
        for _, value in pairs(data) do
            local suntil = StoremeiriUntil:createView(value)
            table.insert(viewlist,suntil)
        end 
        initVector(self.vector, viewlist, 3, 15, 6, 6, 6)
    end 
end 

function StoremeiriSurr:createView()
    local view = StoremeiriSurr.new()
    return view 
end 

function StoremeiriSurr:onClose()
    TimerMgr.removeTimeFun(updatekey)
    EventMgr.removeListener(EventType.ShowMeiriStore, self.refreshData)
end