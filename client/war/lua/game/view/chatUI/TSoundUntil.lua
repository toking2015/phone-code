--单个聊天
--by weihao
--屏蔽功能还没完成
local prePath = "image/ui/ChatUI/"

TSoundUntil = class("TSoundUntil",function() 
    return getLayout(prePath .. "TSoundUntil.ExportJson")
end)

function TSoundUntil:ctor()
    ChatCommon.init(self,ChatCommon.other)
end 


function TSoundUntil:createView(data)
    local view = TSoundUntil.new()
    if data ~= nil then 
        view:refreshData(data)
    end 
    return view 
end 

function TSoundUntil:refreshData(data)
    ChatCommon.setSoundView(self,data,ChatCommon.other) -- 设置声音长度
end 