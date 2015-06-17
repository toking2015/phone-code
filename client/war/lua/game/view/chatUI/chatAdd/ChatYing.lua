-- by weihao 
-- 英雄
local prePath = "image/ui/ChatUI/"
require("lua/game/view/chatUI/chatAdd/ChatYingUntil")

local num = 120
local x = 10
local first = 300
local utext = 40
local positionlist = {
    [4]={[4] = {x,first},[3] ={x,first - utext -num},[2] ={x,first - utext*2 -num},[1] ={x,first - utext*3 -num}},
    [3]={[4] ={x,first},[3] = {x,first - utext},[2] ={x,first - utext*2-num},[1] = {x,first - utext*3-num}},
    [2]={[4] ={x,first},[3] ={x,first - utext},[2] ={x,first - utext*2},[1] ={x,first - utext*3-num}},
    [1]={[4] ={x,first},[3] ={x,first - utext},[2] ={x,first - utext*2},[1] ={x,first - utext*3}}
}

local num1 = 120
local bgpositionlist = {
    [4] = {x, first- num1},
    [3] = {x, first - utext -num1},
    [2] = {x, first - utext * 2  -num1},
    [1] = {x, first - utext * 3  -num1}
}
ChatYing = class("ChatYing",function() 
    return getLayout(prePath .. "ChatYing.ExportJson")
end)

function ChatYing:ctor()
    for i = 1 , 4 do
        createScaleButton(self["btn" .. i],nil,nil,nil,nil,1)
        self["btn" .. i]:addTouchEnded(function()
            ActionMgr.save( 'UI', 'ChatYing click up btn' .. i )
            if i ~= self.type then 
               self.type = i 
               self:press(self["btn" .. i ],i)
               self.bg2.dataLen = #self.typelist 
               self.bg2.tableView:reloadData()  
               self.bg2:setSliderCell(0)
            end 
        end)
    end 
    self:resetView()
    local list = SoldierData.getTable()
--    print("英雄 .. " .. debug.dump(list))
    self.type = 4 
    self:press(self["btn" .. self.type] , self.type)

    self:initTableView()
end 

function ChatYing:resetView()
    for i = 1 , 4 do
        self["btn" .. i ]["ban"]:setColor(cc.c3b(115, 11, 13))  -- 黄色
        self["btn" .. i ]["xia"]:setVisible(true)
        self["btn" .. i ]["shang"]:setVisible(false)
        self["btn" .. i ]:loadTexture("chatadd_lusebtn.png",ccui.TextureResType.plistType)
    end 
end


function ChatYing:initTableView()
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
            local view = ChatYingUntil:createView()
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
    createTableView({},self.create,self.updateItemData,cc.p(self.bg2.sc:getPositionX(),self.bg2.sc:getPositionY()),self.bg2.sc:getSize(),cc.size(288,85),self.bg2,nil, 4 ,2)
    self.bg2.dataLen = #self.typelist -- 由于传空数据
    if #self.typelist == 0 then 
        self.bg2.dataLen = 2
    end 

    self.bg2.tableView:reloadData()  
end 

function ChatYing:press(view , i)
    self:resetView()
    view:loadTexture("chatadd_lvsebtn.png",ccui.TextureResType.plistType)
    view.xia:setVisible(false)
    view.shang:setVisible(true)
    self:moveBtn(i)
    local list = SoldierData.getTable()
    self.typelist = {}
    local starlist = {}
    for key ,value in pairs(list) do
        if value ~= nil then 
            local soldier = findSoldier(value.soldier_id)
            if soldier.equip_type == self.type then  
               for k = 1 , 6 do 
                 if starlist[k] == nil then 
                    starlist[k] = {}
                 end 
                 if k == value.star then 
                    table.insert(starlist[k],value)
                 end 
               end 
--               table.insert(self.typelist,value) 
            end 
        end 
    end 
     
    local function select_sort(t)
        for i=1, #t - 1 do
            local min = i
            for j=i+1, #t do
                if t[j] ~= nil then 
                    if t[j].level < t[min].level  then
                        min = j
                    end
                end 
            end
            if min ~= i then
                t[min], t[i] = t[i], t[min]
            end
        end
    end
    
    
    for key , value in pairs(starlist) do 
        if value ~= nil then 
           select_sort(value)
        end 
    end 
    -- 排序英雄
    for key , value in pairs(starlist) do 
        if value ~= nil then 
           for key1 , value1 in pairs(value) do 
               if value1 ~= nil then 
                  table.insert(self.typelist,1,value1) 
               end 
           end
        end 
    end 

end 

-- 移动按钮跟背景
function ChatYing:moveBtn(type)
    local plist = {}
    local bgp = {}
    plist = positionlist[type]
    bgp = bgpositionlist[type]
    for key ,value in pairs(plist) do
        self["btn" .. key]:setPosition(cc.p(value[1],value[2]))
    end 
    self.bg2:setPosition(cc.p(bgp[1],bgp[2]))
end 

function ChatYing:createView()
   local view = ChatYing.new()
   return view
end 