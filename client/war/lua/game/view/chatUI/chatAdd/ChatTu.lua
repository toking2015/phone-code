-- by weihao 
-- 图腾
local prePath = "image/ui/ChatUI/"
require("lua/game/view/chatUI/chatAdd/ChatTuUntil")
ChatTu= class("ChatTu",function() 
    return getLayout(prePath .. "ChatTu.ExportJson")
end)

function ChatTu:ctor()
--    local list = TotemData.getData()
--    print("图腾 .. " .. debug.dump(list))
    self.typelist = TotemData.getData()
    
    local function select_sort(t)
        for i=1, #t - 1 do
            local min = i
            for j=i+1, #t do
                if t[j] ~= nil then 
                    if t[j].level > t[min].level  then
                        min = j
                    end
                end 
            end
            if min ~= i then
                t[min], t[i] = t[i], t[min]
            end
        end
    end
    --排序图腾
    select_sort(self.typelist)
    self:initTableView()
end 

function ChatTu:initTableView()
    function self.updateItemData(data ,constant, dataIndex, itemIndex, widthCount)
        constant.index = dataIndex
        dataIndex = widthCount * ( dataIndex - 1 ) + itemIndex
        local item = constant.itemList[itemIndex]
        local userItem = self.typelist[dataIndex]
        -- item的数据

        if item  then
            if userItem ~= nil then 
                item:refreshData(userItem)
                item:setVisible(true)
            else  
                item:setVisible(true)
            end 
        end
    end

    function self.create()
        local content = display.newLayer()
        content:setAnchorPoint(cc.p(0,0))
        content:setPosition(cc.p(0, 0))
        content:setTag(1)
        content.itemList = {}
        local view = ChatTuUntil:createView()
        view:setTouchEnabled(false)
        content:addChild(view)
        view:setPosition(0,0)
        content.itemList[1] = view

        if self.firstItem == nil then
           self.firstItem = view
        end
        return content
    end
    self.bg2.sc:setVisible(false)
    createTableView({},self.create,self.updateItemData,cc.p(self.bg2.sc:getPositionX()-20,self.bg2.sc:getPositionY()),self.bg2.sc:getSize(),cc.size(360,100),self.bg2,nil, 1 ,2)
    self.bg2.dataLen = #self.typelist -- 由于传空数据
    if #self.typelist == 0 then 
        self.bg2.dataLen = 2
    end 
    self.bg2.tableView:reloadData()  
end 


function ChatTu:createView()
    local view = ChatTu.new()
    return view 
end 