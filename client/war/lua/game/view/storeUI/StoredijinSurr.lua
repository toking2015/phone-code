-- write by weihao 

local prepath = "image/ui/StoreUI/"
local url = prepath .. "StoredijinSurr.ExportJson"
require("lua/game/view/storeUI/StoredijinUntil")

StoredijinSurr = class("StoredijinSurr", function()
    return getLayout(url)
end)

function StoredijinSurr:ctor()
   local data = StoreData.getDJData()
   self:refreshData(data)
   local bottom = self.bottombg
   createScaleButton(bottom.refreshbtn)
   bottom.refreshbtn:addTouchEnded(function()
       local str = "[image＝refreshthing.png][br][image=coin.png][font=ZH_3]  金币[font=ZH_5] 不足,是否前往"
       showMsgBox(str)
   end )
   bottom.neednumlabel:setString("100")
   bottom.needtimelabel:setString("10:10:10秒后关闭,请抓紧购买")
--   EventMgr.addListener(EventType.UpdateStoreDataDJ, self.refreshData,self)
end 

function StoredijinSurr:refreshData(data)
    local list = {}
    local viewlist = {}
    if nil ~= data and #data ~= 0 then 
        for _, value in pairs(data) do
            local suntil = StoredijinUntil:createView(value)
            table.insert(viewlist,suntil)
        end 
        initVector(self.vector, viewlist, 3, 6, 6, 6, 6)
    end 
end 

function StoredijinSurr:createView()
    local view = StoredijinSurr.new()
    return view 
end 

function StoredijinSurr:onClose()
--    EventMgr.removeListener(EventType.UpdateStoreDataDJ, self.refreshData)
end