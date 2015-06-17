local prepath = "image/ui/StoreUI/"
local url = prepath .. "StoreAchieveSurr.ExportJson"
StoreAchieveSurr = class("StoreyongqiSurr", function()
    return getLayout(url)
end)

function StoreAchieveSurr:ctor()
    self.bg:loadTexture(prepath .. "storeui_dibg.png", ccui.TextureResType.localType) --物品图标
    
    if StoreData.Achieve == "MD" then 
       self.btn1:setPosition(cc.p(-5,12))
       self.btn2:setPosition(cc.p(285+10,12))
       self.btn3:setPosition(cc.p(573+19,12))
       self.bg:setPosition(cc.p(0,7))
       for num = 1 , 3 do 
           self["btn" .. num].count:setPosition(95,20)  
           self["btn" .. num].w:setPosition(105,30)
           self["btn" .. num]. namelabel:setFontSize(20)
           self["btn" .. num].bg:loadTexture(prepath .. "ItemAchievekuan/item_1_1.png", ccui.TextureResType.localType) --物品图标
       end 
    elseif  StoreData.Achieve == "JJ" then 
       for num = 1 , 3 do
           self["btn" .. num].thingcoin:setScale(0.7)
           self["btn" .. num].bg:loadTexture(prepath .. "ItemAchievekuan/item_2_1.png", ccui.TextureResType.localType) --物品图标
       end 
    end 
    for i = 1 , 3 do  
        createScaleButton(self["btn" .. i])    
        StoreCommon:addOutline(self["btn" .. i].count,cc.c4b(0x2d,0x12,0x00,255),2)  --字体描边
        self["btn" .. i]:setVisible(false)
        self["btn" .. i]:addTouchEnded(function() 
            ActionMgr.save( 'UI', 'StoreAchieveSurr click down btn' .. i )
            self["btn" .. i]:setLocalZOrder(1)
            if self["btn" .. i].pressflag == true then --tips 还没出现
                self["btn" .. i].reset()
                return 
            end 
            self["btn" .. i].reset()
            if self["btn" .. i].data1.open == false then 
                TipsMgr.showError(self["btn" .. i].data1.string .. tonumber(self["btn" .. i].data1.string1) .. string.gsub(self["btn" .. i].data1.string2," ","") .. "即可购买")
                return 
            end 
            local coin = CoinData.getCoinByCate( self["btn" .. i].moneytype)
            if self["btn" .. i].buyedcount < self["btn" .. i].limitcount then 
                StoreTipDailyBuy:createView({leixin = self["btn" .. i].leixin,count = self["btn" .. i].count1,buyedcount = self["btn" .. i].buyedcount,limitcount = self["btn" .. i].limitcount,
                    cointype = self["btn" .. i].moneytype ,id = self["btn" .. i].id ,cur = self["btn" .. i].nowmoney,allmoney = coin,
                    coin = self["btn" .. i].coin,coinbg = self["btn" .. i].coinbg})
            else 
                TipsMgr.showError('该商品已售罄')
                --显示已经售罄
            end 
        end)
    end   
    self:refreshData()
    EventMgr.addListener(EventType.UpdateStoreDataAch, self.refreshData,self)
end 

function StoreAchieveSurr:refreshData()
    
    local data = StoreData.getShowAchData()
    local num = 0 
    for key ,value in pairs(data) do
        if value ~= nil then 
           num = num + 1
           if num > 0 and num <=3 then 
              StoreUntil.button(self["btn" .. num])
              self["btn" .. num]:setVisible(true)
              self["btn" .. num].bgid = value.bgid  --背景颜色
              self["btn" .. num].coinbg = value.coinbg  --物品框背景颜色
              self["btn" .. num].coin = value.coin    --物品id图片
              self["btn" .. num].nameid = value.name   --物品名字
              self["btn" .. num].nowmoney = value.xunzhan  --现在价格
              self["btn" .. num].id = value.id      --物品购买id
              self["btn" .. num].buyedcount = value.buyedcount  --物品已购买数量
              self["btn" .. num].limitcount = value.hislimit  --物品限制购买数量
              self["btn" .. num].moneytype = value.type        --物品货币类型
              self["btn" .. num].leixin = value.leixin --物品类型
              self["btn" .. num].count1 = value.count --物品数量
              self["btn" .. num].winlimit = value.winlimit  --物品胜利限制
              self["btn" .. num].data1 = value
              local bgurl = ItemData.getItemKuangeziUrl(self.bgid)
              local thingbgurl = "image/ui/StoreUI/ItemAchievekuan/" .. "item_2_" .. self["btn" .. num].coinbg .. ".png"
              if StoreData.Achieve == "MD" then 
                 thingbgurl = "image/ui/StoreUI/ItemAchievekuan/" .. "item_1_" .. self["btn" .. num].coinbg .. ".png"
              elseif StoreData.Achieve == "JJ" then 
                 thingbgurl = "image/ui/StoreUI/ItemAchievekuan/" .. "item_2_" .. self["btn" .. num].coinbg .. ".png"
              end 
              local thingurl = ItemData.getItemUrl(self["btn" .. num].coin)
              local flag = true 
              if self["btn" .. num].leixin == const.kCoinItem then  --物品
                    thingurl = ItemData.getItemUrl(self["btn" .. num].coin)
                    flag = true
              elseif self.leixin == const.kCoinTotem then  --图腾
                    thingurl = TotemData.getAvatarUrlById(self["btn" .. num].coin)
                    flag = true
              elseif self["btn" .. num].leixin == const.kCoinGlyph then   --雕文  
                    self["btn" .. num].thingcoin:setVisible(false)
                    self["btn" .. num].donghua = TotemData.getGlyphObject(self["btn" .. num].coin,"Store",self["btn" .. num],self["btn" .. num].thingcoin:getPositionX(),self["btn" .. num].thingcoin:getPositionY())
                    self["btn"  .. num].donghua:setLocalZOrder(5) 
                    flag = false
              elseif self["btn" .. num].leixin == const.kCoinMoney then   --金币
                    self["btn" .. num].thingcoin:loadTexture("image/icon/coin/1.png",ccui.TextureResType.localType)
                    flag = false
              elseif self["btn" .. num].leixin == const.kCoinGold then   --钻石
                    self["btn" .. num].thingcoin:loadTexture("image/icon/coin/3.png",ccui.TextureResType.localType)
                    flag = false
              elseif self["btn" .. num].leixin == const.kCoinWater then  --圣水
                    self["btn" .. num].thingcoin:loadTexture("image/icon/coin/12.png",ccui.TextureResType.localType)
                    flag = false
              end 
              self["btn" .. num].namelabel:setString(self["btn" .. num].nameid)
              self["btn" .. num].xunzhanlabel:setString(self["btn" .. num].nowmoney)  --价钱
              self["btn"  .. num].w:setLocalZOrder(6)
              if self["btn" .. num].count1 == 1 then 
                 self["btn" .. num].count:setString("")
              else 
                 if self["btn" .. num].count1 < 10000 then 
                    self["btn" .. num].count:setString(self["btn" .. num].count1 .. '')
                    self["btn" .. num].w:loadTexture("empty.png",ccui.TextureResType.plistType)
                 else
                    self["btn" .. num].count:setString(self["btn" .. num].count1/10000)
                    self["btn" .. num].w:loadTexture(prepath .. "store_W.png",ccui.TextureResType.localType)
                 end 
              end 
              if flag == true then 
                 self["btn" .. num].thingcoin:loadTexture(thingurl, ccui.TextureResType.localType) --物品图标
              end
              self["btn" .. num].bg:loadTexture(thingbgurl, ccui.TextureResType.localType) --物品图标
              StoreUntil.selectCoin(self["btn" .. num].moneytype,{self["btn" .. num].xunzhan})
              self["btn" .. num].jiaqian:setVisible(false)
              self["btn" .. num].xunzhanlabel:setVisible(false)
              self["btn" .. num].xunzhan:setVisible(false)
              self["btn" .. num].goumai:setVisible(false)
              self["btn" .. num].qianjin:setVisible(false)
              self["btn" .. num].num:setVisible(false)
              self["btn" .. num].ci:setVisible(false) 
              if self["btn" .. num].data1.open == true then 
                 self["btn" .. num].jiaqian:setVisible(true)
                 self["btn" .. num].xunzhanlabel:setVisible(true)
                 self["btn" .. num].xunzhan:setVisible(true)
              else          
                 self["btn" .. num].goumai:setVisible(true)
                 self["btn" .. num].qianjin:setVisible(true)
                 self["btn" .. num].num:setVisible(true)
                 self["btn" .. num].ci:setVisible(true)
                 self["btn" .. num].xunzhanlabel:setVisible(true)
                 self["btn" .. num].xunzhanlabel:setPosition( self["btn" .. num].xunzhanlabel:getPositionX() + 10 , self["btn" .. num].xunzhanlabel:getPositionY() - 2 )
                 self["btn" .. num].xunzhan:setVisible(true)
                 self["btn" .. num].xunzhan:setScale(0.7)
                 self["btn" .. num].xunzhan:setPosition( self["btn" .. num].xunzhan:getPositionX() , self["btn" .. num].xunzhan:getPositionY() - 10)
                 self["btn" .. num].qianjin:setString(self["btn" .. num].data1.string)
                 self["btn" .. num].num:setString(self["btn" .. num].data1.string1)
                 self["btn" .. num].ci:setString(self["btn" .. num].data1.string2)
                 self["btn" .. num].goumai:setString(self["btn" .. num].data1.string3)
              end 
           end 
        else
            self["btn" .. num]:setVisible(false)
        end    
    end 
    

end 

function StoreAchieveSurr:addOutline(item, rgb, px)
    local txt = item:getVirtualRenderer()
    txt:enableOutline(rgb, px)
end

function StoreAchieveSurr:createView()
    local view = StoreAchieveSurr.new()
    return view
end 