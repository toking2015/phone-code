--单个聊天
--by weihao
--屏蔽功能还没完成
local prePath = "image/ui/ChatUI/"

MSoundUntil = class("MSoundUntil",function() 
    return getLayout(prePath .. "MSoundUntil.ExportJson")
end)

function MSoundUntil:ctor()
    ChatCommon.init(self,ChatCommon.me)
end 

function MSoundUntil:createView(data)
    local view = MSoundUntil.new()
    if data ~= nil then 
        view:refreshData(data)
    end 
    return view 
end 

function MSoundUntil:refreshData(data)
    ChatCommon.setSoundView(self,data,ChatCommon.me) -- 设置声音长度
end 