
local prepath = "image/ui/StoreUI/"
local url = prepath .. "Storeyouxi.ExportJson"

StoreyouxiUntil = class("StoreyouxiUntil", function()
    return getLayout(url)
end)

local function confirmHandler()  
    StoreCommon.intoVip()
end 

function StoreyouxiUntil:ctor()
 

end 

function StoreyouxiUntil:button()
    StoreUntil.button(self)
end 

function StoreyouxiUntil:change()
    
    local bgurl = ItemData.getItemKuanUrl(self.bgid)
    local thingbgurl = ItemData.getItemBgUrl(self.coinbg)
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
    self.thingbg1:loadTexture(thingbgurl, ccui.TextureResType.localType) --物品框背景
    self.xunzhanlabel:setString(self.xunzhan1) --勋章label
    self.namelabel:setString(self.name) --物品名称
    StoreUntil.selectCoin(self.moneytype,{self.xunzhan})
    if self.count1 ~= 1 then 
        self.count:setString(self.count1 .. '')
    else 
        self.count:setString("")
    end 
    -- 标签    
    self.rimai:setVisible(false)  --热卖
    self.xianggou:setVisible(false) --限购
    self.xinping:setVisible(false) --新品
    if self.ctype == 1 then 
        self.rimai:setVisible(true)
    elseif self.ctype == 2 then 
        self.xianggou:setVisible(true) 
    elseif self.ctype == 3 then 
        self.xinping:setVisible(true)
    end 
    
    createScaleButton(self)
    self:button()
    local coin = CoinData.getCoinByCate(self.moneytype)
    self.open = function()
        if self.limitcount == 0 then 
            StoreTipBuy:createView({leixin = self.leixin,count = self.count1 ,name = self.name,cointype = self.moneytype ,id = self.id ,cur = self.xunzhan1,allmoney = coin,coin = self.coin,coinbg = self.coinbg})
        else 
            StoreTipDailyBuy:createView({leixin = self.leixin,count = self.count1,buyedcount = self.buyedcount,
                limitcount = self.limitcount,  cointype = self.moneytype ,
                id = self.id ,cur = self.xunzhan1,allmoney = coin,
                coin = self.coin,coinbg = self.coinbg})
        end 
    end 
    self:addTouchEnded(function()
        ActionMgr.save( 'UI', 'StoreyouxiUntil click up self') 
        self.reset()
        StoreData.StoreDataType = StoreData.Type.YX
        local coin = CoinData.getCoinByCate(self.moneytype)
        if coin < self.xunzhan1 then        
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

function StoreyouxiUntil:createView(data)
    local view = StoreyouxiUntil.new()
    view.bgid = data.bgid  --背景颜色
    view.coinbg = data.coinbg  --物品框背景颜色
    view.coin = data.coin    --物品id图片
    view.name = data.name    --物品名字
    view.xunzhan1 = data.xunzhan --物品价格
    view.id = data.id  --物品购买id
    view.buyedcount = data.buyedcount --已经购买数量
    view.limitcount = data.limitcount -- 限制购买数量
    view.ctype = data.ctype --购买标签类型
    view.moneytype = data.type  --物品货币类型
    view.leixin = data.leixin  --物品类型
    view.count1 = data.count  --物品数量
    view.winlimit = data.winlimit --物品胜利限制
    if data ~= nil  then 
       view:change()
    end 
    return view 
end 