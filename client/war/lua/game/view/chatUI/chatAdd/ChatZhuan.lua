local prePath = "image/ui/ChatUI/"
require("lua/game/view/chatUI/chatAdd/ChatZhuanUntil")
ChatZhuan= class("ChatZhuan",function() 
    return getLayout(prePath .. "ChatZhuan.ExportJson")
end)
local num = 90
local x = 10
local first = 300
local utext = 40
local positionlist = {
    [4]={[4] = {x,first},[3] ={x,first - utext -num},[2] ={x,first - utext*2 -num},[1] ={x,first - utext*3 -num}},
    [3]={[4] ={x,first},[3] = {x,first - utext},[2] ={x,first - utext*2-num},[1] = {x,first - utext*3-num}},
    [2]={[4] ={x,first},[3] ={x,first - utext},[2] ={x,first - utext*2},[1] ={x,first - utext*3-num}},
    [1]={[4] ={x,first},[3] ={x,first - utext},[2] ={x,first - utext*2},[1] ={x,first - utext*3}}
}

local num1 = 90
local bgpositionlist = {
    [4] = {x, first- num1},
    [3] = {x, first - utext -num1},
    [2] = {x, first - utext * 2  -num1},
    [1] = {x, first - utext * 3  -num1}
}

function ChatZhuan:ctor() 
    for i = 1 , 4 do
        createScaleButton(self["btn" .. i],nil,nil,nil,nil,1)
        self["btn" .. i]:addTouchEnded(function()
            ActionMgr.save( 'UI', 'ChatZhuan click up btn' .. i )      
            if i ~= self.type then 
                self:press(self["btn" .. i ],i)
            else 
                local target_id = gameData.id 
                Command.run( 'chatequip' ,target_id ,self.equip_type , self.level) 
            end 
        end)
        
    end 
    createScaleButton(self.fasong)
    self.fasong:addTouchEnded(function()
        ActionMgr.save( 'UI', 'ChatZhuan click up fasong' )
        local data1 = {}
        data1.target_id = gameData.id 
        data1.equip_type = self.equip_type
        data1.level = self.level
        data1.leixin = ChatAddData.TAO
        local jsonstr = table2json( data1 )
        Command.run( 'chatother',jsonstr)
    end)
    self:resetView()
    self.typelist = {} 
    self.type = 4 -- 默认第一个按钮的东西
    self.typelist ,self.equip_type , self.level = EquipmentData:getEquipmentListForSuit(self.type)
    self:initTableView()
    self:press(self["btn" .. self.type],self.type)
    self:moveBtn(self.type)
end

function ChatZhuan:resetView()
    for i = 1 , 4 do
        self["btn" .. i ]["ban"]:setColor(cc.c3b(115, 11, 11))  -- 黄色
        self["btn" .. i ]["xia"]:setVisible(true)
        self["btn" .. i ]["shang"]:setVisible(false)
        self["btn" .. i ]:loadTexture("chatadd_lusebtn.png",ccui.TextureResType.plistType)
    end 
end 

-- 点中为绿色
function ChatZhuan:press(view,num)
    self:resetView()
    view.ban:setColor(cc.c3b(6, 53, 17))  -- 绿色
    view:loadTexture("chatadd_lvsebtn.png",ccui.TextureResType.plistType)
    view.xia:setVisible(false)
    view.shang:setVisible(true)
    self.type = num
    self.typelist ,self.equip_type , self.level = EquipmentData:getEquipmentListForSuit(num)
--    print("self.typelist .. " .. debug.dump(self.typelist))
    self.bg2.dataLen = #self.typelist 
    self.bg2.tableView:reloadData()
    self.bg2:setSliderCell(0)
    self:moveBtn(self.type)
end 

function ChatZhuan:initTableView()
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

        for i=1,3 do
            local view = ChatZhuanUntil:createView()
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
    createTableView({},self.create,self.updateItemData,cc.p(self.bg2.sc:getPositionX(),self.bg2.sc:getPositionY()),self.bg2.sc:getSize(),cc.size(288,72),self.bg2,nil, 3 ,2)
    self.bg2.dataLen = #self.typelist -- 由于传空数据
    if #self.typelist == 0 then 
        self.bg2.dataLen = 5
    end 
    
    self.bg2.tableView:reloadData()  
end 

-- 移动按钮跟背景
function ChatZhuan:moveBtn(type)
    local plist = {}
    local bgp = {}
    plist = positionlist[type]
    bgp = bgpositionlist[type]
    for key ,value in pairs(plist) do
        self["btn" .. key]:setPosition(cc.p(value[1],value[2]))
    end 
    self.bg2:setPosition(cc.p(bgp[1],bgp[2]))
end 

function ChatZhuan:createView()
   local view = ChatZhuan.new()
   return view
end  