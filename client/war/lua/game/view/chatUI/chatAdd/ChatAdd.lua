-- by weihao 
-- 聊天添加框
require("lua/game/view/chatUI/chatAdd/ChatDiao.lua")
require("lua/game/view/chatUI/chatAdd/ChatTu.lua")
require("lua/game/view/chatUI/chatAdd/ChatWu.lua")
require("lua/game/view/chatUI/chatAdd/ChatYing.lua")
require("lua/game/view/chatUI/chatAdd/ChatZhuan.lua")
require("lua/game/view/chatUI/chatAdd/ChatAddCommon.lua")
local prePath = "image/ui/ChatUI/"

ChatAdd = class("ChatAdd",function() 
    return getLayout(prePath .. "ChatAdd.ExportJson")
end)

function ChatAdd:ctor()
   for i = 1 , 5 do
      if  i == 1 then 
         ProgramMgr.setGray(self["btn" .. i])
      else 
         createScaleButton(self["btn" .. i])
         self["btn" .. i]:addTouchEnded(function() 
             ActionMgr.save( 'UI', 'ChatAdd click btn' .. i ) 
             self:press(self["btn" .. i],i)
         end)
      end 
      
   end  
   self:resetView()
end 

function ChatAdd:resetView()
    for i = 1 , 5 do
        self["btn" .. i]["shang"]:setVisible(false)
        self["btn" .. i]:loadTexture("chatadd_lvkuan.png",ccui.TextureResType.plistType)
    end 
    if self.chat_view ~= nil then 
       self.chat_view:removeFromParent()
       self.chat_view = nil 
    end 
end 

function ChatAdd:press(view,i)
   if self.chat_view == nil or  self.chat_view.tag ~= i then 
       self:resetView()
       view:loadTexture("chatadd_huanse.png",ccui.TextureResType.plistType)
       view.shang:setVisible(true)
       self.chat_view = nil 
       if i == 1 then 
          self.chat_view = ChatDiao:createView()
       elseif i == 2 then 
          self.chat_view = ChatZhuan:createView()  
       elseif i == 3 then 
          self.chat_view = ChatTu:createView()
       elseif i == 4 then 
          self.chat_view = ChatWu:createView()
       else 
          self.chat_view = ChatYing:createView()
       end 
       self.chat_view.tag = i 
       self.vector:addChild(self.chat_view)
--       LogMgr.error("替换")
   end 
end 

function ChatAdd:createView()
   local view = ChatAdd.new()
   return view
end 