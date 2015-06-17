-- by weihao 
-- 物品until
local prePath = "image/ui/ChatUI/"
local preKuanPath = "image/ui/ChatUI/chat_kuan/"
ChatWuUntil= class("ChatDiaoUntil",function() 
    return getLayout(prePath .. "ChatDiaoUntil.ExportJson")
end)

function ChatWuUntil:ctor()
--   self.bg
--   self.bg.coin
    ChatAddCommon.setChatTouch(self.bg)
end 

function ChatWuUntil:refreshData(data)
    local item = findItem(data.item_id)
--    data.list = item 
    self.bg.data = data
    self.bg.leixin = ChatAddData.WU
    local thingurl = ItemData.getItemUrl(data.item_id)
    self.bg.coin:setScale(0.5)
    self.bg.coin:loadTexture(thingurl, ccui.TextureResType.localType) --物品图标
    local quality = item.quality
    local url = preKuanPath .. "diaowen_" .. quality .. ".png"
    self.bg:loadTexture(url, ccui.TextureResType.localType) --物品图标

end 

function ChatWuUntil:createView()
    local view = ChatWuUntil.new()
    return view
end 
