
local prepath = "image/ui/StoreUI/"
local url1 = prepath .. "Storemeiri.ExportJson"

StoremeiriUntil = class("StoremeiriUntil", function()
    return getLayout(url1)
end)

local function confirmHandler()
    StoreCommon.intoVip()
end 

function StoremeiriUntil:button()
    StoreUntil.button(self)
end 

function StoremeiriUntil:ctor()
    StoreCommon:addOutline(self.count,cc.c4b(0x2d,0x12,0x00,255),2)  --字体描边
    local number = 1
    local function confirmBuy()
        Command.run( 'buy thing', self.id, number)
    end 
    createScaleButton(self)
    self:button()
    self:addTouchEnded(function()
        ActionMgr.save( 'UI', 'StoremeiriUntil click self') 
        self:setLocalZOrder(1)
        if self.pressflag == true then --tips 还没出现
            self.reset()
            return 
        end 
        self.reset()
        LogMgr.debug(debug.dump(self.data))
        StoreData.StoreDataType = StoreData.Type.MR
        local coin = CoinData.getCoinByCate(self.moneytype)
        
        if self.pressflag == false then --tips 还没出现
            if coin < self.nowmoney then 
                LogMgr.debug("in ")
                if AlteractData.canShow( self.moneytype,objid) then
                    lteractData.showByData(self.moneytype,objid)
                else
                    local str = StoreTip.getstr(self.moneytype)
                end
--                showMsgBox(str, confirmHandler)
            elseif StoreData.getWinTime() ~= nil  and self.winlimit ~= nil and self.winlimit ~= 0 then 
                LogMgr.debug("in2 ")
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
        end 
        
    end )
end 

function StoremeiriUntil:change()
    if self.donghua ~= nil then 
        self.donghua:removeFromParent()
        self.donghua = nil
    end 
    
    local bgurl = ItemData.getItemKuangeziUrl(self.bgid)
    local thingbgurl = ItemData.getItemBgUrl(self.coinbg)
    local thingurl = ItemData.getItemUrl(self.coin)
    
    local flag = true 
    if self.leixin == const.kCoinItem then  --物品
        thingurl = ItemData.getItemUrl(self.coin)
        flag = true
    elseif self.leixin == const.kCoinTotem then  --图腾
        LogMgr.debug("self.coin .. "..self.coin)
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
    self.name:setString(self.nameid)  --物品名称
    self.yuanjia:setString("原价:" .. self.oldmoney)  --原价
    self.xianjia:setString("现价:" .. self.nowmoney)  --现价
    if self.count1 ~= 1 then 
        self.count:setString(self.count1 .. '')
    else 
        self.count:setString("")
    end 
    StoreUntil.selectCoin(self.moneytype,{self.coin1,self.coin2})
    local coin = CoinData.getCoinByCate(self.moneytype)
    
    if self.buyedcount < self.limitcount then 
        self.buyed:setVisible(false)
    else
       self.line:setVisible(false)
       self.xianjia:setVisible(false)
       self.yuanjia:setVisible(false)
       self.coin1:setVisible(false)
       self.coin2:setVisible(false)
       self.buyed:setVisible(true)
    end
    self.open = function ()
--        if self.limitcount == 0 then 
--            StoreTipBuy:createView({leixin = self.leixin,count = self.count1,name = self.nameid,cointype = self.moneytype ,id = self.id ,cur = self.nowmoney,allmoney = coin,coin = self.coin,coinbg = self.coinbg})
--        else 
--            StoreTipDailyBuy:createView({leixin = self.leixin,count = self.count1,buyedcount = self.buyedcount,limitcount = self.limitcount,
--                cointype = self.moneytype ,id = self.id ,cur = self.nowmoney,allmoney = coin,
--                coin = self.coin,coinbg = self.coinbg})
--        end  
        if self.buyedcount < self.limitcount then 
            StoreTipDailyBuy:createView({leixin = self.leixin,count = self.count1,buyedcount = self.buyedcount,limitcount = self.limitcount,
                    cointype = self.moneytype ,id = self.id ,cur = self.nowmoney,allmoney = coin,
                    coin = self.coin,coinbg = self.coinbg})
        else 
            TipsMgr.showError('该商品已售罄')
            --显示已经售罄
        end 
    end 
    
end 

function StoremeiriUntil:createView(data)
    local view = StoremeiriUntil.new()
    view.bgid = data.bgid  --背景颜色
    view.coinbg = data.coinbg  --物品框背景颜色
    view.coin = data.coin    --物品id图片
    view.nameid = data.name   --物品名字
    view.oldmoney = data.oldmoney  --以前价格
    view.nowmoney = data.nowmoney  --现在价格
    view.id = data.id      --物品购买id
    view.buyedcount = data.buyedcount  --物品已购买数量
    view.limitcount = data.limitcount  --物品限制购买数量
    view.moneytype = data.type        --物品货币类型
    view.leixin = data.leixin --物品类型
    view.count1 = data.count --物品数量
    view.winlimit = data.winlimit  --物品胜利限制
    view.data = data 
    if data ~= nil  then 
        view:change()
    end 
    return view 
end 