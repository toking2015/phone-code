require("lua/game/view/auctionUI/AuctionSellUntil")
local prepath = "image/ui/AuctionUI/"
local url = prepath .. "AuctionSell.ExportJson"

AuctionSell = class("AuctionSell",function() 
    return getLayout(url)
end)

function AuctionSell.getWindow()
    return PopMgr.getWindow("AuctionUI")
end


function AuctionSell:ctor()
   self:initView()
   EventMgr.addListener(EventType.AuctionSellView,self.initView,self) -- 出售的view
end 

function AuctionSell:onClose()
    EventMgr.removeListener(EventType.AuctionSellView,self.initView)
end 

function AuctionSell:initView()

    -- 这里设置上架以及未上架的数据
    local viewlist = {}
    viewlist = AuctionData.getWshangjiaList()  
    for key, value in pairs( AuctionData.getShangjialist()) do
        table.insert(viewlist,value)
    end
    
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
        return AuctionSellUntil:createView(nil)
    end
    self.tableview = createTableView(viewlist,self.create,self.updateItemData,cc.p(self.scrollview:getPositionX(),self.scrollview:getPositionY()),self.scrollview:getSize(),cc.size(650,63),self,nil)  
   
end 

function AuctionSell:createView()
   local view = AuctionSell.new()
   return view 
end 
