require("lua/game/view/auctionUI/AuctionRecordUntil")
local prepath = "image/ui/AuctionUI/"
local url = prepath .. "AuctionRecord.ExportJson"

AuctionRecord = class("AuctionRecord",function() 
    return getLayout(url)
end)

function AuctionRecord.getWindow()
    return PopMgr.getWindow("AuctionUI")
end

function AuctionRecord:ctor()
   self:initView()
   EventMgr.addListener(EventType.AuctionRecordView,self.initView,self) -- 出售的view
end 

function AuctionRecord:onClose()
    EventMgr.removeListener(EventType.AuctionRecordView,self.initView)
end 

function AuctionRecord:initView()

    local viewlist = AuctionData.getSaleList()
    
    if self.tableview ~= nil then 
        self.tableview:removeAllChildren(true)
        self.tableview:removeFromParent(true)
        self.tableview = nil 
    end
    
    function self.updateItemData(data ,constant, index, i, widthCount)
        if #data - index + 1> 0 then 
            constant:refreshData( data[#data - index + 1] )
        end 
    end

    function self.create()
        return AuctionRecordUntil:createView(nil)
    end
    self.tableview = createTableView(viewlist,self.create,self.updateItemData,cc.p(self.scrollview:getPositionX(),self.scrollview:getPositionY()),self.scrollview:getSize(),cc.size(600,79),self,nil)  
end 

function AuctionRecord:createView()
    local view = AuctionRecord.new()
    return view 
end 
