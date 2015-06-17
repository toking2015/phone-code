-- by weihao 
-- 物品until
local prePath = "image/ui/ChatUI/"
local preKuanPath = "image/ui/ChatUI/chat_kuan/"
ChatDiaoUntil= class("ChatDiaoUntil",function() 
    return getLayout(prePath .. "ChatDiaoUntil.ExportJson")
end)

function ChatDiaoUntil:ctor()

    ChatAddCommon.setChatTouch(self.bg)

end 

function ChatDiaoUntil:refreshData(data)
    if self.donghua ~= nil then 
       self.donghua:removeFromParent()
       self.donghua = nil 
    end 
    self.bg.data = data
    self.bg.leixin = ChatAddData.DIAO
    local list = findTempleGlyph(data.id)
    self.bg.coin:setVisible(false)
    self.donghua = TotemData.getGlyphObject(data.id,"ChatUI",self.bg,self.bg.coin:getPositionX(),self.bg.coin:getPositionY(),data)
    
    local url = preKuanPath .. "diaowen_" .. list.quality .. ".png"
    self.bg:loadTexture(url, ccui.TextureResType.localType) --物品图标
    
end 

function ChatDiaoUntil:createView()
   local view = ChatDiaoUntil.new()
   return view
end 
