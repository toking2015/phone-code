require("lua/game/view/chatUI/ChatExpression/ExpressionUntil")
local prePath = "image/ui/ChatUI/"
ExpressionUI = class("ExpressionUI",function() 
    return getLayout(prePath .. "ExpressionUI.ExportJson")
end)

function ExpressionUI:ctor()

    self:initTableView()
end 

function ExpressionUI:initTableView()
    self.typelist = ExpressionData.getShowList()
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

        for i=1,5 do
            local view = ExpressionUntil:createView()
            view:setTouchEnabled(false)
            content:addChild(view)
            view:setPosition((i - 1) * 40,0)
            content.itemList[i] = view

            if self.firstItem == nil then
                self.firstItem = view
            end
        end
        return content
    end
    self.sc:setVisible(false)
    createTableView({},self.create,self.updateItemData,cc.p(self.sc:getPositionX() + 3,self.sc:getPositionY()),self.sc:getSize(),cc.size(40,40),self.bg,nil, 5 ,2)
    self.bg.dataLen = #self.typelist -- 由于传空数据
    self.bg.tableView:reloadData()  
end 

function ExpressionUI:createView()
   local view = ExpressionUI.new()
   return view 
end 