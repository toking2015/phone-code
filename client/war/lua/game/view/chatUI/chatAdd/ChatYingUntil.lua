-- by weihao 
-- 英雄until
local prePath = "image/ui/ChatUI/"

ChatYingUntil = class("MainChatUI",function() 
    return getLayout(prePath .. "ChatYingUntil.ExportJson")
end)

function ChatYingUntil:ctor()
    ChatAddCommon.setChatTouch(self.bg)
    
    local pianyi = TeamData.AVATAR_OFFSET
    self.bg.coin:setPosition(self.bg.coin:getPositionX() + pianyi.x , pianyi.y + self.bg.coin:getPositionY())
    for i = 1 ,5 do
        self["star" .. i]["position"] = {x = self["star" .. i ]:getPositionX(), y = self["star" .. i ]:getPositionY()}
    end 
end 

function ChatYingUntil:refreshData(data)
    self.text:setString("")
    self.bg.leixin = ChatAddData.YING
    self:selectStar(data.star)
    self.text:setString(data.level)
    local data1 = findSoldier(data.soldier_id)
    self.bg.data = data
    local url = SoldierData.getAvatarUrl(data1)
    self.bg.coin:loadTexture(url,ccui.TextureResType.localType)
    local bgurl = SoldierData.getQualityFrameName(data.quality)
    self.bg:loadTexture(bgurl,ccui.TextureResType.plistType)
    
end 

function ChatYingUntil:selectStar(num)
   for i = 1 ,5 do
       self["star" .. i ]:setVisible(false)
       self["star" .. i ]:setPosition(self["star" .. i]["position"])
       self["star" .. i ]:setLocalZOrder(5)
     
   end 
   if num == 1 then 
      self.star3:setVisible(true)
   elseif num == 2 then 
      self.star2:setVisible(true)
      self["star2"]:setPosition(self["star2"]["position"].x+5,self["star2"]["position"].y )
      self["star4"]:setPosition(self["star4"]["position"].x-5,self["star4"]["position"].y )
      self.star4:setVisible(true)
   elseif num == 3 then 
      self.star2:setVisible(true)
      self.star3:setVisible(true)
      self.star4:setVisible(true)
   elseif num == 4 then 
      self.star2:setVisible(true)
      self.star2:setVisible(true)
      self.star3:setVisible(true)
      self.star4:setVisible(true)
   else
      for i = 1 ,5 do
          self["star" .. i ]:setVisible(true)
      end 
   end 
end 

function ChatYingUntil:createView()
    local view = ChatYingUntil.new()
    return view 
end 