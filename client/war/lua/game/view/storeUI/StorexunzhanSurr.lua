-- write by weihao 
local prepath = "image/ui/StoreUI/"
local url = prepath .. "StorexunzhanSurr.ExportJson"
require("lua/game/view/storeUI/StorexunzhanUntil")
require("lua/game/view/storeUI/StoreAchieveSurr")
StorexunzhanType ={
  HUO = 3 ,
  SHUI = 2 ,
  FENG = 4 ,
  TU = 1
}
local num = 1
StorexunzhanSurr = class("StorexunzhanSurr", function()
    return getLayout(url)
end)

function StorexunzhanSurr:showScrollview()
    local data = StoreData.getXZData()
    num = 1
    self:refreshData(data[1])
    self:loadView()
end 

-- 展示成就
function StorexunzhanSurr:showAchievement()
--    self.nbg:loadTexture(prepath .. "storeui_dibg.png",ccui.TextureResType.localType)
end 

function StorexunzhanSurr:ctor()
    self:showAchievement()
    self.viewlist = {}
    for i = 1 ,4 do  
       self.viewlist[i] = nil
    end 
    EventMgr.addListener(EventType.UpdateStoreDataXZ, self.refreshData,self)
    self.list ={}
    self.positionlist = {}
    for k = 1 , 4 ,1 do
       createScaleButton(self["btn" .. k .. "d2"],false,nil,nil,false)
       createScaleButton(self["btn" .. k .. "d1"])
       table.insert(self.list,{btn_selected = self["btn" .. k .. "d2"] ,btn_unselected =self["btn" .. k .. "d1"]})
       table.insert(self.positionlist,{x1= self["btn" .. k .. "d1"]:getPositionX(),y1= self["btn" .. k .. "d1"]:getPositionY(),
            x2= self["btn" .. k .. "d2"]:getPositionX(),y2= self["btn" .. k .. "d2"]:getPositionY()})
    end 
    
    self.updateredPoint = function()
        self.bottombg.vector:removeAllChildren(true)
        local str ="[font=ZH_P5]当前已挑战胜利[font=ZH_P6]" .. StoreData.getWinTime() .. "[font=ZH_P5]次"
        str = str .. "                已消费[font=ZH_P6]" .. VarData.getVar("medal_history_consume") .. "[font=ZH_P5]勋章"
        RichText:addMultiLine(str, prepath, self.bottombg.vector)
        local reddata = StoreData.getRedPoint()
        for i = 1 ,4 do 
            if reddata[i] == true then 
                local size1 = self["btn" .. i .. "d1"]:getSize()
                local size2 = self["btn" .. i .. "d2"]:getSize()
                local off1 = cc.p(size1.width - 8,size1.height - 8)
                local off2 = cc.p(size2.width - 8,size2.height - 8)
                setButtonPoint( self["btn" .. i .. "d1"], true ,off1)
                setButtonPoint( self["btn" .. i .. "d2"], true ,off2)
            else 
                local size1 = self["btn" .. i .. "d1"]:getSize()
                local size2 = self["btn" .. i .. "d2"]:getSize()
                local off1 = cc.p(size1.width - 8,size1.height - 8)
                local off2 = cc.p(size2.width - 8,size2.height - 8)
                setButtonPoint( self["btn" .. i .. "d1"], false ,off1)
                setButtonPoint( self["btn" .. i .. "d2"], false ,off2)
            end  
        end 
    end 
    
    local typedata = {StorexunzhanType.TU,StorexunzhanType.SHUI,StorexunzhanType.HUO,StorexunzhanType.FENG}
    self.tab = createTab(self.list, typedata)
    function self.handler(value)
        local data = StoreData.getXZData()
        ActionMgr.save( 'UI', 'StorexunzhanSurr click up value.data')
        if value.data == StorexunzhanType.HUO then
            StoreData.TypeXZ = StorexunzhanType.HUO
            LogMgr.debug("huo3")
            num = 3 
            if self.viewlist[num] == nil then 
               self:refreshData(data[num])
            else 
               self:setScrollview (self.viewlist[num])
            end 
        elseif value.data == StorexunzhanType.SHUI then
            StoreData.TypeXZ = StorexunzhanType.SHUI
            LogMgr.debug("shui2")
            num = 2
            if self.viewlist[num] == nil then 
                self:refreshData(data[num])
            else 
                self:setScrollview (self.viewlist[num])
            end 
            
        elseif value.data == StorexunzhanType.FENG then
            StoreData.TypeXZ = StorexunzhanType.FENG
            LogMgr.debug("feng4")
            num = 4 
            if self.viewlist[num] == nil then 
                self:refreshData(data[num])
            else 
                self:setScrollview (self.viewlist[num])
            end 
            
        elseif value.data == StorexunzhanType.TU then 
            StoreData.TypeXZ = StorexunzhanType.TU
            LogMgr.debug("tu1")
            num = 1 
            if self.viewlist[num] == nil then 
                self:refreshData(data[num])
            else 
                self:setScrollview (self.viewlist[num])
            end 
        end 
    end
    Command.bind( 'storetype', 
        function(id)
            self.handler(id)
            if self.tab ~= nil then 
               self.tab:setSelectedIndex(id.data)
            end 
        end 
    )    
    self.tab:addEventListener(self.tab, self.handler)
    --设置胜利数量
    local wintime = StoreData.getWinTime()
    local str ="[font=ZH_P5]当前已挑战胜利[font=ZH_P6]" .. wintime .. "[font=ZH_P5]次"
    str = str .. "                已消费[font=ZH_P6]" .. VarData.getVar("medal_history_consume") .. "[font=ZH_P5]勋章"
    RichText:addMultiLine(str, prepath, self.bottombg.vector)
    
end 

function StorexunzhanSurr:loadView()
    local data = StoreData.getXZData()
    for i = 1 ,4 do
        num = i
        local viewlist = {}
        if self.viewlist[num] == nil then 
            for _, value in pairs(data[num]) do
                local suntil = StorexunzhanUntil:createView(value)
--                self:addChild(suntil)
--                suntil:setVisible(false)
                suntil:retain()
                table.insert(viewlist,suntil)  
            end 
            self.viewlist[num] = viewlist
        end 
        
    end 
    num = 1 
end 

--设置scrollview
function StorexunzhanSurr:setScrollview (viewlist)
    StoreData.Achieve = "JJ"
    initScrollviewWith(self.scrollview, viewlist, 3, 45, 0, 6, 6)
    local view = StoreAchieveSurr:createView()
    local newlist = {}
    local list = {}
    local rowNumList = {}
    if StoreData.getShowAchData() ~= nil and #StoreData.getShowAchData() ~= 0 then  
        local view = StoreAchieveSurr:createView()
        table.insert(newlist,view)
        list = { newlist,viewlist}
        rowNumList = {1,3}
    else 
        list = {viewlist}
        rowNumList = {3}
    end 
    initScrollViewWithList(self.scrollview, list, rowNumList, 45, 0, 6, 6)
    bindScrollViewAndSlider(self.scrollview, self.slider)
    self.slider:setPercent(0)
end 

function StorexunzhanSurr:refreshData(data)
    StoreData.Achieve = "JJ"
    local list = {}
    local viewlist = {}
    if nil ~= data and #data ~= 0 then 
        for _, value in pairs(data) do
            local suntil = StorexunzhanUntil:createView(value)
            suntil:retain()
            table.insert(viewlist,suntil)  
        end 
        if self.viewlist[num] ~= nil then 
            for key ,value in pairs(self.viewlist[num]) do
                if value ~= nil then 
                   value:release()
                   self.viewlist[num][key] = nil 
                end 
            end 
        end 
        self.viewlist[num] = {}
        self.viewlist[num] = viewlist
        local newlist = {}
        local list = {}
        local rowNumList = {}
        if StoreData.getShowAchData() ~= nil and #StoreData.getShowAchData() ~= 0 then  
            local view = StoreAchieveSurr:createView()
            table.insert(newlist,view)
            list = { newlist,viewlist}
            rowNumList = {1,3}
        else 
            list = {viewlist}
            rowNumList = {3}
        end 
        initScrollViewWithList(self.scrollview, list, rowNumList, 45, 0, 6, 6)
    end 
    bindScrollViewAndSlider(self.scrollview, self.slider)
    self.slider:setPercent(0)
    self.updateredPoint()
end 

function StorexunzhanSurr:createView()
   local view = StorexunzhanSurr.new()
   return view 
end 

function StorexunzhanSurr:onClose()

    EventMgr.removeListener(EventType.UpdateStoreDataXZ, self.refreshData)
    for i = 1 ,4 do 
       if self.viewlist[i] ~= nil then
           for key ,value in pairs(self.viewlist[i]) do
               if value ~= nil and value.release then  
                  if value.update ~= nil then 
                     TimerMgr.killPerFrame( value.update)
                  end 
                  value:release()
                  self.viewlist[i][key] = nil
               end 
           end 
       end
       self.viewlist[i] = nil 
    end 
end