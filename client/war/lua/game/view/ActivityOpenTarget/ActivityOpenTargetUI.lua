--@author zengxianrong
--@author zengxianrong
local prePath = "image/ui/ActivityOpenTarget/"
local url_item = prePath .. "ActivityOpenTargetItem.ExportJson"
local url_buyui = prePath .. "ActivityOpenTargetBuyUI.ExportJson"
require("lua/game/view/bagUI/BagItem.lua")

--Item ------------------------------
local TargetItem = class(
    "TargetItem", 
    function()
        return getLayout(url_item)
    end
)

function TargetItem:ctor()
    self:setTouchEnabled(true)
    local function onGetTouchend(sender, eventType)
        ActionMgr.save( 'UI', '[TargetItem] click [btn_get]' )
        -- if SignData.canSign( ) then
        --     trans.send_msg("PQSign", {})
        -- end
    end
    UIMgr.addTouchEnded(self.btn_get, setTouchEnabled)
end
--BuyUI 
local TargetBuyUI = class(
    "TargetBuyUI", 
    function()
        return getLayout(url_buyui)
    end
)

function TargetBuyUI:ctor()
    self:setTouchEnabled(true)
    self.bg:loadTexture(prePath.."bg_buy.png",ccui.TextureResType.localType)
    local function onBuyTouchend(sender, eventType)
        ActionMgr.save( 'UI', '[TargetBuyUI] click [btn_get]' )
        -- if SignData.canSign( ) then
        --     trans.send_msg("PQSign", {})
        -- end
    end
    UIMgr.addTouchEnded(self.btn_get, onBuyTouchend)
end

--刷新显示
function TargetBuyUI:updateData()

end
---
-- 窗口类
---
local ActivityOpenTargetUI = createUIClass("ActivityOpenTargetUI", prePath .. "ActivityOpenTargetUI.ExportJson", PopWayMgr.SMALLTOBIG)
ActivityOpenTargetUI.sceneName = "common"

function ActivityOpenTargetUI:ctor()
    --记录需要释放的其他窗口的资源
    local otherPath = "image/ui/bagUI/"
    LoadMgr.addPlistPool(otherPath.."WarPackage0.plist", otherPath.."WarPackage0.png", LoadMgr.WINDOW, self.winName)

   --左边按钮
    self.tips1:setVisible(false)
    self.tips2:setPosition(550,50)
    self.item_contat = {}
    self.size_btnlist = {}
    self.size_datalist = {}
    self.Image_2.bg_img:loadTexture(prePath.."bg.png",ccui.TextureResType.localType)
    --描边
    addOutline(self.Image_2.Image_3.Label_4, cc.c4b(0x59, 0x1f, 0x05, 0xff), 2)
    for k=1,7 do
        table.insert(self.size_btnlist,{btn_selected = self["btn_day_"..k.."2"] ,btn_unselected =self["btn_day_"..k.."1"]})
        self["btn_day_"..k.."2"]:setTouchEnabled(true)
    end

    local size_typedata = {1,2,3,4,5,6,7}
    self.size_tab = createTab(self.size_btnlist, size_typedata)
    self["btn_day_11"]:setTouchEnabled(true)
    self["btn_day_12"]:setTouchEnabled(true)

    function self.sizehandler(value)
        ActionMgr.save( 'UI', 'ActivityOpenTargetUI click size_tab' )
        self.percent =nil
        OpenTargetData.setSelectDay(value.data)
    end
    self.size_tab:addEventListener(self.size_tab, self.sizehandler)
    --上边按钮
    self.top_btnlist = {}
    for k=1,4 do
    table.insert(self.top_btnlist,{btn_selected = self["btn_top_"..k.."2"] ,btn_unselected =self["btn_top_"..k.."1"]})
    self["btn_top_"..k.."2"]:setTouchEnabled(true)
    end

    local top_typedata = {1,2,3,4}
    self.top_tab = createTab(self.top_btnlist, top_typedata)
    self["btn_top_11"]:setTouchEnabled(true)
    self["btn_top_12"]:setTouchEnabled(true)

    function self.tophandler(value)
        ActionMgr.save( 'UI', 'ActivityOpenTargetUI click top_tab' )
        self.percent =nil
        OpenTargetData.setSelectIndex(value.data)
    end
    self.top_tab:addEventListener(self.top_tab, self.tophandler)
    self.event_list = {}
    self.event_list[EventType.actOpenTargetUpdate] = function ( ... ) self:updateData() end
    self.event_list[EventType.NewDayBegain] = function ( ... )
        if OpenTargetData.getIsOpen() == false then
            Command.run("ui hide","ActivityOpenTargetUI")
        end
    end
end

function ActivityOpenTargetUI:onShow()
    OpenTargetData.updateForce()
    EventMgr.addList(self.event_list)
    performNextFrame(self, function() self:updateData() end)
end

function ActivityOpenTargetUI:updateData( ... )
    self.tips2:setString(OpenTargetData.getActivitTimeStr())
    self.index_datalist =OpenTargetData.getSorJopenTarget(OpenTargetData.getJOpenTarget())
    self:updateDataSizeBtn()
    self:updateDataTopBtn()
    self:updateDataSelect()
end

function ActivityOpenTargetUI:dispose( ... )
    if #self.item_contat > 0 then
        for i=1,#self.item_contat do
            self.item_contat[i]:release()
        end
    end
end

function  ActivityOpenTargetUI:onClose()
    EventMgr.removeList(self.event_list)
end

function ActivityOpenTargetUI:updateDataSizeBtn( ... )
    for i = 1,7 do
        local cangetDay = OpenTargetData.getCangetDay(i)
        setButtonPoint(self["btn_day_"..i.."1"],cangetDay,cc.p(0,51),nil,nil,cc.p(0.9,0.9))
        setButtonPoint(self["btn_day_"..i.."2"],cangetDay,cc.p(0,51),nil,nil,cc.p(0.9,0.9))
        local openDay = OpenTargetData.getCurOpenDay()
        if i <= openDay then
            ProgramMgr.setNormal(self["btn_day_"..i.."1"])
            self["btn_day_"..i.."1"]:setTouchEnabled(true)
        else
            ProgramMgr.setGray(self["btn_day_"..i.."1"])
            self["btn_day_"..i.."1"]:setTouchEnabled(false)
        end
    end
    self.size_tab:setSelectedIndex(OpenTargetData.selectDay)
end

function ActivityOpenTargetUI:updateDataTopBtn( ... )
    self.day_datalist = OpenTargetData.getJOpenTargetDay()
    local len = #self.day_datalist
    for i=1,4 do
        local hasname = false
        if i <= len then
            local datalist = self.day_datalist[i]
            if datalist and #datalist > 0 then
                local jdata = datalist[1]
                if jdata then
                    hasname = true
                    self["btn_top_"..i.."1"].txt_top_11:setString(jdata.name)
                    self["btn_top_"..i.."2"].txt_top_11:setString(jdata.name)
                    local canget = OpenTargetData.getCangetIndex(nil,i)
                    setButtonPoint(self["btn_top_"..i.."1"],canget,cc.p(131-21,58-15),nil,nil,cc.p(0.9,0.9))
                    setButtonPoint(self["btn_top_"..i.."2"],canget,cc.p(131-21,58-15),nil,nil,cc.p(0.9,0.9))
                    self:setDoneFla(self["btn_top_"..i.."1"],OpenTargetData.getDoneIndex(nil,i))
                    self:setDoneFla(self["btn_top_"..i.."2"],OpenTargetData.getDoneIndex(nil,i))
                end
            end
        end
        self.top_tab:setIndexVible(i,hasname)
    end
    self.top_tab:setSelectedIndex(OpenTargetData.selectIndex)
end

function ActivityOpenTargetUI:setDoneFla( btn,value )
    if value then
        if btn.done_fla == nil then
            btn.done_fla = ccui.ImageView:create('ActivityOpenTarget/fla_done.png', ccui.TextureResType.plistType)
            btn.done_fla:setAnchorPoint(cc.p(0, 0))
            btn.done_fla:setTouchEnabled(false)
            btn.done_fla:setScale(0.5,0.5)
            btn:addChild(btn.done_fla)
            btn.done_fla:setPosition(96,4)
        end
        btn.done_fla:setVisible(true)
    else
        if btn.done_fla then
            btn.done_fla:setVisible(false)
        end
    end
end

function ActivityOpenTargetUI:updateDataSelect( ... )
    if self.index_datalist then
        local jdata = self.index_datalist[1] 
        if jdata then
            if jdata.a_type == OpenTargetData.typeBuy then
                self:updateDataBuy()
            else
                self:updateDataNomael()
            end
        end
    end
end
function ActivityOpenTargetUI:updateDataBuy( ... )
    if self.tableView then
        self.tableView:setVisible(false)
    end
    local cx = 554 /2 - 69
    if self.buyUi == nil then
        self.buyUi = TargetBuyUI:new()
        self.content:addChild(self.buyUi)
        self.buyUi:setPosition(cc.p(322 - 44,58))
        self.buyUi.itemList = {}
        for i=1,2 do 
            local itemBox = BagItem:create( "image/ui/bagUI/Item.ExportJson" )
            itemBox.item_num_line:setVisible(false)
            itemBox.btn_item_delect:setVisible(false)
            itemBox:showTips(true)
            self.buyUi:addChild(itemBox)
            self.buyUi.itemList[i] = itemBox
            itemBox:setPosition(158 + (i-1) * 120,122)
        end

        local function btnHandler(sender,eveType )
            ActionMgr.save( 'UI', 'TargetBuyUI click btn_get' )
            --local sender = eveType:getCurrentTarget()
            if sender and sender.jdata and sender.jdata.coin_1 then
                if CoinData.checkLackCoin(sender.jdata.coin_1.cate,sender.jdata.coin_1.val) then
                    return
                else
                    trans.send_msg("PQOpenTargetBuy", {day = sender.jdata.day,guid = sender.jdata.id})
                end
            end
        end
        --UIMgr.addTouchEnded( item.icon_face, btnHandler )
        self.buyUi:setTouchEnabled(false)
        UIMgr.addTouchEnded( self.buyUi.btn_get, btnHandler )

    end
    self.buyUi:setVisible(true)
    self.buyUi.btn_get:setVisible(false)
    self.buyUi.fla_buyed:setVisible(false)
    if self.index_datalist then
        local jdata = self.index_datalist[1]
        self.buyUi.btn_get.jdata = jdata
        if jdata then
            if OpenTargetData.hasBuyItem(jdata) then
                self.buyUi.fla_buyed:setVisible(true)
            else
                self.buyUi.btn_get:setVisible(true)
                if OpenTargetData.getCanBuyItem(jdata) then
                    ProgramMgr.setNormal(self.buyUi.btn_get)
                    self.buyUi.btn_get:setTouchEnabled(true)
                else
                    ProgramMgr.setGray(self.buyUi.btn_get)
                    self.buyUi.btn_get:setTouchEnabled(false)
                end
            end

            if jdata.item then
                local len = #jdata.item
                local starx = cx - (104 * len + 80 * (len - 1) )/2
                for i=1,2 do 
                    if i> len then
                        self.buyUi.itemList[i]:setVisible(false)
                    else
                        self.buyUi.itemList[i]:setVisible(true)
                        self:updateItemBox(self.buyUi.itemList[i],jdata.item[i])
                        self.buyUi.price_old:setString(tostring(jdata.coin_1.val * 2))
                        self.buyUi.price_now:setString(tostring(jdata.coin_1.val))
                    end
                    self.buyUi.itemList[i]:setPosition(starx + ((i-1) * 104 + 80 ),122)
                end
            end
        end
    end
end
function ActivityOpenTargetUI:updateDataNomael( ... )
    if self.buyUi then
        self.buyUi:setVisible(false)
    end
    if self.tableView == nil then
        self:initTableView()
    end
    self.tableView:setVisible(true)
    self.dataLen = #self.index_datalist
    self.oldPercent = self.percent
    self.tableView:reloadData()
    if self.oldPercent ~= nil and type(self.oldPercent) == "number" then
        local TableHeight = self.tcellHeigth * self.dataLen
        local viewHeight = 435
        local ScrollOffH = math.max(0,TableHeight - viewHeight)
        --self.percent = math.ceil( self.tableView:getContentOffset().y / ScrollOffH * 100)
        local h =  self.oldPercent/100 * ScrollOffH
        self.tableView:setContentOffset( cc.p(0, h) )
    end
end

function ActivityOpenTargetUI:initTableView( ... )

    function self.updateItemData(data ,constant, dataIndex, itemIndex, widhtCount )
        constant.index = dataIndex
        local Jdata = self.index_datalist[dataIndex]
        if constant.view and constant.view.itemList then
            constant.view.btn_get.jdata = nil
            for k,v in pairs(constant.view.itemList) do
                v:setVisible(false)
            end
            constant.view.btn_get:setVisible(false)
            constant.view.fla_getted:setVisible(false)
            if Jdata and Jdata.reward then
                constant.view.txt_rate:setString(OpenTargetData.getRateStr(Jdata))
                constant.view.btn_get.jdata = Jdata
                if OpenTargetData.getCangetItem(Jdata) then
                    constant.view.btn_get:setVisible(true)
                    ProgramMgr.setNormal(constant.view.btn_get)
                    constant.view.btn_get:setEnabled(true)
                    setButtonPoint(constant.view.btn_get,true,cc.p(136-21,51-15),nil,nil,cc.p(0.9,0.9))
                else
                    if OpenTargetData.hasGetItem(Jdata) then
                        constant.view.fla_getted:setVisible(true)
                    else
                        constant.view.btn_get:setVisible(true)
                        ProgramMgr.setGray(constant.view.btn_get)
                        constant.view.btn_get:setEnabled(false)
                        setButtonPoint(constant.view.btn_get,false,cc.p(136-21,51-15),nil,nil,cc.p(0.9,0.9))
                    end
                end
                for i=1,4 do 
                    if i <= #Jdata.reward then
                        local reward = Jdata.reward[i]
                        constant.view.itemList[i]:setVisible(true)
                        self:updateItemBox(constant.view.itemList[i],reward)
                        constant.view.txt_desc:setString(Jdata.desc)
                    end
                end
            end
        end
    end

    function self.create()
        local content = display.newLayer()
        content:setAnchorPoint(cc.p(0,0))
        content:setPosition(cc.p(0, 0))
        content:setTag(1)
        local view = self:createItem()
        content:addChild(view)
        content.view = view
        content.view.itemList = {}
        view:setPosition(0,0)

        for i=1,4 do
            local itemBox = BagItem:create( "image/ui/bagUI/Item.ExportJson" )
            itemBox:setScale(0.7,0.7)
            itemBox.scalew = 1.3
            itemBox.item_num:setScale(1.2,1.2)
            itemBox.item_num_line:setVisible(false)
            itemBox.btn_item_delect:setVisible(false)
            itemBox:showTips(true)
            content.view:addChild(itemBox)
            itemBox:setPosition(30 + (i-1) * 92,18)
            content.view.itemList[i] = itemBox
        end
        return content
    end

    function self.touchCell( conctent, index, itemIndex )
        if conctent and conctent.view and conctent.view then
        end
    end

    local function scrollViewDidScroll(view)
        local TableHeight = self.tcellHeigth * self.dataLen
        local viewHeight = 435
        local ScrollOffH = math.max(0,TableHeight - viewHeight)
        local curY = self.tableView:getContentOffset().y
        if ScrollOffH > 0 then
            self.percent = curY / ScrollOffH * 100
        else
            self.percent = nil
        end
        --self.percent = math.ceil( self.tableView:getContentOffset().y / self.ScrollOffH * 100)
    end
    self.tableView = createTableView({}, self.create,self.updateItemData, cc.p( 307, 90 - 15 ),cc.size(512,290 + 15), cc.size(512,140), self, self.slider, 1 ,2)
    self.tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL )
end
function ActivityOpenTargetUI:updateItemBox( rewardItem,reward )
    if not rewardItem or not reward then
        return
    end
    rewardItem:setReward(reward)
end

function ActivityOpenTargetUI:createItem( ... )
    local item = TargetItem:new()
    item.bg:loadTexture(prePath.."bg_item.png",ccui.TextureResType.localType)
    local function btnHandler(sender,eveType )
        ActionMgr.save( 'UI', 'TargetItem click btn_get' )
        --local sender = eveType:getCurrentTarget()
        if sender and sender.jdata then
            trans.send_msg("PQOpenTargetTake", {day = sender.jdata.day,guid = sender.jdata.id})
        end
    end
    --UIMgr.addTouchEnded( item.icon_face, btnHandler )
    item:setTouchEnabled(false)
    UIMgr.addTouchEnded( item.btn_get, btnHandler )
    item:retain()
    --createScaleButton(item,nil,nil,nil,nil,1.05)
    table.insert(self.item_contat,item)
    return item
end

