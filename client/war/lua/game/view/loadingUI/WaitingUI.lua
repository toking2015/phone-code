WaitingUI = createUIClassEx('WaitingUI', cc.Layer)

function WaitingUI:ctor()
	self.bgLayer = UIFactory.getLayerColor(cc.c4b(0x00, 0x00, 0x00, 0x20), visibleSize.width, visibleSize.height, self)
	self.bgLayer:setTouchEnabled(true)
	local function touchHandler(touch, event)
	end
	UIMgr.addTouchBegin(self.bgLayer, touchHandler) --屏蔽点击事件

	function self.addArmature()
		if not self.armature then
			local path = 'image/armature/ui/loading/'
			local armature = ArmatureSprite:addArmatureEx(path, "loading", self.winName, self)
			armature:setPosition(visibleSize.width / 2 - 200, visibleSize.height /2 + 210)
			self.armature = armature
		end
	end
end

function WaitingUI:onShow(delay)
	if delay then
		performWithDelay(self, self.addArmature, delay)
	else
		self.addArmature()
	end
end

function WaitingUI:onClose()
	if self.armature then
		self.armature:removeFromParent()
		self.armature = nil
	end
end

DisconnectUI = createUIClassEx('DisconnectUI', cc.Layer)

function DisconnectUI:ctor()
	self.bgLayer = UIFactory.getLayerColor(cc.c4b(0x00, 0x00, 0x00, 0x80), visibleSize.width, visibleSize.height, self)
	self.bgLayer:setTouchEnabled(true)
	local function touchHandler(touch, event)
	end
	UIMgr.addTouchBegin(self.bgLayer, touchHandler) --屏蔽点击事件

	self.bg = UIFactory.getSprite("image/ui/LoadingUI/wait.png", self, visibleSize.width / 2, visibleSize.height / 2)

	self.txt = UIFactory.getLabel("连接中...", self, 0, 0, 24, cc.c3b(0xff, 0xff, 0xff))
	self.txt:setAnchorPoint(0, 0.5)
	self.txt:setPosition(visibleSize.width / 2 - 42, visibleSize.height / 2 - 38)

	self.time = 0
	function self.updateText()
		self.time = self.time + 1
		local count = self.time % 3
		local str = '连接中.'
		for i = 1, count do
			str = str..'.'
		end
		self.txt:setString(str)
	end
end

function DisconnectUI:onShow()
	self.time = 0
	if self.timer_id then
		self.timer_id = TimerMgr.killTimer(self.timer_id)
	end
	self.timer_id = TimerMgr.startTimer(self.updateText, 1)
	self.updateText()
	if not self.armature then
		local path = 'image/armature/ui/loading/'
		local armature = ArmatureSprite:addArmatureEx(path, "wait", self.winName, self)
		armature:setPosition(visibleSize.width / 2 - 184, visibleSize.height /2 + 255)
		-- self:addChild(armature)
		self.armature = armature
	end
end

function DisconnectUI:onClose()
	self.timer_id = TimerMgr.killTimer(self.timer_id)
	if self.armature then
		self.armature:removeFromParent()
		self.armature = nil
	end
end
