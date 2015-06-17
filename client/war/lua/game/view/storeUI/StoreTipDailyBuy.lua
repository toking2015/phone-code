local prepath = "image/ui/StoreUI/"
local url1 = prepath .. "StoreTip1.ExportJson"

StoreTipDailyBuy = createUIClass("StoreTipDailyBuy", url1, PopWayMgr.SMALLTOBIG)
local cur = 100
local allmoney = 100
local id = -1
local coin = 1
local coinbg = 1
local cointype = 2
local buyedcount = 0
local limitcount = 0
local count = 1
local leixin = const.kCoinItem
function StoreTipDailyBuy:buy()
    if id ~= -1 then 
        Command.run( 'buy thing', id, 1)  
    end 
    
end  
function StoreTipDailyBuy:ctor()
    createScaleButton(self.cancle)
    createScaleButton(self.sure)
    self.buyed:setVisible(false)
    self.cancle:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'StoreTipDailyBuy click up cancle')
        Command.run('ui hide', 'StoreTipDailyBuy')
    end )
    self.sure:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'StoreTipDailyBuy click up sure')
        LogMgr.debug("allmoney.. " .. allmoney)
        LogMgr.debug("cur .. " .. cur)
        if allmoney >= cur and limitcount - buyedcount > 0 then 
            self:buy()
        end
        Command.run('ui hide', 'StoreTipDailyBuy')
    end )
    
    Command.bind( 'buywatertotemsure', 
        function()
            if allmoney >= cur and limitcount - buyedcount > 0 then 
                self:buy()
            end
            Command.run('ui hide', 'StoreTipDailyBuy')
        end 
    )

    self.znumber:setString("1")  --消耗多少
    self.cnumber:setString("1")  --剩余次数
end 

function StoreTipDailyBuy:onShow()
    self.znumber:setString(cur .. '')
    self.cnumber:setString((limitcount - buyedcount) .. '')
    StoreCommon:addOutline(self.count,cc.c4b(0x2d,0x12,0x00,255),2)  --字体描边  
    if count ~= 1 then 
        self.count:setString(count..'')
    else 
        self.count:setString("")
    end 
    if limitcount - buyedcount <= 0 then 
        self.buyed:setVisible(true)
        self.shenyu:setVisible(false)
        self.cnumber:setVisible(false)
    end 
    local thingbgurl = ItemData.getItemBgUrl(coinbg)
    local thingurl = ItemData.getItemUrl(coin) 
    
    local flag = true 
    if leixin == const.kCoinItem then  --物品
        thingurl = ItemData.getItemUrl(coin)
        flag = true
    elseif leixin == const.kCoinTotem then  --图腾
        thingurl = TotemData.getAvatarUrlById(coin)
        flag = true
    elseif leixin == const.kCoinGlyph then   --雕文  
        self.coin:setVisible(false)
        self.donghua = TotemData.getGlyphObject(coin,"StoreTipDailyBuy",self,self.coin:getPositionX(),self.coin:getPositionY())
        flag = false
    elseif leixin == const.kCoinMoney then   --金币
        self.coin:loadTexture("image/icon/coin/1.png",ccui.TextureResType.localType)
        flag = false
    elseif leixin == const.kCoinGold then   --钻石
        self.coin:loadTexture("image/icon/coin/3.png",ccui.TextureResType.localType)
        flag = false
    elseif leixin == const.kCoinWater then  --圣水
        self.coin:loadTexture("image/icon/coin/12.png",ccui.TextureResType.localType)
        flag = false
    end 
    if flag == true then 
        self.coin:loadTexture(thingurl, ccui.TextureResType.localType) --物品图标
    end
    
    self.coin.leixin = leixin
    self.coin.coin = coin
    createScaleButton(self.coin,false)
    StoreUntil.button(self.coin)
    self.coin:addTouchEnded(function() 
        self.coin:setLocalZOrder(1)
        self.coin.reset()
    end)
    self.coinbg:loadTexture(thingbgurl, ccui.TextureResType.localType) --物品图标
    StoreUntil.selectCoin(cointype,{self.zhuanshi})
   
    

end 

function StoreTipDailyBuy:onClose()

end

function StoreTipDailyBuy:createView(data)
    if data ~= nil then
--        LogMgr.debug("data.limitcount .." .. data.limitcount) 
        cur = data.cur
        allmoney = data.allmoney
        id = data.id
        coin = data.coin
        coinbg = data.coinbg
        cointype = data.cointype
        buyedcount = data.buyedcount
        limitcount = data.limitcount
--        LogMgr.debug("data.count" .. data.count)
        count = data.count
        leixin = data.leixin
    else 
        allmoney = 0
        cur = 100
        id = -1
        coin = 1
        coinbg = 1
        cointype = CoinType.zhuanshi
        buyedcount = 0
        limitcount = 0
        count = 1
        leixin = const.kCoinItem
    end
    Command.run('ui show', 'StoreTipDailyBuy', PopUpType.SPECIAL )
end 