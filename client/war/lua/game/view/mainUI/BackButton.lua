local __this = BackButton or cc.Node:create()
BackButton = __this

__this.STATE_NONE = 0
__this.STATE_HOME = 1
__this.STATE_BACK = 2
__this.STATE_COPY = 3

function __this:init()
	self:retain() --不准释放
	self.btnList = {}
	self.stateList = {{state=self.STATE_NONE}} -- {state=state, cls=cls, callback=callback}
	self.curState = self.stateList[1]
	function self.clickHandler()
		ActionMgr.save( 'UI', '[BackButton] click [btn]' )
		if self.curState.callback then
			self.curState.callback()
			EventMgr.dispatch( EventType.BackButtonClick, self.curState.state )
		end
	end
end

function __this:clear()
	for i = #self.stateList, 2, -1 do
		table.remove(self.stateList, i)
	end
	for _,btn in pairs(self.btnList) do
		btn:stopAllActions()
		btn:setPosition(cc.p(-120, 10))
	end
	self.curState = self.stateList[1]
end

--添加返回按钮
--cls 类实例
--callback 如阻止退出则返回true
function __this:pushBack(cls, callback, index)
	self:addState(self.STATE_BACK, cls, callback, index)
end

--添加主页按钮
function __this:pushHome(cls, callback)
	-- TASK #7209::【手游】取消炉石按钮
	-- self:addState(self.STATE_HOME, cls, callback)
end

-- 添加副本按钮
function __this:pushCopy(cls, callback)
	self:addState(self.STATE_COPY, cls, callback)
end

function __this:pushNone(cls)
	self:addState(self.STATE_NONE, cls)
end

function __this:pop(cls)
	if self.curState.cls == cls then
		table.remove(self.stateList)
		self:updateData()
	else
		--如果不在最上层，直接移除就可以了
		for i = #self.stateList - 1, 2, -1 do
			if cls == self.stateList[i].cls then
				table.remove(self.stateList, i)
				break
			end
		end
	end
end

function __this:getButtonByState(state)
	local btn = self.btnList[state]
	if not btn and state ~= self.STATE_NONE then
		if state == self.STATE_HOME then
			btn = self:createHomeBtn()
		elseif state == self.STATE_BACK then
			btn = self:createBackBtn()
		elseif state == self.STATE_COPY then
			btn = self:createCopyBtn()
		end
		btn:setPosition(cc.p(-120, 10))
		self:addChild(btn, state)
		btn:addTouchEnded(self.clickHandler)
		self.btnList[state] = btn
	end
	return btn
end

function __this:addState(state, cls, callback, index)
	if self.curState.cls ~= cls then
		if index then
			table.insert(self.stateList, index, {state=state, cls=cls, callback=callback})
		else
			table.insert(self.stateList, {state=state, cls=cls, callback=callback})
		end
		self:updateData()
	end
end

function __this:updateData()
	local btn1 = self:getButtonByState(self.curState.state)
	self.curState = self.stateList[#self.stateList]
	local btn2 = self:getButtonByState(self.curState.state)
	if btn1 == btn2 then --同一个按钮，不播放切换动画
		return
	end
	local delay = 0
	if btn1 then
		delay = 0.2
		btn1:setEnabled(false)
		btn1:stopAllActions()
		local action = cc.EaseBackIn:create(cc.MoveTo:create(delay, cc.p(-120, 10)))
		local callback = cc.CallFunc:create(function()
			if btn1.new_copy then
				btn1.new_copy:setVisible(self.curState.state == __this.STATE_COPY)
			end
		end)
		btn1:runAction(cc.Sequence:create(action, callback))
	end
	if btn2 then
		local action = cc.EaseBackOut:create(cc.MoveTo:create(0.2, cc.p(10, 10)))
		if delay ~= 0 then
			action = cc.Sequence:create(cc.DelayTime:create(delay), action)
		end
		btn2:setEnabled(true)
		btn2:stopAllActions()
		btn2:runAction(action)
	end
end

--退出按钮
function __this:createBackBtn()
	__this.btn = ccui.Layout:create()
	local bg = ccui.ImageView:create("btn_back_new.png", ccui.TextureResType.plistType)
	bg:setTouchEnabled(false)
	__this.btn:addChild(bg)
	bg:setPosition(cc.p(44, 47))
	__this.btn:setTouchEnabled(true)
	__this.btn:setSize(cc.size(90, 100))
	createScaleButton(__this.btn)
	return __this.btn
end

function __this:createHomeBtn()
    self.btn_main = ccui.Layout:create()
    self.btn_main:setSize(cc.size(90, 100))
    self.btn_main:setAnchorPoint(0, 0)
    self.btn_main:setTouchEnabled(true)

    local img_title_bg = ccui.ImageView:create("bottom_icon1.png", ccui.TextureResType.plistType)
    img_title_bg:setPosition(cc.p(45, 18))
    self.btn_main:addChild(img_title_bg)

    local img_title = ccui.ImageView:create("main_txt_main.png", ccui.TextureResType.plistType)
    img_title:setPosition(cc.p(44, 18))
    self.btn_main:addChild(img_title)

    local img_icon = ccui.ImageView:create("main_index.png", ccui.TextureResType.plistType)
    img_icon:setPosition(cc.p(44, 65))
    self.btn_main:addChild(img_icon)

    img_title_bg:setTouchEnabled(false)
    img_title:setTouchEnabled(false)
    img_icon:setTouchEnabled(false)

    createScaleButton(self.btn_main)
    return self.btn_main
end

function __this:createCopyBtn()
    self.btn_main = ccui.Layout:create()
    self.btn_main:setSize(cc.size(90, 100))
    self.btn_main:setAnchorPoint(0, 0)
    self.btn_main:setTouchEnabled(true)
    local img_icon = ccui.ImageView:create("image/mainPage/icon_copy.png", ccui.TextureResType.localType)
    img_icon:setPosition(cc.p(44, 47))
    self.btn_main:addChild(img_icon)
    img_icon:setTouchEnabled(false)
    createScaleButton(self.btn_main)

    local new_copy = ccui.ImageView:create("image/mainPage/new_copy_open.png", ccui.TextureResType.localType)
    new_copy:setPosition(cc.p(89, 160))
    self.btn_main:addChild(new_copy)
    new_copy:setTouchEnabled(false)
    self.btn_main.new_copy = new_copy

    return self.btn_main
end

function __this:getCurrState()
	return self.curState.state
end

function __this:isBackActionCom()
	return self.btn:getPositionX() == 10
end

function __this:isHomeActionCom()
	return self.btn_main:getPositionX() == 10
end

local function onSceneClose(event)
--	__this:clear()
end

EventMgr.addListener(EventType.SceneClose, onSceneClose)
