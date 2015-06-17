local prePath = "image/ui/RankUI/"
local typeprePath = "image/ui/RankUI/ranktype/"
RankTypeUntil = class("RankTypeUntil",function() 
    return getLayout(prePath .. "RankTypeUntil.ExportJson")
end)

function RankTypeUntil:ctor()

end 

function RankTypeUntil:refreshData(data)
    if data ~= 1 then --不为英雄的时候 
       self.bg.tou:setPositionX(60)
    end 
    self.bg.tou:loadTexture( typeprePath .. "ranktypecoin_" .. data .. ".png", ccui.TextureResType.localType )
    self.bg.name:loadTexture( typeprePath .. "ranktypename_" .. data .. ".png", ccui.TextureResType.localType )
    self.bg.xz:setVisible(false)
end 

function RankTypeUntil:createView(data)
    local view = RankTypeUntil.new()
    if data ~= nil then 
        view:refreshData(data)
    end 
    return view 
end 