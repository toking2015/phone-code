--单个聊天
--by weihao
--屏蔽功能还没完成
local prePath = "image/ui/ChatUI/"

MChatUntil = class("MChatUntil",function() 
    return getLayout(prePath .. "MChatUntil.ExportJson")
end)

function MChatUntil:ctor()
    ChatCommon.init(self,ChatCommon.me)
end 

function MChatUntil:createView(data)
    local view = MChatUntil.new()
    if data ~= nil then 
       view:refreshData(data)
    end 
    return view 
end 

function MChatUntil:refreshData(data)
    ChatCommon.setTextView(self,data,ChatCommon.me) 
end 