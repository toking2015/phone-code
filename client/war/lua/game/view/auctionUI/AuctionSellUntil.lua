local prepath = "image/ui/AuctionUI/"
AuctionSellUntil = class("AuctionSellUntil", function()
    return getLayout(prepath .. "AuctionSellUntil.ExportJson")
end)

function AuctionSellUntil:ctor()
    buttonDisable(self,true)
    self.xiajiabtn:setTouchEnabled(false)
    self.xiugaibtn:setTouchEnabled(false)
    self.shangjiabtn:setTouchEnabled(false)
    ChatCommon.initBtn(self.xiajiabtn)
    ChatCommon.initBtn(self.xiugaibtn)
    ChatCommon.initBtn(self.shangjiabtn)
end 

function AuctionSellUntil:refreshData(data)
--   print(debug.dump(data))
   if data.shangjia == 2 then -- 未上架
        self.wsjlabel:setVisible(true) 
        self.sjlabel:setVisible(false)
        self.xiajiabtn:setVisible(false)
        self.xiugaibtn:setVisible(false)
        self.shangjiabtn:setVisible(true)
        self.money:setVisible(false)
        self.time:setVisible(false)
        self.jinbi:setVisible(false)
   elseif data.shangjia == 1 then   -- 上架
        self.sjlabel:setVisible(true)
        self.wsjlabel:setVisible(false)
        self.xiajiabtn:setVisible(true)
        self.xiugaibtn:setVisible(true)
        self.shangjiabtn:setVisible(false)
        self.money:setVisible(true)
        self.time:setVisible(true)
        self.jinbi:setVisible(true)
   end 
   AuctionCommon.setMoneyCoin(data.cointype,{self.jinbi})
   AuctionCommon.setCoin(data.leixin,data.coin, {self.coin},true)  --设置头像
   AuctionCommon.setKuan(data.coinbg,{self.kuan})  -- 设置边框
   self.name:setString(data.name)
   self.type:setString("T" .. data.t)
   self.num:setString(data.count)
   self.money:setString(data.money)
   local hour = 0 
   if data.start_time ~= nil and data.start_time < gameData.getServerTime() then 
      hour = DateTools.secondToString((24 * 60 * 60 - (gameData.getServerTime() - data.start_time)), 1)
      hour = string.gsub(hour, "分", "分钟", 1)
      hour = string.gsub(hour, "时", "小时", 1)
      if (24 * 60 * 60 - (gameData.getServerTime() - data.start_time)) < 60 then 
         hour = "1分钟"
      end 
      self.time:setString(hour)
   end
   
    
   
   self.shangjiabtn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'AuctionSellUntil click shangjiabtn' )        
        if data.shangjia == 2 and AuctionUI.selectView == 2  then 
--           print("上架")
           AuctionData.setAuctionUp(data)   --上架
        end 
   end)
   self.xiugaibtn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'AuctionSellUntil click xiugaibtn' )  
        if data.shangjia == 1 and AuctionUI.selectView == 2 then 
--            print("修改")
            AuctionData.setModifylist(data)
        end    
   end)
   self.xiajiabtn:addTouchEnded(function() 
        ActionMgr.save( 'UI', 'AuctionSellUntil click xiajiabtn' )  
        if data.shangjia == 1 and AuctionUI.selectView == 2 then 
--            print("下架")
            Command.run('xiajia' ,data.cargo_id)
        end    
   end)
   
end 

function AuctionSellUntil:createView()
    local view = AuctionSellUntil.new()
    return view
end 