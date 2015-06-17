-- write by weihao 

local prepath = "image/ui/StoreUI/"
local url = prepath .. "StoreyouxiSurr.ExportJson"
require("lua/game/view/storeUI/StoreyouxiUntil")
StoreyouxiSurr = class("StoreyouxiSurr", function()
    return getLayout(url)
end)

function StoreyouxiSurr:ctor()
    local data = StoreData.getYXData()
    self:refreshData(data)
    EventMgr.addListener(EventType.UpdateStoreDataYX, self.refreshData,self)
    analyseExportJson("Store", url) --记录需要释放的plist
end 

function StoreyouxiSurr:refreshData(data)
    local list = {}
    local viewlist = {}
    if nil ~= data and #data ~= 0 then 
        for _, value in pairs(data) do
            local suntil = StoreyouxiUntil:createView(value)
            table.insert(viewlist,suntil)
        end 
        initScrollviewWith(self.scrollview, viewlist, 3, 20, 5, 6, 6)
    end 
    
--    bindScrollViewAndSlider(self.scrollview, self.slider)
--    self.slider:setPercent(0)
end 

function StoreyouxiSurr:createView()
    local view = StoreyouxiSurr.new()
    return view 
end 

function StoreyouxiSurr:onClose()
    EventMgr.removeListener(EventType.UpdateStoreDataYX, self.refreshData)
end