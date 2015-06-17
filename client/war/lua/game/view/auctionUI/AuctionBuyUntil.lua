local prepath = "image/ui/AuctionUI/"
AuctionBuyUntil = class("AuctionBuyUntil", function()
    return getLayout(prepath .. "AuctionBuyUntil.ExportJson")
end)

function AuctionBuyUntil:ctor()
    buttonDisable(self,true)
    self.quanbtn:setTouchEnabled(false)
    self.goubtn:setTouchEnabled(false)
    ChatCommon.initBtn(self.quanbtn)
    ChatCommon.initBtn(self.goubtn)
    self.quanbtn:addTouchEnded(function()
        if self.quanbtn:isVisible() == false then 
           return 
        end 
        ActionMgr.save( 'UI', 'AuctionBuyUntil click quanbtn' )
        if AuctionUI.selectView == 1 then 
           if self.data ~= nil then
              local money = CoinData.getCoinByCate(const.kCoinMoney) 
              local allcount = 10  --购买十个
              if money >= allcount * self.data.money then 
                  local list = {}           
                  for key ,value in pairs (self.data.idlist) do 
                      if value ~= nil then 
                          local count = self.data.countlist[key]
                          local allmoney = self.data.countlist[key] * self.data.money
                          if allcount - count >= 0 then 
                             table.insert(list,{cargo_id = value , coin = self.data.value.coin, percent = self.data.percent })
                          else 
                             local coin = {}
                             coin.objid = self.data.value.coin.objid
                             coin.cate = self.data.value.coin.cate
                             coin.val = allcount
                             table.insert(list,{cargo_id = value , coin = coin, percent = self.data.percent})
                             break
                          end 
                      end 
                  end  
                  Command.run('auction buy list',list)
             else
                  TipsMgr.showError('金币不足')
              end 
           end 
        end 
    end)
    self.goubtn:addTouchEnded(function()
        ActionMgr.save( 'UI', 'AuctionBuyUntil click goubtn' )
        if AuctionUI.selectView == 1 then
            if self.data ~= nil then
               local money = CoinData.getCoinByCate(const.kCoinMoney) 
               if money >=  self.data.money then 
                   local length = #self.data.idlist
                   if length >= 1 then 
                      local index = math.floor( math.random(1,length))
                      local value = self.data.idlist[index]
                      local percent = self.data.percent
                      local allmoney = self.data.money
                      if value ~= 0 then 
                         Command.run('auction buy',value,1,allmoney,percent)
                      else
                         Command.run('auction buy',value,1,self.data.coin,percent)
                      end 
                   end 
               else 
                   TipsMgr.showError('金币不足')
               end
            end  
        end 
    end)
end 

function AuctionBuyUntil:refreshData(data)
    self.data = data
    AuctionCommon.setCoin(data.leixin,data.coin, {self.coin},true)  --设置头像
    AuctionCommon.setKuan(data.coinbg,{self.kuan})  -- 设置边框
    AuctionCommon.setMoneyCoin(data.cointype,{self.jinbi})
    self.name:setString(data.name)
    self.type:setString("T" .. data.t)
    if data.guid ~= 0 then 
       self.num:setString(data.count)
    else 
       self.num:setString("999")
    end 
    if data.count < 0 then 
       self.quanbtn:setVisible(false)
    end 
    self.money:setString(data.money)
end 

function AuctionBuyUntil:createView()
   local view = AuctionBuyUntil.new()
   return view
end 
