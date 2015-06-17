-- by weihao 
-- 雕文
require("lua/game/view/chatUI/chatAdd/ChatDiaoUntil")
local prePath = "image/ui/ChatUI/"

local num = 115
local x = 10
local first = 295
local utext = 40
local positionlist = {
    [1]={[1] = {x,first},[2] ={x,first - utext -num},[3] ={x,first - utext*2 -num},[4] ={x,first - utext*3 -num}},
    [2]={[1] ={x,first},[2] = {x,first - utext},[3] ={x,first - utext*2-num},[4] = {x,first - utext*3-num}},
    [3]={[1] ={x,first},[2] ={x,first - utext},[3] ={x,first - utext*2},[4] ={x,first - utext*3-num}},
    [4]={[1] ={x,first},[2] ={x,first - utext},[3] ={x,first - utext*2},[4] ={x,first - utext*3}}
}

local num1 = 130
local bgpositionlist = {
    [1] = {x, first- num1},
    [2] = {x, first - utext -num1},
    [3] = {x, first - utext * 2  -num1},
    [4] = {x, first - utext * 3  -num1}
}
ChatDiao= class("ChatDiao",function() 
    return getLayout(prePath .. "ChatDiao.ExportJson")
end)

function ChatDiao:ctor()
    for i = 1 , 4 do
        createScaleButton(self["btn" .. i],nil,nil,nil,nil,1)
        self["btn" .. i]:addTouchEnded(function()
            ActionMgr.save( 'UI', 'ChatDiao click up btn' .. i )
            if self.type ~= i then 
               self:press(self["btn" .. i ])
               local type = i
               if i == 2 then
                  type = 3 
               elseif i == 3 then 
                  type = 2
               end 
               self:refreshView(type)
               self:moveBtn(i)
               self.type = i 
            end 
        end)
    end 
    self:resetView()
    self.typelist = {} 
    self.type = 1 -- 默认第一个按钮的东西
    self:moveBtn(self.type)
    self.btn1:loadTexture("chatadd_lvsebtn.png",ccui.TextureResType.plistType)
    self.btn1.xia:setVisible(false)
    self.btn1.shang:setVisible(true)
    local list = TotemData.getGlyphList()
--    print("list .. " .. debug.dump(list))
    self:refreshView(self.type)
    self:initTableView()
end 

function ChatDiao:resetView()
    for i = 1 , 4 do
        self["btn" .. i ]["xia"]:setVisible(true)
        self["btn" .. i ]["shang"]:setVisible(false)
        self["btn" .. i ]:loadTexture("chatadd_lusebtn.png",ccui.TextureResType.plistType)
    end 
end 

function ChatDiao:refreshView(type)
   local list = TotemData.getGlyphList()
   
   self.typelist = {} 
   for key , value in pairs(list) do 
       local data = findTempleGlyph(value.id)
--        data.list = value 
        if data.type  == type then 
          --土
          table.insert(self.typelist,value)
        elseif data.type  == type then    
          --火
          table.insert(self.typelist,value)
        elseif data.type  == type then 
          --水
          table.insert(self.typelist,value)
        elseif data.type  == type then 
          --风
          table.insert(self.typelist,value)
       end 
   end 
   
   local function select_sort(t)
        for i=1, #t - 1 do
            local max = i
            for j=i+1, #t do
                if t[j] ~= nil then 
                    if #t[j].attr_list > #t[max].attr_list or #t[j].hide_attr_list > #t[max].hide_attr_list  then
                        max = j
                    end
                end 
            end
            if max ~= i then
                t[max], t[i] = t[i], t[max]
            end
        end
   end
   select_sort(self.typelist)
   self.bg2.dataLen = #self.typelist 
   if self.bg2.tableView ~= nil then 
      self.bg2.tableView:reloadData()
      self.bg2:setSliderCell(0)
   end 
   
end 

function ChatDiao:initTableView()
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
            local view = ChatDiaoUntil:createView()
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
    createTableView({},self.create,self.updateItemData,cc.p(self.bg2.sc:getPositionX()+10,self.bg2.sc:getPositionY()+20),self.bg2.sc:getSize(),cc.size(288,72),self.bg2,nil, 4 ,2)
    self.bg2.dataLen = #self.typelist -- 由于传空数据
    if #self.typelist == 0 then 
        self.bg2.dataLen = 2 
    end 
    self.bg2.tableView:reloadData()  
end 

-- 移动按钮跟背景
function ChatDiao:moveBtn(type)
   local plist = {}
   local bgp = {}
   plist = positionlist[type]
   bgp = bgpositionlist[type]
   for key ,value in pairs(plist) do
      self["btn" .. key]:setPosition(cc.p(value[1],value[2]))
   end 
   self.bg2:setPosition(cc.p(bgp[1],bgp[2]))
end 


function ChatDiao:press(view)
    self:resetView()
    view:loadTexture("chatadd_lvsebtn.png",ccui.TextureResType.plistType)
    view.xia:setVisible(false)
    view.shang:setVisible(true)
end 

function ChatDiao:createView()
   local view = ChatDiao.new()
   return view 
end 