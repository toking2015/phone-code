local prePath = "image/ui/RankUI/"
local untilprePath = "image/ui/RankUI/rankuntil/"
local prePaiPath = "image/ui/RankUI/rankpaiming/"
RankUIUntil = class("RankUIUntil",function() 
    return getLayout(prePath .. "RankUIUntil.ExportJson")
end)

function RankUIUntil:ctor()
    local pianyi = TeamData.AVATAR_OFFSET
    local x = self.bg1.coin:getPositionX()+pianyi.x
    local y = pianyi.y+self.bg1.coin:getPositionY() - 5
    self.bg1.coin:setPosition(x,y)
    self.bg1.coin:setScale(0.6)
end 

function RankUIUntil:refreshData(data,index)
--   self.bg:loadTexture("image/ui/RankUI/rankui_zise.png", ccui.TextureResType.localType)
   if data ~= nil and index ~= nil then 
       self.name:setString(data.info.name)
       local url = ""
       if data ~= nil and data.info ~= nil and data.info.avatar ~= nil and data.info.avatar ~= 0 then 
          url = TeamData.getAvatarUrlById(data.info.avatar)
       else
          self.name:setString(gameData.getSimpleDataByKey("name"))
          url = TeamData.getAvatarUrlById(gameData.getSimpleDataByKey("avatar"))
       end 
       self.bg1.coin:loadTexture(url, ccui.TextureResType.localType)
       if data ~= nil and data.info ~= nil and data.info.first ~= nil then 
          self.num:setString(data.info.first)
       end 
       self.bnum:setVisible(false)
       self.pming:setVisible(false)
       self.pbg:setVisible(false)
       self.weishang:setVisible(false)
       self.shang:setVisible(false)
       self.xia:setVisible(false) 
       self.hen:setVisible(false)
       self.zrlabel:setVisible(false)
       local url = untilprePath .. "rankuntil_red.png"
       self.bg:loadTexture(url,ccui.TextureResType.localType)--人物头像
       if index <= 50 and index > 3 then 
          self.pbg:setVisible(true)
          self.pbg.pnum:setString(index)
       elseif index > 1 and index <= 3 then  
          self.pming:setVisible(true)
          self.pming:loadTexture(prePaiPath .. "rankuip_" .. index .. ".png",ccui.TextureResType.localType )      
       elseif index == 1 then 
          url = untilprePath .. "rankuntil_blue.png"
          self.pming:setVisible(true)
          self.bg:loadTexture(url,ccui.TextureResType.localType)--人物头像
          self.pming:loadTexture(prePaiPath .. "rankuip_" .. index .. ".png",ccui.TextureResType.localType )  
       else 
          self.weishang:setVisible(true)
       end 
       if RankData.time == const.kRankAttrCopy then 
           if data.info.index == 0 then 
              self.hen:setVisible(true)
           elseif data.info.index - index > 0 then 
              self.shang:setVisible(true)
              self.shang.bg.label:setString(data.info.index - index)
           elseif data.info.index - index  < 0 then 
              self.xia:setVisible(true)
              self.xia.bg.label:setString(index - data.info.index) 
           else
              self.hen:setVisible(true)
           end 
       elseif RankData.time == const.kRankAttrReal then 
            self.zrlabel:setVisible(true)
            self.zrlabel:setString(data.info.index)
       end 
       
       if data.data ~= nil and data.data.equip_level ~= nil then 
          self.bnum:setVisible(true)
          local name = "布甲"
          if data.data.equip_type == 1 then 
             name = "布甲"
          elseif data.data.equip_type == 2 then 
             name = "皮甲"
          elseif data.data.equip_type == 3 then 
             name = "锁甲"
          elseif data.data.equip_type == 4 then 
             name = "板甲"
          end 
          self.bnum:setString("T" .. data.data.equip_level .. " " .. name)
       end 
       
   end 
--   print(debug.dump(data))
end 

function RankUIUntil:createView(data,index)
   local view = RankUIUntil.new()
   if data ~= nil and index ~= nil then 
      view:refreshData(data,index)
   end 
   return view 
end 