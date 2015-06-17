-- create by Hujingjiang --
require("lua/game/view/mainUI/BackButton.lua")
-- 通过此方法创建类对象
MainSceneUI = class("MainSceneUI", function()
	return Node:create()	
end)

function MainSceneUI:ctor()
	-- 初始化左上角，左上角底下对象，顶部对象，按钮对象组等
	self.con_head = MainUIMgr.getRoleHead()
	self.con_sign = MainUIMgr.getRoleSign()
	self.con_top = MainUIMgr.getRoleTop()
	self.con_group = MainUIMgr.getRoleRight()
	self.con_btnGroup = MainUIMgr.getRoleBottom()
    self.mainchat = MainUIMgr.getMainChat()
    self.paomaui = MainUIMgr.getPaomaUI()
--    self.mainchat = MainChatUI:createView()
--    self.mainchat:initBtn()
--	self.btn_chat = ccui.ImageView:create("main_chat.png", ccui.TextureResType.plistType)
--	self.btn_chat:setAnchorPoint(0, 0)
--	self.btn_chat:setPosition(cc.p(0, 280))
--	self:addChild(self.btn_chat)
--	self.btn_chat = createScaleButton(self.btn_chat)
	
	-- 注册点击事件
--	local function showChatHandler(ref, eventType)
--        if ChatData.isShowChat == false then 
--            ChatData.isShowChat = true
--          Command.run('ui show' , 'ChatUI' ,PopUpType.SPECIAL)
--		    PopMgr.popUpWindow("ChatUI", nil, nil, true)
--	    end
--	end
--    UIMgr.addTouchEnded(self.btn_chat, showChatHandler)

	self.time_count = 0

    self.event_list = {}
    self.event_list[EventType.UserCoinUpdate] = function(data)
    	if data.coin.cate == trans.const.kCoinTeamXp then
    		if data.set_type == 1 then -- 刪除不处理
    			self.con_head:obtainExpAction(data)
    		end
    		-- self.con_head:updateExp(data)
    	elseif data.coin.cate == const.kCoinVipLevel then
			self.con_head:updateVipLevel()
    	elseif data.coin.cate == const.kCoinTeamLevel then
    		self.con_head:updateLevel()
    	else
    		self:onUserCoinUpdate()
    	end
    end
    self.event_list[EventType.UserVarUpdate] = function ( data )
    	if data == "frist_pay_reward_flag" then
    		self.con_sign:updateFRData()
    		Command.run("ui hide","ActivityFRUI")
    	end
    end
    self.event_list[EventType.UserPayUpdate] = function ( )
    		self.con_sign:updateFRData()
    end
	self.event_list[EventType.CloseWindow] = function()
		self:onUserCoinUpdate()
		-- self.con_head:updateExp()
		self.con_head:updateLevel()
		self.con_head:updateVipLevel()
		self.con_head:updateAvatar()
	end
	self.event_list[EventType.SceneShow] = function()
		self.con_head:updateExp()
		self.con_head:updateLevel()
		self.con_head:updateVipLevel()
		self.con_head:updateAvatar()
		self:showNewCopyOpen()
	end														
    self.event_list[EventType.TeamNameChange] = function()
    	self.con_head:updateName()
    end
    self.event_list[EventType.UserSoldierUpdate] = function()
    	self.con_btnGroup:updateHeroData()
	end
	self.event_list[EventType.UserItemUpdate] = function()
    	self.con_btnGroup:updateHeroData()
	end
	local function onSimpleUpdate()
		self.con_head:updateAvatar()
		self.con_sign:updateFRData()
		-- self.con_head:updateFightValue()
	end
	self.event_list[EventType.UserSimpleUpdate] = onSimpleUpdate
--	self.event_list[EventType.ShowGetCopyPrize] = function(list)
--		showGetEffect(list)
--	end
--    self.event_list[EventType.NCopyUIHide] = function()
--        local parent = self.con_top:getParent()
--        if parent ~= self then
--            if parent ~= nil then
--                self.con_top:removeFromParent() 
--            end
--            self:addChild(self.con_top)
--            self.con_top:setCascadeOpacityEnabled(true)
--            setUiOpacity(self.con_top, 255)
--        end
--        parent = self.con_btnGroup:getParent()
--        if parent ~= self then
--            if nil ~= parent then
--                self.con_btnGroup:removeFromParent() 
--            end
--            self:addChild(self.con_btnGroup)
--            self.con_btnGroup:setCascadeOpacityEnabled(true)
--            setUiOpacity(self.con_btnGroup, 255)
--        end
--        parent = self.con_group:getParent()
--        if parent ~= self then
--            if nil ~= parent then
--                self.con_group:removeFromParent() 
--            end
--            self:addChild(self.con_group)
--            self.con_group:resetShow()
--            self.con_group:setPositionY(198)
--            self.con_group:setCascadeOpacityEnabled(true)
--            setUiOpacity(self.con_group, 255)
--        end
--    end
end

function MainSceneUI:onUserCoinUpdate()
	self.con_top:updateData()
end

function MainSceneUI:showNewCopyOpen()
	if not SceneMgr.isSceneName("main") then
		return
	end
	local isShow = CopyMgr.checkNextCopy()
	-- LogMgr.debug("是否开启新副本", isShow)
	if not isShow then -- hide
		local copy_id = CopyData.getNextCopyId()
		if 0 == copy_id or not CopyData.checkOpenAreaBy(copy_id, gameData.user.simple.team_level) then
			self.btn_copy.new_copy:setVisible(false)
			return
		end

		local task = TaskData.getMianTask()
		if not task then
			self.btn_copy.new_copy:setVisible(false)
			return
		end

		--玩家完成10034任务后&&玩家在主界面并且停留时间超过10秒钟（指没有任何动作）
		if 10034 < task.task_id then
			self:startTimer()
		else
			self.btn_copy.new_copy:setVisible(false)
		end
	else
		local state = BackButton:getCurrState()
		local induct = InductMgr:checkRun()
		if BackButton.STATE_COPY == state and not induct and not BackButton:isBackActionCom() then
			self.btn_copy.new_copy:setVisible(true)
		end
	end
end

function MainSceneUI:startTimer()
	local function callfunc()
		self.time_count = self.time_count + 1
		-- LogMgr.debug("time_count = " .. self.time_count)
		if self.time_count >= 10 then -- show
			local state = BackButton:getCurrState()
			if self.cid then TimerMgr.killTimer(self.cid) self.cid = nil end
			-- LogMgr.debug('state = ', state)
			local induct = InductMgr:checkRun()
			if BackButton.STATE_COPY == state and not induct and not self.btn_copy.new_copy:isVisible() then
				self.btn_copy.new_copy:setVisible(true)
			end
		end
	end
	local state = BackButton:getCurrState()
	if not self.cid and BackButton.STATE_COPY == state and not self.btn_copy.new_copy:isVisible() then
		self.cid = TimerMgr.startTimer(callfunc, 1)
	elseif not (BackButton.STATE_COPY == state) then
		if self.cid then
			TimerMgr.killTimer(self.cid)
			self.cid = nil
		end
	end
end

function MainSceneUI:addListenerHandler()
    local layer = SceneMgr.getLayer(SceneMgr.LAYER_MAX)
    if not self.listener then
    	local function touchFunc()
    		-- LogMgr.debug("点击主场景...")
    		self.time_count = 0
			performWithDelay(self, function() self:showNewCopyOpen() end, 0.3)
    	end
        listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(touchFunc, cc.Handler.EVENT_TOUCH_BEGAN)
        listener:registerScriptHandler(touchFunc, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(touchFunc, cc.Handler.EVENT_TOUCH_ENDED)
        listener:registerScriptHandler(touchFunc, cc.Handler.EVENT_TOUCH_CANCELLED)
        self.listener = listener
        local eventDispatcher = layer:getEventDispatcher()    
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, layer)
        self.eventDispatcher = eventDispatcher
    end

end

function MainSceneUI:onShow()
	debug.showTime("MainSceneUI_1_")
	self:init()
	debug.showTime("MainSceneUI_1_")
--	local role_name = self.con_head.txt_name:getVirtualRenderer()
--    role_name:enableOutline(cc.c4b(255, 240, 0, 255), 2)
--    role_name:enableGlow(cc.c4b(0, 0, 0, 255))
	EventMgr.addList(self.event_list)
	--调用各子UI的updateData方法
	debug.showTime("MainSceneUI_2_")
	self.con_top:showAll()
	self.con_top:updateData()
	self.con_head:updateName()
	debug.showTime("MainSceneUI_2_")
	debug.showTime("MainSceneUI_3_")
	UICommon.showSubUI(self.con_head, 2)
	UICommon.showSubUI(self.con_top, 2)
	UICommon.showSubUI(self.con_sign, 2)
	UICommon.showSubUI(self.con_btnGroup, 8)
	UICommon.showSubUI(self.con_group, 6)
    UICommon.showSubUI(self.mainchat, 8)
    UICommon.showSubUI(self.paomaui, 9)
    debug.showTime("MainSceneUI_3_")
    debug.showTime("MainSceneUI_4_")
	MainUIMgr.checkChatShow(self.mainchat)
    debug.showTime("MainSceneUI_4_")
    debug.showTime("MainSceneUI_5_")
    if self.paomaui ~= nil then 
        self.paomaui:onShow(self.mainchat)
    end 
    debug.showTime("MainSceneUI_5_")
    local function callback()
    	-- local copy_id = CopyData.getNextCopyId()
    	-- local area_id = math.floor(copy_id / 1000)
    	-- if CopyData.checkOpenArea(area_id) == false then area_id = area_id - 1 end
     --    Command.run( 'NCopyUI show', area_id, const.kCopyMopupTypeNormal)
    	Command.run("NCopyUI show default")
    end
    BackButton:pushCopy(self, callback)

    -- 新副本开启逻辑
    self:addListenerHandler()
    local btn_copy = BackButton:getButtonByState(BackButton.STATE_COPY)
    btn_copy.new_copy:setVisible(false)
    self.btn_copy = btn_copy -- 获取副本按钮对象
    local up = cc.MoveBy:create(1, cc.p(0, 10))
    local down = up:reverse()
    local sq = cc.Sequence:create(up, down)
    btn_copy.new_copy:runAction(cc.RepeatForever:create(sq))

    local function callfunc()
		local state = BackButton:getCurrState()
    	if BackButton.STATE_COPY == state and not btn_copy.new_copy:isVisible() then
    		btn_copy.new_copy:setVisible(true)
    		if self.cid then
    			TimerMgr.killTimer(self.cid)
    			self.cid = nil
    		end
    	end
    end
    Command.bind("new copy open", callfunc)

    self.showPaomaUI = function(flag)
       if self.paomaui ~= nil and self.paomaui.setVisible ~= nil then 
          self.paomaui:setVisible(flag)
       end 
       self.paomaui:setPositionX(366)
    end 
    EventMgr.addListener(EventType.PaomaEvent, self.showPaomaUI)  
    
end

function MainSceneUI:onClose()
	EventMgr.removeList(self.event_list)
    if self.listener then
        self.eventDispatcher:removeEventListener(self.listener)
        self.listener = nil
        self.eventDispatcher = nil
    end
    self.btn_copy.new_copy:stopAllActions()
    self.btn_copy.new_copy:setPosition(cc.p(89, 160))

	if self.cid then TimerMgr.killTimer(self.cid) self.cid = nil end
	TimerMgr.killTimer(self.tid)
	self.tid = nil
    if self.mainchat ~= nil then 
        self.mainchat:onClose()
    end 
    if self.paomaui ~= nil then 
        self.paomaui:onClose()
    end 
	self:removeChild(self.con_head)
	self:removeChild(self.con_top)
	self:removeChild(self.con_sign)
	self:removeChild(self.con_group)
	self:removeChild(self.con_btnGroup)
    self:removeChild(self.mainchat)
    self:removeChild(self.paomaui)
    EventMgr.removeListener(EventType.PaomaEvent, self.showPaomaUI)  
    BackButton:pop(self)
end

-- 创建 [主界面]
function MainSceneUI:create()
	return MainSceneUI:new()
end

function MainSceneUI:init()
	-- 设置部分对象的位置
	local dis = 10
	
	if self.con_head and self.con_head:getParent() then self.con_head:removeFromParent() end
	self.con_head:setVisible(true)
	self.con_head:setPositionX(dis - 7)
	self.con_head:setPositionY(visibleSize.height - self.con_head:getBoundingBox().height)
	self:addChild(self.con_head)
	
	if self.con_top and self.con_top:getParent() then self.con_top:removeFromParent() end
	self.con_top:setVisible(true)
	self.con_top:setPositionX(visibleSize.width - self.con_top:getBoundingBox().width - dis)
	self.con_top:setPositionY(visibleSize.height - self.con_top:getBoundingBox().height)
	self:addChild(self.con_top)

	if self.con_sign and self.con_sign:getParent() then self.con_sign:removeFromParent() end
	self.con_sign:setPositionX(26)
	self.con_sign:setPositionY(self.con_head:getPositionY() - self.con_sign:getSize().height - 15)
	self:addChild(self.con_sign)

	if self.con_group and self.con_group:getParent() then self.con_group:removeFromParent() end
	self.con_group:setPositionX(visibleSize.width - self.con_group:getBoundingBox().width - dis)
	self.con_group:setPositionY(198)
	-- self.con_group:setPositionY(visibleSize.height / 2 - self.con_group:getBoundingBox() .height / 2 + 30)
	self:addChild(self.con_group)

	if self.con_btnGroup and self.con_btnGroup:getParent() then self.con_btnGroup:removeFromParent() end
	-- self.con_btnGroup:setPositionX(visibleSize.width - self.con_btnGroup:getBoundingBox().width - 20)
	self.con_btnGroup:setPositionY(dis - 8)
	self:addChild(self.con_btnGroup)

    self.mainchat:setPositionX(160)
    -- self.mainchat:setPositionY(dis)
    self:addChild(self.mainchat, 1000)

    self:addChild(self.paomaui, 1000)
    self.paomaui:setPositionX(366)
    self.paomaui:init()
	-- btn_chat:setPositionY(visibleSize.height / 2)
	-- self:addChild(btn_chat)

	-- 注册点击事件
	-- local function showChatHandler(ref, eventType)
 --        if MainSceneUI.chatFlag == false then 
 --        	LogMgr.log( 'debug',"MainSceneUI.chatFlag:false" )
 --        	MainSceneUI.chatFlag = true
	-- 	    local chatUI = PopMgr.popUpWindow("ChatUI")
	--     end
	-- end
 --    UIMgr.addTouchEnded( btn_chat, showChatHandler )
end
