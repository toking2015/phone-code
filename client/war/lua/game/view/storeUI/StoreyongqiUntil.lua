local prepath = "image/ui/StoreUI/"
local url = prepath .. "Storedijing.ExportJson"

StoreyongqiUntil = class("StoreyongqiUntil", function()
    return getLayout(url)
end)



local function confirmHandler()
    StoreCommon.intoVip()
end 

function StoreyongqiUntil:button()    
    StoreUntil.button(self)
end 
function StoreyongqiUntil:ctor()
    
    local number = 1
    local function confirmBuy()
        Command.run( 'buy thing', self.id, number)
    end 
--    self:setTouchEnabled(false)
--    ChatCommon.initBtn(self ,true,false)
   createScaleButton(self)
   self:button()
   self:addTouchEnded(function()
        ActionMgr.save( 'UI', 'StoreyongqiUntil click up self') 
        self:setLocalZOrder(1)
       if self.pressflag == true then --tips 还没出现
            self.reset()
            return 
       end 
       self.reset()
       if self.startlocaltion ~= nil and self.endlocaltion ~= nil then 
          if self.startlocaltion.y - self.endlocaltion.y >= 40 or self.startlocaltion.y - self.endlocaltion.y <= -40 then 
             return 
          end 
       end 
       if StoreData.yongqiflag == false then 
          return 
       end 
       if self:isVisible() ~= true then 
          return 
       end 
       if self.buyed:isVisible() == true then 
          TipsMgr.showError('已售罄')
          return 
       end  
        

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
    end )
end 

function StoreyongqiUntil:change()  
    if self.donghua ~= nil then 
       self.donghua:removeFromParent()
       self.donghua = nil 
    end 
    local bgurl = ItemData.getItemKuangeziUrl(self.bgid)
    local thingbgurl = ItemData.getItemBgUrl(self.coinbg)
    local thingurl = ItemData.getItemUrl(self.coin)
    StoreCommon:addOutline(self.count,cc.c4b(0x2d,0x12,0x00,255),2)  --字体描边
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
        self.donghua:setLocalZOrder(5)
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
    
    if self.buyedcount < self.limitcount then 
       self.buyed:setVisible(false)
       self.money:setVisible(true)
       self.coin1:setVisible(true)
    else 
       self.buyed:setVisible(true)
       self.money:setVisible(false)
       self.coin1:setVisible(false)
    end 
    
    StoreUntil.selectCoin(self.moneytype,{self.coin1})
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

function StoreyongqiUntil:refreshData(data)
    self.bgid = data.bgid  --背景颜色
    self.coinbg = data.coinbg  --物品框背景颜色
    self.coin = data.coin --物品id图片
    self.nameid = data.name  --物品名字
    self.moneyid = data.money  --物品价格
    self.id = data.id     --物品购买id
    self.buyedcount = data.buyedcount --已经购买数量
    self.limitcount = data.limitcount -- 限制购买数量
    self.moneytype = data.type  --物品货币类型
    self.leixin = data.leixin   --物品类型
    self.count1 = data.count    --物品数量
    self.winlimit = data.winlimit --物品胜利限制
    if data ~= nil then 
        self:change()
    end 
end 
function StoreyongqiUntil:onClose()
    local eventDispatcher = self:getEventDispatcher()
    eventDispatcher:removeEventListener(self.listener)
end

function StoreyongqiUntil:createView(data)
    local view = StoreyongqiUntil.new()
    if data ~= nil then 
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
    end 
    if data ~= nil then 
        view:change()
    end 
    return view 
end 