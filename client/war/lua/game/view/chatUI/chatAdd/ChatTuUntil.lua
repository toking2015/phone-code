-- by weihao 
-- 图腾until
local prePath = "image/ui/ChatUI/"

ChatTuUntil = class("ChatTuUntil",function() 
    return getLayout(prePath .. "ChatTuUntil.ExportJson")
end)

function ChatTuUntil:ctor()
--   self.kuan
--   self.kuan.coin
    ChatAddCommon.setChatTouch(self.bg)
     
end 

function ChatTuUntil:refreshData(data)
    self.bg.leixin = ChatAddData.TU
    self.bg.data = data
    self.bg.data1 = TotemData.getTotemGlyphList(data.guid) --雕文合成
    local item = findTotem(data.id)
    self:selectStar(tonumber(data.level))
    self.bg.name:setString(item.name)
    self:selectType(item.type,data)
    local thingurl = TotemData.getAvatarUrlById(item.id)
    self.bg.kuan.coin:loadTexture(thingurl, ccui.TextureResType.localType) --物品图标
    self.bg.kuan.coin:setScale(0.9)
    if item.quality == 0 then 
       item.quality = 1
    end 
    local url = "qu_totem_" .. item.quality - 1 .. ".png"
    self.bg.kuan:loadTexture(url, ccui.TextureResType.plistType) 
end

function ChatTuUntil:selectStar(num)
   for i = 1 ,num do
       self["bg"]["star" .. i]:loadTexture("chatadd_star1.png",ccui.TextureResType.plistType)
   end 
   for i = num + 1 , 5 do 
       self["bg"]["star" .. i]:loadTexture("chatadd_star2.png",ccui.TextureResType.plistType)
   end 
end  

--根据图腾类型选择字体颜色
function ChatTuUntil:selectType(type,data)
   -- 设置类型颜色
   if type == 1 then 
      self.bg.type:setString("土系")
      self.bg.type:setColor(cc.c3b(0xFF, 0xDA, 0x00))
   elseif type == 2 then 
      self.bg.type:setString("火系")
      self.bg.type:setColor(cc.c3b(255, 0, 4))
   elseif type == 3 then 
      self.bg.type:setString("水系")
      self.bg.type:setColor(cc.c3b(0,255,240))
   elseif type == 4 then 
      self.bg.type:setString("风系")
      self.bg.type:setColor(cc.c3b(255, 255, 255))
   end 
   -- 设置名字颜色
   if data.level == 1 then 
        self.bg.name:setColor(cc.c3b(255, 255, 255)) --白色
   elseif data.level == 2 then 
        self.bg.name:setColor(cc.c3b(0,56,0)) --绿色
   elseif data.level == 3 then 
        self.bg.name:setColor(cc.c3b(0x00, 0x5a, 0xFF))--蓝色
   elseif data.level == 4 then 
        self.bg.name:setColor(cc.c3b(0xa2, 0x00, 0xFF))--紫色
   elseif data.level == 5 then
        self.bg.name:setColor(cc.c3b(255,48,0)) -- 橙色
   end 
end 

function ChatTuUntil:createView()
    local view = ChatTuUntil.new()
    return view
end 
