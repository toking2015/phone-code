-- by weihao 
-- 物品until
local prePath = "image/ui/ChatUI/"
local preKuanPath = "image/ui/ChatUI/chat_kuan/"
ChatZhuanUntil= class("ChatZhuanUntil",function() 
    return getLayout(prePath .. "ChatDiaoUntil.ExportJson")
end)

function ChatZhuanUntil:ctor()

    ChatAddCommon.setChatTouch(self.bg)

end 

function ChatZhuanUntil:refreshData(data)
    if self.donghua ~= nil then 
        self.donghua:removeFromParent()
        self.donghua = nil 
    end 
    self.bg.data = data
    self.bg.leixin = ChatAddData.ZHUAN
    local thingurl = ItemData.getItemUrl(data.item_id)
    self.bg.coin:loadTexture(thingurl, ccui.TextureResType.localType) --物品图标
    self.bg.coin:setScale(0.7) 
    local quality = EquipmentData:getEquipmentQuality( data.main_attr_factor )
    local url = preKuanPath .. "diaowen_" .. (quality- const.kCoinEquipWhite + 1) .. ".png"
    self.bg.data.quality = (quality- const.kCoinEquipWhite + 1)
    self.bg:loadTexture(url, ccui.TextureResType.localType) --物品图标

end 

function ChatZhuanUntil:createView()
    local view = ChatZhuanUntil.new()
    return view
end 
