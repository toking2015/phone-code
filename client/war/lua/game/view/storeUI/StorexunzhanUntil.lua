
local prepath = "image/ui/StoreUI/"
local url = prepath .. "Storexunzhan.ExportJson"

StorexunzhanUntil = class("StorexunzhanUntil", function()
    return getLayout(url)
end)

local function confirmHandler()
    StoreCommon.intoArena()
end 


function StorexunzhanUntil:button()
    
    StoreUntil.button(self)
end 
function StorexunzhanUntil:ctor()
    local number = 1
    createScaleButton(self)  
    self:button()
    self:addTouchEnded(function()  
        ActionMgr.save( 'UI', 'StorexunzhanUntil click up self')    
        StoreData.StoreDataType = StoreData.Type.XZ
        local coin = CoinData.getCoinByCate(self.moneytype)
        if self.pressflag == false then --tips 还没出现
            if StoreData.getWinTime() ~= nil and self.winlimit ~= nil and self.winlimit ~= 0 and self.winlimit > StoreData.getWinTime() then 
                TipsMgr.showError('需要竞技场胜利' .. self.winlimit .. '场')  
            elseif coin < self.xunzhan1 then 
                if AlteractData.canShow( self.moneytype,objid) then
                    AlteractData.showByData(self.moneytype,objid)
                else
                    local str = StoreTip.getstr(self.moneytype)
                end
            else      
                self.open ()
            end
        end 
        self.reset()
        self:setLocalZOrder(1)
    end )
end 

function StorexunzhanUntil:updateRedPoint()
    if  StoreData.ingoreRedPoint(self.coin) then -- 忽略礼包
        if self.winlimit ~= nil and self.winlimit ~= 0 and self.winlimit > StoreData.getWinTime() then 
    
        else 
            local coin = CoinData.getCoinByCate(self.moneytype)
            local size = self:getSize()
            local off = cc.p(size.width - 8,size.height - 8)
            if coin >= self.xunzhan1 then 
--                setButtonPoint( self, true ,off)
                setButtonPoint( self, false ,off) -- 屏蔽红点
            else 
                setButtonPoint( self, false ,off)
            end 
        end
    end 
end 

function StorexunzhanUntil:change()
    if self.donghua ~= nil then 
       self.donghua:removeFromParent()
       self.donghua = nil
    end 
    LogMgr.debug(debug.dump(self.data))
    StoreCommon:addOutline(self.count,cc.c4b(0x2d,0x12,0x00,255),2)  --字体描边
    if self.count1 ~= 1 then 
        self.count:setString(self.count1 .. '')
    else 
        self.count:setString("")
    end 
    local bgurl = ItemData.getItemYuankuanUrl(self.bgid)
--    local thingbgurl = ItemData.getItemBgUrl(self.coinbg)
    local thingurl = ItemData.getItemUrl(self.coin) 
    local flag = true 
    if self.leixin == const.kCoinItem then  --物品
        thingurl = ItemData.getItemUrl(self.coin)
        flag = true
    elseif self.leixin == const.kCoinTotem then  --图腾
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
--    self.thingbg1:loadTexture(thingbgurl, ccui.TextureResType.localType) --物品框背景
    self.xunzhanlabel:setString(self.xunzhan1) --勋章label
    self.namelabel:setString(self.name) --物品名称
    StoreUntil.selectCoin(self.moneytype,{self.xunzhan})
    local coin = CoinData.getCoinByCate(self.moneytype)
   
    self.jiaqian:setVisible(false)
    self.xunzhanlabel:setVisible(false)
    self.xunzhan:setVisible(false)
    self.jinjichang1:setVisible(false)
    self.kegoumai:setVisible(false)
    self.num:setVisible(false)
    self.ci:setVisible(false)
--    LogMgr.debug("StoreData.getWinTime() .. " ..  self.winlimit)
    if self.winlimit ~= nil and self.winlimit ~= 0 and self.winlimit > StoreData.getWinTime() then 
        self.jinjichang1:setVisible(true)
        self.kegoumai:setVisible(true)
        self.num:setVisible(true)
        self.ci:setVisible(true)
        self.num:setString(self.winlimit .. '')
    else 
        self.jiaqian:setVisible(true)
        self.xunzhanlabel:setVisible(true)
        self.xunzhan:setVisible(true)
        local size = self:getSize()
        local off = cc.p(size.width - 8,size.height - 8)
        if StoreData.ingoreRedPoint(self.coin) and  coin >= self.xunzhan1 then  -- 忽略礼包
--           setButtonPoint( self, true ,off)
            setButtonPoint( self, false ,off)     --屏蔽红点
        end 
    end
    
    self.open = function ()

        if (self.limitcount == 0 or self.limitcount == nil) and (self.hislimit == 0 or self.hislimit == nil) and (self.daylimit == 0 or self.daylimit == nil) and (self.severlimit == 0 or self.severlimit == nil) then 
            StoreTipBuy:createView({leixin = self.leixin,count = self.count1,name = self.name,cointype = self.moneytype ,id = self.id ,cur = self.xunzhan1,allmoney = coin,coin = self.coin,coinbg = self.coinbg})
        
        elseif self.hislimit <= self.buyedcount and self.daylimit <= self.buyedcount and self.serverlimit <= self.buyedcount then 
            TipsMgr.showError('购买次数已超过') 
        else
--            StoreTipBuy:createView({leixin = self.leixin,count = self.count1,name = self.name,cointype = self.moneytype ,id = self.id ,cur = self.xunzhan1,allmoney = coin,coin = self.coin,coinbg = self.coinbg})
            local num = 1
            if self.limitcount ~=nil then 
                num = self.limitcount
            elseif self.hislimit ~= nil then
                num = self.hislimit 
            elseif self.daylimit ~= nil then
                num = self.daylimit
            elseif self.severlimit ~= nil then
                num = self.severlimit 
            end 
            StoreTipDailyBuy:createView({leixin = self.leixin,count = self.count1,buyedcount = self.buyedcount,limitcount = num,
                cointype = self.moneytype ,id = self.id ,cur = self.xunzhan1,allmoney = coin,
                coin = self.coin,coinbg = self.coinbg})
        end 
    end 
    if self.coin ==  80201 then  --生命之泉
        Command.bind( 'buywatertotem' , 
            function()
                self.open()
            end 
        )
        Command.bind('watertotemself' ,
            function()
               return self
            end 
        )
        
    end 

end 

function StorexunzhanUntil:createView(data)
    local view = StorexunzhanUntil.new()
    view.bgid = data.bgid  --背景颜色
    view.coinbg = data.coinbg  --物品框背景颜色
    view.coin = data.coin    --物品id图片
    view.name = data.name    --物品名字
    view.xunzhan1 = data.xunzhan --物品价格
    view.id = data.id  --物品购买id
    view.buyedcount = data.buyedcount --已经购买数量
    view.limitcount = data.limitcount -- 限制购买数量
    view.moneytype = data.type  --物品货币类型
    view.leixin = data.leixin  --物品类型
    view.count1 = data.count  --物品数量
    view.winlimit = data.winlimit --物品胜利限制
    
    view.hislimit = data.hislimit    --历史限制  
    view.daylimit = data.daylimit    --每天限制
    view.serverlimit = data.serverlimit  --全服限制
    view.data = data
    
    if data ~= nil  then 
       view:change()
    end 
    return view  
end 