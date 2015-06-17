local prepath = "image/ui/StoreUI/"
local url1 = prepath .. "StoreTip3.ExportJson"

StoreTipBuy = createUIClass("StoreTipBuy", url1, PopWayMgr.SMALLTOBIG)
local cur = 100
local allmoney = 100
local id = -1
local coin = 1
local coinbg = 1
local cointype = 2
local name = "商品"
local count = 1
local leixin = const.kCoinItem
function StoreTipBuy:buy()
    local num = tonumber(self.input:getText())
    if id ~= -1 then 
        Command.run( 'buy thing', id, num)
    end 
    Command.run('ui hide', 'StoreTipBuy')
   
    
end  

function StoreTipBuy:ctor()

    local txt_input = self.text
    local t_size = txt_input:getSize()
    self.input = TextInput:create(t_size.width, t_size.height)
    FontStyle.applyStyle(self.input, FontStyle.ZH_3)
    txt_input:setVisible(false)
    self.input:setText( 1 .. '')
    self.input:setFontColor(cc.c3b(255, 174, 1))
    self.input:setPosition(txt_input:getPositionX() - t_size.width/2, txt_input:getPositionY() )
    self.input:setMaxLength(8)  --设置最多字数
    self:addChild(self.input)
    
    createScaleButton(self.sub)
    createScaleButton(self.add)
    createScaleButton(self.cancle)
    createScaleButton(self.sure)
    
    self.fitcoin = function()
        local dwidth = self.dwnum:getSize().width 
        local hwidth = self.hfnum:getSize().width 

        self.coin2:setPositionX(self.hfnum:getPositionX() + hwidth + 20)
        self.coin1:setPositionX(self.dwnum:getPositionX() + dwidth + 20)
    end 
    
    self.subfun = function()
        local num = tonumber(self.input:getText())
        num = num - 1 
        if num < 1 then
            num = 1
        end  
        if num >= 1 then 
            self.input:setText(num .. '')
            self.buynum1:setString(num .. '')
            self.hfnum:setString(num*cur .. '')
        end 
        self.fitcoin()
    end

    self.addfun = function()
        local num = tonumber(self.input:getText())
        num = num + 1 
        -- 没有最大限制
--        if num >= count then
--            num = count
--        end     
        if num >= 1 then 
            if allmoney >= num*cur then 
--                self.buynum:setString(num .. '')
                self.input:setText( num .. '')
                self.buynum1:setString(num .. '')
                self.hfnum:setString(num*cur .. '')
            end 
        end
        self.fitcoin() 
    end 

    self.sub:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'StoreTipBuy click up sub') 
        self.subfun()
        self:clearTimer("downTimer")
    end)

    self.sub:addTouchCancel(function()
        ActionMgr.save( 'UI', 'StoreTipBuy click up sub') 
        self:clearTimer("downTimer")
    end)
    self.sub:addTouchBegan(function()
        ActionMgr.save( 'UI', 'StoreTipBuy click down sub') 
        self:startDownTimer(2)
    end)

    self.add:addTouchEnded(function()
        ActionMgr.save( 'UI', 'StoreTipBuy click up add') 
        self.addfun()
        self:clearTimer("downTimer")
    end )

    self.add:addTouchCancel(function()
        ActionMgr.save( 'UI', 'StoreTipBuy click up add') 
        self:clearTimer("downTimer")
    end)
    self.add:addTouchBegan(function()
        ActionMgr.save( 'UI', 'StoreTipBuy click down add') 
        self:startDownTimer(1)
    end)


    self.cancle:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'StoreTipBuy click up cancle') 
        Command.run('ui hide', 'StoreTipBuy')
    end )
    self.sure:addTouchEnded(function()
        ActionMgr.save( 'UI', 'StoreTipBuy click up sure')  
        local money = tonumber(self.hfnum:getString())
        if allmoney >= money then 
            self:buy()
        else 
            if cointype == CoinType.xunzhan then 
                TipsMgr.showError('勋章不足')
            elseif cointype == CoinType.zhuanshi then
                TipsMgr.showError('钻石不足')
            elseif cointype == CoinType.jinbi then
                TipsMgr.showError('金币不足')
            end 
        end
        
    end )
    
    self.update = function ()
        local num = 1
        if self.input:getText() ~= nil then 
           if type(tonumber(self.input:getText())) == "number" then
              num = math.floor(tonumber(self.input:getText()))
              if num <= 0 then 
                 num = 1
              end 
              if allmoney >= num*cur then                  
                  self.input:setText( num .. '')
                  self.buynum1:setString(num .. '')
                  self.hfnum:setString(num*cur .. '')
              else
                  num = math.floor(allmoney/cur)
                  self.input:setText( num .. '')
                  self.buynum1:setString(num .. '')
                  self.hfnum:setString(num*cur .. '')
              end 
              self.fitcoin()
           end 
        end 

    end 
    self.updatekey = TimerMgr.startTimer( self.update , 0.01, false )
    self.buynum:setVisible(false)
    self.buynum:setString("1")
    self.buynum1:setString("1")
    self.dwnum:setString("500")
    self.hfnum:setString("100")
end 

function StoreTipBuy:delayInit()
    self.Image_27_0:loadTexture("image/ui/StoreUI/storeui_shangkuan.png",ccui.TextureResType.localType)  
end 

function StoreTipBuy:onShow()
    self.name:setString(name)
    self.dwnum:setString(cur .. '')
    self.hfnum:setString(cur .. '')
    StoreCommon:addOutline(self.count,cc.c4b(0x2d,0x12,0x00,255),2)  --字体描边  
    if count ~= 1 then 
        self.count:setString(count..'')
    else 
        self.count:setString("")
    end 
    
    local thingbgurl = ItemData.getItemBgUrl(coinbg)
    local thingurl = ItemData.getItemUrl(coin) 
    self.fitcoin()
    local flag = true 
    if leixin == const.kCoinItem then  --物品
        thingurl = ItemData.getItemUrl(coin)
        flag = true
    elseif leixin == const.kCoinTotem then  --图腾
        thingurl = TotemData.getAvatarUrlById(coin)
        flag = true
    elseif leixin == const.kCoinGlyph then   --雕文  
        self.thingcoin:setVisible(false)
        self.donghua = TotemData.getGlyphObject(coin,"StoreTipBuy",self,self.coin:getPositionX(),self.coin:getPositionY())
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
    if cointype == CoinType.xunzhan then 
        self.coin1:loadTexture("storeui_xunzhanstore.png",ccui.TextureResType.plistType)
        self.coin2:loadTexture("storeui_xunzhanstore.png",ccui.TextureResType.plistType)
    elseif cointype == CoinType.zhuanshi then 
        self.coin1:loadTexture("storeui_zhuanshi.png",ccui.TextureResType.plistType)
        self.coin2:loadTexture("storeui_zhuanshi.png",ccui.TextureResType.plistType)
    elseif cointype == CoinType.jinbi then 
        self.coin1:loadTexture("storeui_coin1.png",ccui.TextureResType.plistType)
        self.coin2:loadTexture("storeui_coin1.png",ccui.TextureResType.plistType)
    end 
end 

function StoreTipBuy:onClose()
    if self.updatekey ~= nil then 
       TimerMgr.killTimer(self.updatekey)
       self.updatekey = nil 
    end 
end

function StoreTipBuy:createView(data)
    if data ~= nil then 
       cur = data.cur
       allmoney = data.allmoney
       id = data.id
       coin = data.coin
       coinbg = data.coinbg
       cointype = data.cointype
       name = data.name 
       count = data.count
       leixin = data.leixin
    else 
       allmoney = 0
       cur = 100
       id = -1
       coin = 1
       coinbg = 1
       count = 1
       cointype = CoinType.zhuanshi
       leixin = const.kCoinItem
       name = "商品"
    end
    Command.run('ui show', 'StoreTipBuy', PopUpType.SPECIAL )
end 

function StoreTipBuy:startDownTimer(flag)
    local  function idle( )
        self.beginTime = self.beginTime+1
        if self.beginTime >= self.saveMax or self.saveMax < 0 then
            self.beginTime = 1
            self.longClick = true
            if self.flag == 1 then
                -- 一为加 
                self.addfun()
            elseif self.flag == 2 then 
                -- 二为减
                self.subfun()
            end
            self.saveMax = self.saveMax - 1
        end
    end

    self:clearTimer("downTimer")
    self.flag = flag
    self.longClick = false
    self.beginTime  = 0
    self.saveMax = 12
    self.downTimer = TimerMgr.startTimer( idle, 0.01, false )
end 

function StoreTipBuy:clearTimer( name )
    if self[name] == nil then
        return
    end

    if self[name] ~= nil  then
        TimerMgr.killTimer(self[name])
        self[name] = nil
    end
end

