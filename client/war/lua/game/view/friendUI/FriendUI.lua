-- author:toking
local resPath = "image/ui/FriendUI/"

require("lua/game/view/friendUI/FriendItem.lua")
require("lua/game/view/friendUI/FriendRecomUI.lua")
require("lua/game/view/friendUI/FriendAdd.lua")
require("lua/game/view/friendUI/FriendDetail.lua")
require("lua/game/view/friendUI/FriendBlack.lua")

FriendUI = createUILayout("FriendUI", resPath .. "Friend_main.ExportJson", 'ChatUI' )

function FriendUI:ctor( ... )
    self.AddWinList = {addui= {ui = FriendAdd,point = {x=535,y=577-195}},detailui={ui=FriendDetail,point = {x=535,y=577-431}},
    recomui={ui=FriendRecomUI,point={x=535,y=0}},black={ui = FriendBlack,point={x=535,y=577-195}}}

    self.mask:loadTexture("image/ui/FriendUI/img/mask_1.png", ccui.TextureResType.localType )
    local function btnHandler(sender,eveType )
        if eveType ~= ccui.TouchEventType.ended then
            return
        end

        if gameData.checkLevel(15) == false then
            TipsMgr.showError("需要15级以上才可使用")
            return
        end
        local name = sender:getName()
        ActionMgr.save( 'UI', 'FriendUI click'..name )
        FriendData:btnHandler(name,self)
    end
    UIMgr.addTouchEnded( self.btn_main_add, btnHandler )
    UIMgr.addTouchEnded( self.btn_main_invit, btnHandler )
    --self.isUpRoleTopView = true
    self.item_contat={}

    function self.update( ... )
        self:updateData()
    end
    function self.updateType( ... )
    	self:hideOtherAllWin()
    	self:updateData()
    end
    self.btnlist = {}
    self.datalist = {}

    for k=1,4 do
        table.insert(self.btnlist,{btn_selected = self["btn_top2" .. k] ,btn_unselected =self["btn_top1" .. k]})
        self["btn_top2" .. k]:setTouchEnabled(true)
    end

    local typedata = {FriendData.TYPE_FRIEND,FriendData.TYPE_BLIACK,FriendData.TYPE_ASKED,FriendData.TYPE_STRANGER}
    self.tab = createTab(self.btnlist, typedata)
    self["btn_top2" .. 1]:setTouchEnabled(true)
    self["btn_top1" .. 1]:setTouchEnabled(true)
    self.mask:setTouchEnabled(true)

    function self.handler(value)
        ActionMgr.save( 'UI', 'FriendUI click btn_top' )
        self.percent =nil
        FriendData:setCurrentType(value.data,self)
    end

    self.tab:addEventListener(self.tab, self.handler)


    function self.updateItemData(data ,constant, dataIndex, itemIndex, widhtCount )
        constant.index = dataIndex
        constant.view:updateData(self.datalist[dataIndex])
        if self.datalist[dataIndex] and (self.datalist[dataIndex].friend_name == nil or self.datalist[dataIndex].friend_name == "") then
            FriendData:updateCachetData(self.datalist[dataIndex].friend_id,constant.view)
        end
        -- if FriendData.current_type == FriendData.TYPE_ASKED then
        -- 	FriendData:updateCachetData(self.datalist[dataIndex],constant.view)
        -- else
        -- 	FriendData:updateCachetData(self.datalist[dataIndex].friend_id,constant.view)
        -- end
    end

    function self.create()
        local content = display.newLayer()
        content:setAnchorPoint(cc.p(0,0))
        content:setPosition(cc.p(0, 0))
        content:setTag(1)
        local view = self:createItem()
        content:addChild(view)
        content.view = view
        view:setPosition(8,0)
        return content
    end

    function self.touchCell( conctent, index, itemIndex )
        if conctent and conctent.view and conctent.view.friend_data then
            ActionMgr.save( 'UI', 'FriendUI click FriendItem' )
        	local friendData = conctent.view.friend_data
            if FriendData.current_type == FriendData.TYPE_FRIEND or FriendData.current_type == FriendData.TYPE_STRANGER then
                --ChatData.chatWithFriend(friendData)
        		FriendData:btnHandler("btn_gift_chat",friendData.friend_id)
            end
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
    self.tableView = createTableView({}, self.create,self.updateItemData, cc.p( 17-8, 83 ),cc.size(507+16,435), cc.size(507+16,97), self, self.slider, 1 ,5)
    self.tableView:registerScriptHandler( scrollViewDidScroll,cc.SCROLLVIEW_SCRIPT_SCROLL )
end

function FriendUI:dispose( ... )
    if #self.item_contat > 0 then
        for i=1,#self.item_contat do
        	self.item_contat[i]:onClose()
            self.item_contat[i]:release()
        end
    end
    self.s = nil
    self.item_contat = nil
    self.btnlist = nil
    self.datalist = nil
    self.detailui = nil
    self.addui = nil
    self.recomui = nil
    self.main_ui = nil
    --self.percent = nil
end

function FriendUI:createItem( ... )
    local item = FriendItem:new()
    local function btnHandler(sender,eveType )
        ActionMgr.save( 'UI', 'FriendUI click icon_face' )
        item.icon_face:setScale(0.75,0.75)
		if eveType ~= ccui.TouchEventType.ended then
	        return
	    end
	    local name = sender:getName()
	    if name == "icon_face" then
	    	 local pitem = sender:getParent()
	    	 if pitem then
	    		self:showDetail(pitem)
    		end
    	end
	end
    local function btncancel(sender,eveType )
        item.icon_face:setScale(0.75,0.75)
    end
    --UIMgr.addTouchEnded( item.icon_face, btnHandler )
    item:setTouchEnabled(false)
    createScaleButton(item.icon_face,nil,nil,nil,nil,0.8)
    item.icon_face:addTouchEnded(btnHandler)
     item.icon_face:addTouchCancel(btnHandler)
    item:retain()
    --createScaleButton(item,nil,nil,nil,nil,1.05)
    table.insert(self.item_contat,item)
    return item
end

function FriendUI:showDetail( item )
	if self.fla_recom == nil then
		if FriendData.current_type == FriendData.TYPE_FRIEND or FriendData.current_type == FriendData.TYPE_STRANGER then
			self:showOtherWin("detailui",item.role_id)
		elseif FriendData.current_type == FriendData.TYPE_BLIACK then
			self:showOtherWin("black",item.role_id)
		end
	end
end

function FriendUI:onShow( ... )
    Command.run( 'friend list')
    Command.run( 'friend limit_list')
    EventMgr.addListener(EventType.FriendUpdata, self.updateData,self )
    EventMgr.addListener(EventType.FriendLimitChange, self.updateData,self )
    EventMgr.addListener(EventType.FriendTypeChange,self.updateType)
    EventMgr.addListener("chatUpdate", self.updateData,self )
    if FriendData:AskedAwaitNum() > 0 then
        self.tab:clickIndex(3)
    end
    self:updateData()
end

function FriendUI:onClose( ... )
    EventMgr.removeListener(EventType.FriendUpdata, self.updateData,self)
    EventMgr.removeListener(EventType.FriendLimitChange, self.updateData,self)
    EventMgr.removeListener(EventType.FriendTypeChange,self.updateType)
    EventMgr.removeListener("chatUpdate",self.updateData,self)
    self:dispose()
end

function FriendUI:updateData( ... )
    self.tab:setIndexVible(3,FriendData:AskedAwaitNum() > 0)
    self.tab:setIndexVible(4,FriendData:getCurrentDataList(FriendData.TYPE_STRANGER) and #FriendData:getCurrentDataList(FriendData.TYPE_STRANGER) > 0)
	self.tab:setSelectedIndex(FriendData:getIndext())
	self.datalist  = FriendData:getCurrentDataList()
	self.dataLen = table.getn(self.datalist)
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
    --红点
    setButtonPointWithNum(self.btn_top23,FriendData:AskedAwaitNum() > 0,FriendData:AskedAwaitNum(),cc.p(94,36))
    setButtonPointWithNum(self.btn_top13,FriendData:AskedAwaitNum() > 0,FriendData:AskedAwaitNum(),cc.p(93,28))

    setButtonPointWithNum(self.btn_top21,FriendData:getNewFriendChat(FriendData.TYPE_FRIEND) > 0,FriendData:getNewFriendChat(FriendData.TYPE_FRIEND),cc.p(94,36))
    setButtonPointWithNum(self.btn_top11,FriendData:getNewFriendChat(FriendData.TYPE_FRIEND) > 0,FriendData:getNewFriendChat(FriendData.TYPE_FRIEND),cc.p(93,28))
    setButtonPointWithNum(self.btn_top24,FriendData:getNewFriendChat(FriendData.TYPE_STRANGER) > 0,FriendData:getNewFriendChat(FriendData.TYPE_STRANGER),cc.p(94,36))
    setButtonPointWithNum(self.btn_top14,FriendData:getNewFriendChat(FriendData.TYPE_STRANGER) > 0,FriendData:getNewFriendChat(FriendData.TYPE_STRANGER),cc.p(93,28))
end

function FriendUI:getS( ... )
    if self.s == nil then
        self.s = self.main_ui.getSize and self.main_ui:getSize() or self.main_ui:getContentSize()
    end
    return self.s
end

function FriendUI:showOtherWin( winname ,role_id)
    for _,v in pairs(self.AddWinList) do
        if _ ~= winname then
            if self[_] then
                self[_].ui:setVisible(false)
            end
        end
    end

    if self[winname] and self[winname].ui:getParent() and self[winname].ui:isVisible() then
        self:hideOtherWin(winname)
        return
    end
    if self[winname] == nil and self.AddWinList[winname] then
        self[winname] = {}
        self[winname].ui = self.AddWinList[winname].ui:new()
        self[winname].ui.parents=self
        self[winname].point = self.AddWinList[winname].point
        self:addChild(self[winname].ui)
        self[winname].ui:setPosition(self[winname].point.x,self[winname].point.y)
    end
    self[winname].ui:setVisible(true)
    if self[winname].ui.onShow then
        self[winname].ui:onShow()
    end
    if role_id and self[winname].ui.setRoleId then
        self[winname].ui:setRoleId(role_id)
    end
    local s2 = self[winname].ui.getSize and self[winname].ui:getSize() or self[winname].ui:getContentSize()
    --self.main_ui:setPositionX(visibleSize.width / 2 - (self:getS().width + s2.width)/2 + self:getS().width/2)
end

function FriendUI:updateSize( ... )
	local curui = nil
	for _,v in pairs(self.AddWinList) do
        if self[_] and self[_].ui:isVisible() then
            curui = self[_].ui
        end
    end
    if curui then
    	local s2 = curui.getSize and curui:getSize() or curui:getContentSize()
    	--self.main_ui:setPositionX(visibleSize.width / 2 - (self:getS().width + s2.width)/2 + self:getS().width/2)
    else
    	 --self.main_ui:setPositionX(visibleSize.width / 2)
    end
end

function FriendUI:hideOtherAllWin( ... )
	local hidother = false
	for _,v in pairs(self.AddWinList) do
        if self[_] then 
    		if self[_].ui:isVisible() then
            	self[_].ui:setVisible(false)
            end
            self[_].ui:onClose()
        	if self[_].ui:getParent() then
        		self[_].ui:removeFromParent()
            end
            self[_] = nil
            hidother = true
        end
    end
    --self.main_ui:setPositionX(visibleSize.width / 2)
    return hidother
end

function FriendUI:hideOtherWin( winname )
    if self[winname] then
    	if self[winname].ui then
        	self[winname].ui:onClose()
        	if self[winname].ui:getParent() then
        		self[winname].ui:removeFromParent()
            end
	    end
	    self[winname] = nil
        --self.main_ui:setPositionX(visibleSize.width / 2)
    end
end

function FriendUI:addMainUI( win )
	self.main_ui = win
end