--单个聊天
--by weihao
--屏蔽功能还没完成
local prePath = "image/ui/ChatUI/"

TChatUntil = class("TChatUntil",function() 
    return getLayout(prePath .. "TChatUntil.ExportJson")
end)

function TChatUntil:ctor()
    ChatCommon.init(self,ChatCommon.other)
end 

function TChatUntil:createView(data)
    local view = TChatUntil.new()
    if data ~= nil then 
        view:refreshData(data)
    end 
    return view 
end 

function TChatUntil:refreshData(data)
    ChatCommon.setTextView(self,data,ChatCommon.other) 
end 