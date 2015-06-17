-- write by weihao 
require("lua/game/view/storeUI/StoreCommon")
require("lua/game/view/storeUI/StoreUntil")
require("lua/game/view/storeUI/StoreTip")
require("lua/game/view/storeUI/StoreTipBuy")
require("lua/game/view/storeUI/StoreTipDailyBuy")
require("lua/game/view/storeUI/StoredijinSurr")
require("lua/game/view/storeUI/StorexunzhanSurr")
require("lua/game/view/storeUI/StoremeiriSurr")
require("lua/game/view/storeUI/StoreyouxiSurr")
require("lua/game/view/storeUI/StoreyongqiSurr")
require("lua/game/view/storeUI/StoreAutoSell")

local prepath = "image/ui/StoreUI/"
local url = prepath .. "StoreBg.ExportJson"
local updatekey = "Store_updatekey"

CoinType = {
    xunzhan = const.kCoinMedal ,
    zhuanshi = const.kCoinGold ,
    jinbi = const.kCoinMoney,
    mudi = const.kCoinTomb
}

StoreType = {
  xunzhan = 1,
  meiri = 2,
  yongqi = 3 ,
  dijin = 4 ,
  youxi = 5 
}
Store = createUIClass("Store", url, PopWayMgr.SMALLTOBIG)
Store.sceneName = "common"
Store.isMudi = false -- 是否为大墓地
function Store:setCoin()  
    if Store.isMudi == false and StoreData.yongqiflag == false then 
    -- 勋章
        self.xunzhanbg.xunzhan:loadTexture("storeui_xunzhanstore.png",ccui.TextureResType.plistType)
        local coin = CoinData.getCoinByCate(const.kCoinMedal)
        self.xunzhanbg.xunzhanlabel:setString(coin .."")
    else 
    -- 大墓地
        self.xunzhanbg.xunzhan:loadTexture("storeui_damudi.png",ccui.TextureResType.plistType)
        local coin = CoinData.getCoinByCate(const.kCoinTomb)
        self.xunzhanbg.xunzhanlabel:setString(coin .."")
    end
end 

function Store:ctor()
    --初始化数据
    Store.isMudi = false
    self.isUpRoleTopView = true
    StoreData.initData()
    
    createScaleButton(self.xunzhanbtn1)
    createScaleButton(self.yongqibtn1)
    createScaleButton(self.meiribtn1)
    createScaleButton(self.dijinbtn1)
    
    createScaleButton(self.xunzhanbtn2,false,nil,nil,false)
    createScaleButton(self.yongqibtn2,false,nil,nil,false)
    createScaleButton(self.meiribtn2,false,nil,nil,false)
    createScaleButton(self.dijinbtn2,false,nil,nil,false)
    
--    self.timebg:setVisible(false)
    self.timebg.timelabel:setString(21 .. '时更新')
    createScaleButton(self.chongzhibtn)
    self.chongzhibtn:setVisible(false)
    self.xunzhanbg:setVisible(true)
    createScaleButton(self.xunzhanbg.addbtn)
    self.xunzhanbg:setPositionY(518)
    
    EventMgr.addListener(EventType.UpdataXZCount, self.setCoin,self)
    EventMgr.dispatch(EventType.UpdataXZCount)
    self.xunzhanbg.addbtn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'Store click addbtn')
        if Store.isMudi == false and StoreData.yongqiflag == false then 
            StoreCommon.intoArena()
            LogMgr.debug("add xunzhan")
        else
            StoreCommon.intoMudi()
        end 

    end )
    
    self.chongzhibtn:addTouchEnded(function()
        ActionMgr.save( 'UI', 'Store click chongzhibtn') 
        LogMgr.debug("chongzhi btn")
        StoreCommon.intoVip()
    end )
  
   self.list = {{btn_selected = self.xunzhanbtn2, btn_unselected = self.xunzhanbtn1},
        {btn_selected = self.meiribtn2, btn_unselected = self.meiribtn1},
        {btn_selected = self.yongqibtn2, btn_unselected = self.yongqibtn1},
        {btn_selected = self.dijinbtn2, btn_unselected = self.dijinbtn1}}

   self.positionlist = {}
   self.positionlist ={{x1=self.xunzhanbtn1:getPositionX(),y1=self.xunzhanbtn1:getPositionY(),x2=self.xunzhanbtn2:getPositionX(),y2=self.xunzhanbtn2:getPositionY()},
   {x1=self.meiribtn1:getPositionX(),y1=self.meiribtn1:getPositionY(),x2=self.meiribtn2:getPositionX(),y2=self.meiribtn2:getPositionY()},
   {x1=self.yongqibtn1:getPositionX(),y1=self.yongqibtn1:getPositionY(),x2=self.yongqibtn2:getPositionX(),y2=self.yongqibtn2:getPositionY()},
   {x1=self.dijinbtn1:getPositionX(),y1=self.dijinbtn1:getPositionY(),x2=self.dijinbtn2:getPositionX(),y2=self.dijinbtn2:getPositionY()}}
   
   
--   local list = {{btn_selected = self.xunzhanbtn2, btn_unselected = self.xunzhanbtn1},
--        {btn_selected = self.youxibtn2, btn_unselected = self.youxibtn1},
--        {btn_selected = self.meiribtn2, btn_unselected = self.meiribtn1}}
--   local data = {StoreType.xunzhan,StoreType.youxi,StoreType.meiri}
    local data = {StoreType.xunzhan,StoreType.meiri,StoreType.yongqi,StoreType.dijin}
    self.tab = createTab(self.list, data,true)
    
    self:choose({1,2,3})
--    self.choose({1,2,3,4})
    local function uishow ()
        self.chongzhibtn:setPosition(cc.p(989,560))
        self.timebg:setVisible(true)
        
    end 

    local function handler(value)
        ActionMgr.save( 'UI', 'Store click ' .. value.data) 
        Store.isMudi = false
        StoreData.yongqiflag = false
        self.chongzhibtn:setPosition(cc.p(989,530))
        if self.xunzhanbg ~= nil then 
           self.xunzhanbg:setVisible(false)
--           self.xunzhanbg:setLocalZOrder(1)
        end
        if self.youxisurr ~= nil then  
           self.youxisurr:setVisible(false)
           self.youxisurr:setLocalZOrder(1)
        end
        if self.dijinsurr ~= nil then  
           self.dijinsurr:setVisible(false)
           self.dijinsurr:setLocalZOrder(1)
        end
        if self.xunzhansurr ~= nil then  
           self.xunzhansurr:setVisible(false)
           self.xunzhansurr:setLocalZOrder(1)
        end 
        if self.meirisurr ~= nil then 
           self.meirisurr:setVisible(false)
           self.meirisurr:setLocalZOrder(1)
        end 
        if self.yongqisurr ~= nil then 
           self.yongqisurr:setVisible(false)
           self.yongqisurr:setLocalZOrder(1)
        end 
        if value.data == StoreType.xunzhan then
            StoreData.StoreDataType = StoreData.Type.XZ
           if self.xunzhansurr == nil then 
              self.xunzhansurr = StorexunzhanSurr:createView()
              self.bg_1.vector:addChild(self.xunzhansurr)
           end 
           self.xunzhansurr:setLocalZOrder(5)
           self.xunzhanbg:setVisible(true)
           self.xunzhanbg:setPositionY(518)
           self.xunzhansurr:setVisible(true)
          
           LogMgr.debug("xunzhan")
        elseif value.data == StoreType.yongqi then
            StoreData.StoreDataType = StoreData.Type.DJ
            if self.yongqisurr == nil then 
                self.yongqisurr = StoreyongqiSurr:createView()
                self.bg_1.vector:addChild(self.yongqisurr)
            end 
            self.yongqisurr:setLocalZOrder(5)
            -- 这里得换了勋章图标改成大墓地
            Store.isMudi = true
            self.xunzhanbg:setVisible(true)

            StoreData.yongqiflag = true 
            uishow ()
            self.yongqisurr:setVisible(true)
            LogMgr.debug("yongqi")
        elseif value.data == StoreType.youxi then
            StoreData.StoreDataType = StoreData.Type.XY
            if self.youxisurr == nil then 
               self.youxisurr = StoreyouxiSurr:createView()
               self.bg_1.vector:addChild(self.youxisurr)
           end 
           self.youxisurr:setLocalZOrder(5)
           uishow ()
           self.youxisurr:setVisible(true)
           LogMgr.debug("youxi")
        elseif value.data == StoreType.meiri then
            StoreData.StoreDataType = StoreData.Type.MR
           if self.meirisurr == nil then 
              self.meirisurr = StoremeiriSurr:createView()
              self.bg_1.vector:addChild(self.meirisurr)
           end 
           self.meirisurr:setLocalZOrder(5)
           uishow ()
           self.meirisurr:setVisible(true)
           LogMgr.debug("meiri")
        elseif value.data == StoreType.dijin then 
            StoreData.StoreDataType = StoreData.Type.DJ
           if self.dijinsurr == nil then 
              self.dijinsurr = StoredijinSurr:createView()
              self.bg_1.vector:addChild(self.dijinsurr)
           end 
           self.dijinsurr:setLocalZOrder(5)
           uishow ()
           self.dijinsurr:setVisible(true)
           LogMgr.debug("dijin")
        end 
        self:setCoin()
    end
    self.tab:addEventListener(self.tab, handler)

     
end 

function Store:delayInit()
    self.sanjiao:loadTexture(prepath .. "storeui_shanjiaoxing.png",ccui.TextureResType.localType)
end

function Store:onShow()
    self.updatekey = "storekey"
    self.update = function()
        StoreData.getStoreRedPoint()

        -- 设置小时
        local time = DateTools.getHour( gameData.getServerTime())
        if time < 12 then 
            self.timebg.timelabel:setString(12 .. '时更新')
        elseif time >= 12 and time < 18 then 
            self.timebg.timelabel:setString(18 .. '时更新')
        elseif time >= 18 and time < 21 then 
            self.timebg.timelabel:setString(21 .. '时更新')
        elseif time >=21 then 
            self.timebg.timelabel:setString(12 .. '时更新')
        end 
        --设置红点
        if self.xunzhansurr ~= nil and self.xunzhansurr.updateredPoint ~= nil  then 
            self.xunzhansurr.updateredPoint()
        else 
            return 
        end 
        if self.xunzhansurr.viewlist ~= nil then 
            for i = 1 , 4 do
                if self.xunzhansurr.viewlist[i] ~= nil then 
                    for key , value in pairs(self.xunzhansurr.viewlist[i]) do 
                        if value ~= nil then 
                            value:updateRedPoint()
                        end 
                    end 
                end 
            end 
        end 


    end 
    TimerMgr.addTimeFun(self.updatekey, self.update )
    -- 创建勋章surr
    if self.xunzhansurr == nil then 
        self.xunzhansurr = StorexunzhanSurr:createView()
        self.bg_1.vector:addChild(self.xunzhansurr) 
        self.xunzhansurr:setVisible(false) 
        performWithDelay(self, function ()
            self.xunzhansurr:showScrollview()
        end, 0.2)
    end 
    if StoreData.SelectType == StoreData.Type.XZ then 
        self.xunzhansurr:setVisible(true)
        self.tab:setSelectedIndex(1)
    elseif StoreData.SelectType == StoreData.Type.MR then
        self.xunzhanbg:setVisible(false)
        if self.meirisurr == nil then 
            self.meirisurr = StoremeiriSurr:createView()
            self.bg_1.vector:addChild(self.meirisurr)
        end 
        self.tab:setSelectedIndex(2)
    elseif StoreData.SelectType == StoreData.Type.DJ then
        self.yongqisurr = StoreyongqiSurr:createView()
        self.bg_1.vector:addChild(self.yongqisurr)
        self.tab:setSelectedIndex(3)
    elseif StoreData.SelectType == StoreData.Type.YX then
        if self.youxisurr == nil then 
            self.youxisurr = StoreyouxiSurr:createView()
            self.bg_1.vector:addChild(self.youxisurr)
        end 
    end 

    StoreData.SelectType = StoreData.Type.XZ  --返回默认 选择勋章

    --提示自动贩卖
    StoreData.setAutoList()
    local data = StoreData.getAutoList()
    local flag = false 
    if data ~= nil then 
        for k,v in pairs(data) do 
            if v ~= nil then 
                flag = true 
            end 
        end 
    end 

    if flag == true and StoreData.isShowAuto == true then 
        TimerMgr.runNextFrame(function() 
             Command.run('ui show' , 'StoreAutoSell',PopUpType.SPECIAL)
        end)
    end 
    StoreData.isShowAuto = true
end 

--选择哪几个出现
function Store:choose(list)

    createTabselect (self.list ,self.positionlist,list, function()     
        local i = #list 
--        self.timebg:setPositionY(self.timebg:getPositionY() + 90*(4-i))
        end )
end 

function Store:onClose()
    StoreData.yongqiflag = false
    TimerMgr.removeTimeFun(self.updatekey)
    EventMgr.removeListener(EventType.UpdataXZCount, self.setCoin)
    if self.youxisurr ~= nil then  
        self.youxisurr:onClose()
    end
    if self.dijinsurr ~= nil then  
        self.dijinsurr:onClose()
    end
    if self.xunzhansurr ~= nil then  
        self.xunzhansurr:onClose()
    end 
    if self.meirisurr ~= nil then 
       self.meirisurr:onClose()
    end 
    if self.yongqisurr ~= nil then 
       self.yongqisurr:onClose()
    end 
end 
