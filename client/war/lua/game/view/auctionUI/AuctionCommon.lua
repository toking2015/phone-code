local prepath = "image/ui/AuctionUI/bg/"
local prepath1 = "image/ui/AuctionUI/coin/"
AuctionCommon = {}
function AuctionCommon.setKuan(type,data)
   for key , value in pairs(data) do
       if value ~= nil then 
            value:loadTexture(prepath .. "auctionbg_" .. type ..  ".png",ccui.TextureResType.localType)
       end 
   end 
end 

function AuctionCommon.setMoneyCoin(leixin,data)
   for key , value in pairs(data) do
       if value ~= nil then 
           if leixin == const.kCoinMoney then 
              value:loadTexture("auction_coin.png" , ccui.TextureResType.plistType)
           elseif leixin == const.kCoinGold then  
              value:loadTexture(prepath1 .. "share_zhuanshi.png" , ccui.TextureResType.localType)
           elseif leixin == const.kCoinMedal then 
              value:loadTexture(prepath1 .. "share_xunzhan.png" , ccui.TextureResType.localType)
           end 
       end 
   end 
end 

function AuctionCommon.setCoin(leixin,type, data , isScale)
   if isScale == nil then 
      isScale = false 
   end 
   for key , value in pairs(data) do
        if value ~= nil then 
            local flag = true 
            local thingurl = ItemData.getItemUrl(type) 
            if leixin == const.kCoinActiveScore then --手工活力
                thingurl = CoinData.getCoinUrl(const.kCoinActiveScore)
            elseif leixin == const.kCoinItem then  --物品
                thingurl = ItemData.getItemUrl(type)
                flag = true
            elseif leixin == const.kCoinTotem then  --图腾
                thingurl = TotemData.getAvatarUrlById(type)
                flag = true
            elseif leixin == const.kCoinGlyph then   --雕文  
                value:setVisible(false)
                value.donghua = TotemData.getGlyphObject(type,"AuctionUI",value,value:getPositionX(),value:getPositionY())
                flag = false
            end 
            if flag == true then 
                value:loadTexture(thingurl, ccui.TextureResType.localType) --物品图标
                if isScale == true then 
                   value:setScale(0.5)
                end 
            end
        end 
   end 
end 