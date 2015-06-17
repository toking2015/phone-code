
local prePath = "image/ui/AuctionUI/"

AuctionRecordUntil = class("AuctionRecordUntil", function()
    return getLayout(prePath .. "AuctionRecordUntil.ExportJson")
end)

function AuctionRecordUntil:ctor()
    buttonDisable(self,true)
    buttonDisable(self.vector,true)
end

function AuctionRecordUntil:createView(data)
    local view = AuctionRecordUntil.new()
    return view 
end 

function AuctionRecordUntil:refreshData(data)
    self.vector:removeAllChildren(true)
    local str = "[font=ZH_P1]   [font=ZH_P1] 2014-11-19 20:00:00[br]"
    str = str .. "[font=ZH_P1]   [font=ZH_P2]玩家[font=ZH_P3]神棍德[font=ZH_P2]购买了 "
    str = str .. "[font=ZH_P4]银临胸甲[font=ZH_P1]X99 "
    str = str .. "[font=ZH_P2]收益[font=ZH_P1]99999999 "
    str = str .. "[font=ZH_P2]其中[font=ZH_P1]99999 "
    str = str .. "[font=ZH_P2]为系统税收"
    if data ~= nil then 
        str = "[font=ZH_P1]   [font=ZH_P1] " .. data.time .. "[br]"
        str = str .. "[font=ZH_P1]   [font=ZH_P2]玩家[font=ZH_P3]" .. data.name .. "[font=ZH_P2]购买了 "
        str = str .. "[font=ZH_P4]" .. data.thingname .. "[font=ZH_P1]X" .. data.count .. " "
        str = str .. "[font=ZH_P2]收益[font=ZH_P1]" .. data.money .. " "
        str = str .. "[font=ZH_P2]其中[font=ZH_P1]" .. data.suishou .. " "
        str = str .. "[font=ZH_P2]为系统税收"     
    end
    RichText:addMultiLine(str, prePath, self.vector)

    return self 
end 