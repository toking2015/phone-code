-- by weihao 
-- 物品
require("lua/game/view/chatUI/chatAdd/ChatWuUntil")
local prePath = "image/ui/ChatUI/"

ChatWu= class("ChatWu",function() 
    return getLayout(prePath .. "ChatWu.ExportJson")
end)

function ChatWu:ctor() 

    self.typelist = ItemData.getTable( const.kBagFuncCommon )
--    print("self.typelist .. " .. debug.dump(self.typelist))
    self:initTableView()
end 


function ChatWu:initTableView()
    function self.updateItemData(data ,constant, dataIndex, itemIndex, widthCount)
        constant.index = dataIndex
        dataIndex = widthCount * ( dataIndex - 1 ) + itemIndex
        local item = constant.itemList[itemIndex]
        local userItem = self.typelist[dataIndex]
        -- item的数据

        if item  then
            if userItem ~= nil then 
                item:refreshData(userItem)
                item.id = userItem.id
                item:setVisible(true)
            else  
                item:setVisible(false)
            end 
        end
    end

    function self.create()
        local content = display.newLayer()
        content:setAnchorPoint(cc.p(0,0))
        content:setPosition(cc.p(0, 0))
        content:setTag(1)
        content.itemList = {}

        for i=1,4 do
            local view = ChatWuUntil:createView()
            view:setTouchEnabled(false)
            content:addChild(view)
            view:setPosition((i - 1) * 72,0)
            content.itemList[i] = view

            if self.firstItem == nil then
                self.firstItem = view
            end
        end
        return content
    end
    self.bg2.sc:setVisible(false)
    createTableView({},self.create,self.updateItemData,cc.p(self.bg2.sc:getPositionX()+5,self.bg2.sc:getPositionY()-5),self.bg2.sc:getSize(),cc.size(288,72),self.bg2,nil, 4 ,4)
    self.bg2.dataLen = #self.typelist -- 由于传空数据
    if #self.typelist == 0 then 
        self.bg2.dataLen = 2 
    end 
    self.bg2.tableView:reloadData()  
end 

function ChatWu:createView()
    local view = ChatWu.new()
    return view
end 