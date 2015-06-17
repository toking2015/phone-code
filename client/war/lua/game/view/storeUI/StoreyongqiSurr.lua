local prepath = "image/ui/StoreUI/"
local url = prepath .. "StoreyongqiSurr.ExportJson"
require("lua/game/view/storeUI/StoreyongqiUntil")

StoreyongqiSurr = class("StoreyongqiSurr", function()
    return getLayout(url)
end)
local need_money = {20,20,50,50,100,100,200}
function StoreyongqiSurr:ctor()
    self:showAchievement()
    local data = StoreData.getDJData()
    self:refreshData(data)
    local bottom = self.bottombg
    createScaleButton(bottom.refreshbtn)
    local function confirmHandler()
        StoreCommon.intoVip()
    end
    local time = StoreData.getYongqineed() 
    local money = need_money[time + 1]
    if money == nil then 
       money = 200
    end 

    bottom.neednumlabel:setString(money) 
    
    bottom.refreshbtn:addTouchEnded(function()
        ActionMgr.save( 'UI', 'StoreyongqiSurr click up refreshbtn') 
        local time = StoreData.getYongqineed() 
        local money = need_money[time + 1]
        if money == nil then 
            money = 200
        end 
        local str = "[image=refreshthing.png][br][image=diamond.png][font=ZH_3]  本次刷新需要消耗" .. money .. " 钻石"
        showMsgBox(str,function ()
            local dim = CoinData.getCoinByCate(const.kCoinGold)
            if dim >= money then 
                StoreData.StoreDataType = StoreData.Type.DJ
                Command.run( 'refresh tomb')
            else 
                local str = "[image=tip.png][br][image=diamond.png][font=ZH_5]  钻石[font=ZH_3] 不足,是否前往"
                showMsgBox(str, confirmHandler)
            end 
        end )
    end )
    EventMgr.addListener(EventType.UpdateStoreDataDJ, self.refreshData,self)
    EventMgr.addListener(EventType.UserVarUpdate, self.refreshTime,self)
end 

-- 展示成就
function StoreyongqiSurr:showAchievement()
--    self.nbg:loadTexture(prepath .. "storeui_dibg.png",ccui.TextureResType.localType)
end 

function StoreyongqiSurr:refreshTime(key)
    if key == "tomb_refreshed_times" then 
        local time = StoreData.getYongqineed() 
        local money = need_money[time + 1]
        if money == nil then 
            money = 200
        end 
        if self.bottombg == nil then 
           return 
        end 
        local bottom = self.bottombg
        bottom.neednumlabel:setString(money)
    end 

end 

function StoreyongqiSurr:refreshData(data1)  
    StoreData.Achieve = "MD"
    local yongqilist = data1
    local list = {}
    if self.viewlist == nil then 
       self.viewlist = {}
    end 
    if nil ~= yongqilist and #yongqilist ~= 0 then 
        for key , value in pairs(yongqilist) do

            local suntil = nil 
            if self.viewlist[key] == nil then 
               suntil = StoreyongqiUntil:createView()
               suntil:retain()
               table.insert(self.viewlist,suntil) 
            else 
               suntil = self.viewlist[key]
            end 
            suntil:refreshData(value)
        end 
        local newlist = {}
        local list = {}
        local rowNumList = {}
        if StoreData.getShowAchData() ~= nil and #StoreData.getShowAchData() ~= 0 then  
            local view = StoreAchieveSurr:createView()
            table.insert(newlist,view)
            list = { newlist,self.viewlist}
            rowNumList = {1,3}
        else 
            list = {self.viewlist}
            rowNumList = {3}
        end 
        initScrollViewWithList(self.sc, list, rowNumList, 0, 0, 6, 6)
    end 

end 

function StoreyongqiSurr:createView()
   local view = StoreyongqiSurr.new()
   return view
end 

function StoreyongqiSurr:onClose()
    for key ,value in pairs(self.viewlist) do
        self.viewlist[key]:release()
        self.viewlist[key] = nil 
    end 
    TimerMgr.killPerFrame(self.update)
    EventMgr.removeListener(EventType.UpdateStoreDataDJ, self.refreshData)
end 


