
local prepath = "image/ui/StoreUI/"
local url = prepath .. "Storedijing.ExportJson"

StoredijinUntil = class("StoredijinUntil", function()
    return getLayout(url)
end)

local function confirmHandler()
    StoreCommon.intoVip()
end 

function StoredijinUntil:button()
    StoreUntil.button(self)
--   self.updatekey = "dijinkey"
--   self.pressflag = false
--   self.updatetime = 0 
--   self.reset = function()
--      TimerMgr.killPerFrame( self.update)
--      self.pressflag = false
--      self.updatetime = 0
--      self.tip = StoreTip.showTip()
--      if self.tip ~= nil then 
--         self.window:removeChild(self.tip,true)
--      end 
--      LogMgr.debug("有tip 就消失")
--   end 
--   self.update = function(dt)
--      if self.pressflag == true then 
--         self.updatetime = self.updatetime + dt
--      end 
--      if self.updatetime > StoreUntil.tiptime then 
--         LogMgr.debug("出现tip")
--         self.tip = StoreTip.showTip()
--         self.tip:setPosition(cc.p(self:getPositionX()+StoreUntil.fx,self:getPositionY()+StoreUntil.fy))
--         self.window:addChild(self.tip,3)
--         TimerMgr.killPerFrame( self.update)
--         self.pressflag = false
--         self.updatetime = 0
--         
--      end 
--   end 
--   self:addTouchBegan(function()
--        self.window = StoreUntil.getWindow()
--        self.reset()
--        self.pressflag = true 
--        TimerMgr.callPerFrame(self.update)
--        self:setLocalZOrder(100)
--   end)
--   self:addTouchCancel(function()
--        self:setLocalZOrder(1)
--        self.reset()
--   end)
end 
function StoredijinUntil:ctor()
    local number = 1
    local function confirmBuy()
        Command.run( 'buy thing', self.id, number)
    end 
   createScaleButton(self)
   self:button()
   self:addTouchEnded(function()
        ActionMgr.save( 'UI', 'StoredijinUntil click self') 
        self.reset()
        StoreData.StoreDataType = StoreData.Type.DJ
        local coin = CoinData.getCoinByCate(self.moneytype)
        if coin < self.moneyid then 
            local str = StoreTip.getstr(self.moneytype)
--            showMsgBox(str, confirmHandler)
        elseif StoreData.getWinTime() ~= nil and self.winlimit ~= nil and self.winlimit ~= 0 then 
            if self.winlimit > StoreData.getWinTime() then 
                local str = StoreTip.getArenastr()
                showMsgBox(str,function ()  
                    Command.run('ui show' , 'ArenaUI',PopUpType.SPECIAL)
                end )
            else 
                self.open ()
            end 
        
        else      
            self.open ()
        end
        self:setLocalZOrder(1)
    end )
end 

function StoredijinUntil:change()  
    local bgurl = ItemData.getItemKuangeziUrl(self.bgid)
    local thingbgurl = ItemData.getItemBgUrl(self.coinbg)
    local thingurl = ItemData.getItemUrl(self.coin)
    
    local flag = true 
    if self.leixin == const.kCoinItem then  --物品
        thingurl = ItemData.getItemUrl(self.coin)
        flag = true
    elseif self.leixin == const.kCoinTotem then  --图腾
--        LogMgr.debug("self.coin .. "..self.coin)
        thingurl = TotemData.getAvatarUrlById(self.coin)
        flag = true
    elseif self.leixin == const.kCoinGlyph then   --雕文  
        self.thingcoin:setVisible(false)
        self.donghua = TotemData.getGlyphObject(self.coin,"Store",self,self.thingcoin:getPositionX(),self.thingcoin:getPositionY())
        flag = false
    end 
    if flag == true then 
        self.thingcoin:loadTexture(thingurl, ccui.TextureResType.localType) --物品图标
    end
    
    self.bg:loadTexture(bgurl, ccui.TextureResType.localType)  --背景
    self.thingbg1:loadTexture(thingbgurl, ccui.TextureResType.localType) --物品框背景 
    self.name:setString(''..self.nameid)   --物品名称
    self.money:setString("价钱:" .. self.moneyid)  --价钱
    if self.count1 ~= 1 then 
        self.count:setString(self.count1 .. '')
    else 
        self.count:setString("")
    end 
    StoreUntil.selectCoin(self.moneytype,{self.coin})
    local coin = CoinData.getCoinByCate(self.moneytype)
    self.open = function ()
        if self.limitcount == 0 then 
            StoreTipBuy:createView({leixin = self.leixin,count = self.count1,name = self.nameid,cointype = self.moneytype ,id = self.id ,
                cur = self.moneyid,allmoney = coin,coin = self.coin,coinbg = self.coinbg})
        else 
            StoreTipDailyBuy:createView({leixin = self.leixin,count = self.count1,buyedcount = self.buyedcount,limitcount = self.limitcount,
                cointype = self.moneytype ,id = self.id ,cur = self.moneyid,allmoney = coin,
                coin = self.coin,coinbg = self.coinbg})
        end 
    end   
end 

function StoredijinUntil:createView(data)
    local view = StoredijinUntil.new()
    view.bgid = data.bgid  --背景颜色
    view.coinbg = data.coinbg  --物品框背景颜色
    view.coin = data.coin --物品id图片
    view.nameid = data.name  --物品名字
    view.moneyid = data.money  --物品价格
    view.id = data.id     --物品购买id
    view.buyedcount = data.buyedcount --已经购买数量
    view.limitcount = data.limitcount -- 限制购买数量
    view.moneytype = data.type  --物品货币类型
    view.leixin = data.leixin   --物品类型
    view.count1 = data.count    --物品数量
    view.winlimit = data.winlimit --物品胜利限制
    if data ~= nil then 
        view:change()
    end 
    return view 
end 