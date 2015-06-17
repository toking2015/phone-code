-- Create By Live --

-- 包括 DayBG ，NightBG ，MainBGLayer 及 DarkLayer


----------------- DayBg ------------------
DayBG = class("DayBG", function()
	return Node:create()
end)

function DayBG:ctor()
	self.bg = nil
	self.cloud = nil
	self.sid = 0
end

function DayBG:create()
	local bg = DayBG.new()
	bg:setCascadeOpacityEnabled(true)
	local function onNodeEvent(event)
		if "enter" == event then
			bg:init()
       	elseif "exit" == event then
           	bg:unregisterScriptHandler()
           	bg:dispose()
       	end
    end
    bg:registerScriptHandler(onNodeEvent)

	return bg
end

function DayBG:init()
	local path_day = "image/mainPage/background/day.jpg"
	local path_cloud = "image/mainPage/background/cloud.png"

	LoadMgr.loadImage(path_day, LoadMgr.SCENE, "main")
	LoadMgr.loadImage(path_cloud, LoadMgr.SCENE, "main")

	-- 添加背景
	self.bg = Sprite:create(path_day)
	self.bg:setAnchorPoint(0, 0)
	self.bg:setScaleX(gameWidth / self.bg:getContentSize().width)
	self.bg:setPositionY(640 - self.bg:getContentSize().height)
	self:addChild(self.bg)
	-- 添加云朵
	self.cloud = Sprite:create(path_cloud)
	self.cloud:setAnchorPoint(0, 0)
	self.cloud:setPosition(300, 250)
	self:addChild(self.cloud)

	-- 移动云朵
	local function tick(delay)
		local x = self.cloud:getPositionX()
		x = x + 10 * delay
		if x > gameWidth + 100 then
			x = -700
		end
		self.cloud:setPositionX(x)

	end
	self.sid = TimerMgr.startTimer(tick, 0, false)
end

function DayBG:dispose()
	if self.bg then
		self:removeChild(self.bg)
		self.bg = nil
	end

	if self.cloud then
		self:removeChild(self.cloud)
		self.cloud = nil
	end

	TimerMgr.killTimer(self.sid)
end

----------------- MainBGLayer ------------------
MainBGLayer = class("MainBGLayer", function()
	return Node:create()
end)

function MainBGLayer:create()
	local layer = MainBGLayer.new()

	layer.dayBg = nil

	layer:initShowBg()

	return layer
end

function MainBGLayer:getSkyOpacity()
	if nil ~= self.dayBg then
		return self.dayBg:getOpacity()
	end
	return nil
end

function MainBGLayer:chnOpacity(value)
	if nil ~= self.dayBg then
		self.dayBg:setOpacity(value)
	end
end

function MainBGLayer:dispose()
	TimerMgr.removeTimeFun( "state" )
	if nil ~= self.dayBg then
		if nil ~= self.dayBg:getParent() then
			self:removeChild(self.dayBg)
			self.dayBg = nil
		end
	end
end

function MainBGLayer:initShowBg()
	self:showDayBg()
end

function MainBGLayer:showDayBg()
	if self.dayBg == nil then	
		self.dayBg = DayBG:create()
		self:addChild(self.dayBg)
	end
end
