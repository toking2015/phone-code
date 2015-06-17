--@author zengxianrong
--@author zengxianrong
local prePath = "image/ui/FightPower/"
local url_item = prePath .. "FightPowerItem.ExportJson"
local url_module = prePath .. "FightPowerModule.ExportJson"
--require("lua/game/view/bagUI/BagItem.lua")

--Item ------------------------------
local FightPowerItem = class(
    "FightPowerItem", 
    function()
        return getLayout(url_item)
    end
)

function FightPowerItem:ctor()
    self:setTouchEnabled(true)
    self.bg:loadTexture("FightPower/bg_item.png",ccui.TextureResType.plistType)
    --描边
    addOutline(self.name, cc.c4b(0x30, 0x00, 0x00, 0xff), 2)
    addOutline(self.Label_5, cc.c4b(0x30, 0x00, 0x00, 0xff), 2)
    local function onGetTouchend(sender, eventType)
       -- ActionMgr.save( 'UI', '[TargetItem] click [btn_get]' )
        -- if SignData.canSign( ) then
        --     trans.send_msg("PQSign", {})
        -- end
    end
    UIMgr.addTouchEnded(self, setTouchEnabled)
end

function FightPowerItem:updateData( ... )
    if self.data_type then
        local oldPoin = FightPowerData.getOldPoint(nil,self.data_type)
        local point = FightPowerData.getPointTypeStype(FightPowerData.curType,self.data_type)
        local jdata = FightPowerData.getDataListTypeData(nil,self.data_type)
        self.Label_5:setString(point .. "分")
        if point < 40 then
            self.fla_a:setVisible(true)
        else
            self.fla_a:setVisible(false)
        end
        if jdata then
            self.name:setString(jdata.name)
            self.tips:setString(jdata.s_tips)
        end
        oldPoin = oldPoin or 0
        if  point ~= oldPoin then
            local progress = cc.ProgressFromTo:create(0.3, oldPoin, point) 
            self.left:runAction(progress)
            FightPowerData.updateValueMap(nil,self.data_type,point)
        else
            self.left:setPercentage(point)
        end
        FightPowerData.curStype = 0
        --performWithDelay(self, actionCom, 0.4)
    end
end
--BuyUI 
local FightPowerModule = class(
    "FightPowerModule", 
    function()
        return getLayout(url_module)
    end
)

function FightPowerModule:ctor()
    self:setTouchEnabled(true)
    local function onBuyTouchend(sender, eventType)
        --ActionMgr.save( 'UI', '[TargetBuyUI] click [btn_get]' )
        -- if SignData.canSign( ) then
        --     trans.send_msg("PQSign", {})
        -- end
    end
    UIMgr.addTouchEnded(self, onBuyTouchend)
end
function FightPowerModule:updateData( ... )
    if self.data_type then
        if FightPowerData.cheakOpen(self.data_type) then
            self.fla_unopen:setVisible(false)
            self.num_point:setVisible(true)
        else
            self.fla_unopen:setVisible(true)
            self.num_point:setVisible(false)
        end
        local datalist = FightPowerData.getDataList()
        local itemlist = datalist[self.data_type]
        if itemlist and itemlist[1] then
            self.Label_3:setString(itemlist[1].tips)
        end
        self.num_point:setString(FightPowerData.getPointType(self.data_type))
    end
end
---
-- 窗口类
---
local FightPowerUI = createUIClass("FightPowerUI", prePath .. "FightPower_1.ExportJson", PopWayMgr.SMALLTOBIG)
FightPowerUI.sceneName = "common"

function FightPowerUI:ctor()
    --竞技场
    local fprePath = "image/ui/FormationUI/"
    LoadMgr.loadPlist(fprePath.."FormationBG.plist", nil, LoadMgr.WINDOW, self.winName)
    self.bgf:loadTexture(prePath .. "FightPower/bg_img.png",ccui.TextureResType.localType)
    self.bg_title:loadTexture("FightPower/bg_title.png",ccui.TextureResType.plistType)
    --位置
    self.module_list = {}
    self:initMudule()

    self.item_list = {}
    self:initItem()
    self.container:setVisible(true)
    self.bg_item:setVisible(false)
end

function FightPowerUI:initItem( ... )
    self.mstar_point2 = cc.p(-139 + 140,115 + 238)
    self.istar_point = cc.p(-131 + 140,-221 + 238)
    self.ispace = 85
    self.item_list = {}
    self.cur_module = self:createMudle(1)
    self.cur_module:setTouchEnabled(false)
    self.bg_item:addChild(self.cur_module)
    self.cur_module:setPosition(cc.p(self.mstar_point2.x,self.mstar_point2.y))
    for i=1,4 do
        local item = self:createItem(i)
        self.bg_item:addChild(item)
        item:setPosition(cc.p(self.istar_point.x,self.istar_point.y + self.ispace * (5 - i -1)))
        table.insert(self.item_list,item)
    end
    local function onBackHandle( sender,event )
        FightPowerData.setCurType(0)
    end
    createScaleButton(self.bg_item.btn_back)
    self.bg_item.btn_back:addTouchEnded(onBackHandle)
end

function FightPowerUI:initMudule( ... )
    self.mstar_point = cc.p(594,14)
    self.mstar_point2 = cc.p(-139,115)
    self.mspace = 126
    self.module_list = {}
    for i=1,4 do
        local mud = self:createMudle(i)
        self.container:addChild(mud)
        mud:setPosition(cc.p(self.mstar_point.x,self.mstar_point.y + self.mspace * ( 5 - i -1)))
        table.insert(self.module_list,mud)
    end
end

function FightPowerUI:onShow()
    EventMgr.addListener(EventType.FightPowerUpdate,self.updateData,self)
    self.roleview = UIFactory.getNode(self.bgf)
    self.view = FormationView.new(self.roleview)
    self.bgf:addChild(self.view)
    self.roleview:setLocalZOrder(10)
    self.conlayer = UIFactory.getLayout(578,388,self.bgf,11)
    self.view:setPosition(cc.p(0,-54))
    self.roleview:setPosition(0,-54)
    self.view:setType(const.kFormationTypeCommon)
    self.view:updateData()
    self.conlayer:setTouchEnabled(true)
    UIMgr.registerScriptHandler(self.bgf, onTouchBegin, cc.Handler.EVENT_TOUCH_BEGAN, true)
    performNextFrame(self, function() self:updateData() end)
end

function FightPowerUI:updateData( ... )
    self.num_point:setString(FightPowerData.getPointAll())
    self.num_fight:setString(UserData.getFightValue())
    if FightPowerData.curType == 0 then
        self.container:setVisible(true)
        self.bg_item:setVisible(false)
        self:updateModule()
    else
        self.container:setVisible(false)
        self.bg_item:setVisible(true)
        self:updateItem()
    end
end

function FightPowerUI:updateModule( ... )
    for i,v in pairs(self.module_list) do
        if v then
            v:updateData()
        end
    end
end

function FightPowerUI:updateItem( ... )
    if FightPowerData.curType > 0 then
        self.cur_module.data_type = FightPowerData.curType
        self.cur_module.bg:loadTexture("FightPower/icon_"..self.cur_module.data_type..".png",ccui.TextureResType.plistType)
        self.cur_module:updateData()
        local curDatalist = FightPowerData.getDataListCurType()
        local len = curDatalist and #curDatalist or 0
        for k,v in pairs(self.item_list) do
            if k > len then
                v:setVisible(false)
            else
                v:setVisible(true)
                v:updateData()
            end
        end
    end
end

function FightPowerUI:dispose( ... )
    -- if #self.item_contat > 0 then
    --     for i=1,#self.item_contat do
    --         self.item_contat[i]:release()
    --     end
    -- end
end

function  FightPowerUI:onClose()
    EventMgr.removeListener(EventType.FightPowerUpdate,self.updateData,self)
     if self.view and  self.view.dispose then
        self.view:dispose()
        self.view:removeFromParent()
        self.view = nil
    end
    if self.roleview then
        self.roleview:removeFromParent()
        self.roleview = nil
    end
    if self.conlayer then
        self.conlayer:removeFromParent()
        self.conlayer = nil
    end
    if self.event_list then
        EventMgr.removeList(self.event_list)
    end
end

function FightPowerUI:createMudle( index )
    index = index or 1
    local item = FightPowerModule:new()
    item.data_type = index
    item.bg:loadTexture("FightPower/icon_"..index..".png",ccui.TextureResType.plistType)
    createScaleButton(item,nil,nil,nil,1.01)
    local function btnHandler(sender,eveType )
        sender:setScale(1,1)
        ActionMgr.save( 'UI', 'FightPowerUI click FightPowerModule' )
        if sender and sender.data_type then
            result = FightPowerData.cheakOpen(sender.data_type,true)
            if result then
                FightPowerData.setCurType(sender.data_type)
            end
        end
    end
    --UIMgr.addTouchEnded( item.icon_face, btnHandler )
    --item:setTouchEnabled(false)
    item:addTouchEnded(btnHandler)
    --item:addTouchCancel(btnHandler)
    --item:retain()
    --createScaleButton(item,nil,nil,nil,nil,1.05)
    return item
end

function FightPowerUI:createItem( type )
    local item = FightPowerItem:new()
    item.data_type = type
    item.bg:loadTexture("FightPower/bg_item.png",ccui.TextureResType.plistType)
    local function btnHandler(sender,eveType )
        ActionMgr.save( 'UI', 'FightPowerItem click FightPowerItem' )
        FightPowerData.itemClickHandle(sender.data_type)
    end
    createScaleButton(item,nil,nil,nil,1.01)
    item.left = UIFactory.getLeftProgressBar("FightPower/icon_pro.png", item, 101, 38)
    item.left:setPercentage(0)
    --UIMgr.addTouchEnded( item.icon_face, btnHandler )
    --item:setTouchEnabled(false)
    item:addTouchEnded(btnHandler)
    --item:retain()
    --createScaleButton(item,nil,nil,nil,nil,1.05)
    return item
end

