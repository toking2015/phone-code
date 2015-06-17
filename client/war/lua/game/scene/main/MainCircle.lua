-- Create By Live --

require "lua/game/scene/main/MainPage.lua"
require "lua/game/scene/main/MainBG.lua"
require "lua/game/scene/main/BuilderLayer.lua"

local PI = 3.1415926
local P_PI = PI / 180

-- 判断是否能旋转
local function isRotation(page, disX)
	local level = gameData.user.simple.team_level
	local nextPage = 1
	if disX < 0 then
		nextPage = PageData.getNextPage(page)
	else
		nextPage = PageData.getPrevPage(page)
	end
	-- 获取页面开启条件
	local value = PageData.getPageOpen(nextPage)
	if value.type == 1 then
        if level >= value.data then
    		return true
    	end
	elseif value.type == 2 then
        local id = CopyData.getMaxPassCopy()
        if id >= value.data then
            return true
        end
	end
	return false
end

MainCircle = class("MainCircle", function()
	return Node:create()
end)
function MainCircle:ctor()
	self.isTouch = false
	self.angle = 45

	self.preload = {}

	self.toAngle = 0
	self.preAngle = 0

	self.isTurn = false

	self.skyLayer = nil
	self.earthLayer = nil
	self.builderLayer = nil
	
	self.bubbleLayer = nil
	self.minebubble = nil 

	self.isMoved = false
	self.listener = nil
	
    self.holynum = 1   --保证holy气泡只生成一次
    self.minenum = 1   --保证mine气泡只生成一次
end
-- 通过角度获取当前页下标
function MainCircle:getPageBy(angle)
	local page = math.floor(((360 - angle) % 360) / 45 + 1)
	return page
end
-- 获取当前页下标
function MainCircle:getPageIndex()
	local pageIndex = self:getPageBy(self.toAngle) --math.floor(((360 - self.toAngle) % 360) / 45 + 1)
	return pageIndex
end

function MainCircle:initCircle()
	-- 不必调整坐标，因为在生成时已经调整
	self.skyLayer = MainBGLayer:create()
	self:addChild(self.skyLayer, 0)

	-- 获取当前页下标，设置前一次页面的角度，设置当前页的角度
    local pageIndex = PageData.getCurrPage()
    -- pageIndex = 1
    self.preAngle = (pageIndex - 1) * -45
    self.toAngle = self.preAngle

	-- 初始化Command
	self:initCommand()
	-- 添加 建筑物的气泡层
    Command.run('bubble show')
    -- 生成建筑层
	self.builderLayer = BuilderLayer:create(pageIndex)
	self:addChild(self.builderLayer, 2)
	-- 生成地面层
	self.earthLayer = MainPage:create(pageIndex)
	self:addChild(self.earthLayer, 1)
	-- 初始化点击事件
	self:configTouchEvent()

	-- 设置建筑物的红点位置
	local card = { page = 1, id = 1004, callback = CardData.Free}
	-- local trial = { page = 8, id = 8003, callback = TrialMgr.isRedPoint, x = 260, y = 400}
	-- local arena = { page = 8, id = 8004, callback = ArenaData.isRedPoint, x = 470, y = 490}
	local trial = { page = 8, id = 8003, callback = TrialMgr.isRedPoint, x = -1239, y = 804}
	local arena = { page = 8, id = 8004, callback = ArenaData.isRedPoint, x = -1155, y = 1016}
	Command.run('set redPoint', card)
	Command.run('set redPoint', trial)
	Command.run('set redPoint', arena)

end
-- 初始化Command方法
function MainCircle:initCommand()
	Command.bind("cmd main turn", function(angle)
        -- local curAngle = (PageData.getCurrPage() - 1) * 45 + angle
		-- circle:preloadPage(angle)
        self:doRotate(0.5, angle)
	end)
	-- 设置红点
	local function setRedPoint(obj)
		PageData.addRedPointData(obj)
	end
	Command.bind('set redPoint', function(obj) 
		setRedPoint(obj) 
	end)
	-- 添加气泡
    local function showBubbleLayer()
        if self.holynum == 1 and BuildingData.checkBuildingExist(const.kBuildingTypeWaterFactory) then
			self.bubbleLayer = HolyBubble:createHolyBubble()
			self.bubbleLayer:retain()
	    	local obj = {page = 1, id = 1005, icon = self.bubbleLayer, x = -45, y = 130}
	    	PageData.addBubbleIcon(obj)
            self.holynum = self.holynum + 1
	    end

        if self.minenum == 1 and (BuildingData.getDataByType(const.kBuildingTypeGoldField)) then
			self.minebubble = MineBubble:createMineBubble() 
			self.minebubble:retain()
	  	    local obj = {page = 1, id = 1006, icon = self.minebubble, x = -40, y = 130}
		    PageData.addBubbleIcon(obj)
            self.minenum = self.minenum + 1
	    end
    end
    Command.bind('bubble show', showBubbleLayer)
    -- 收集圣水
    Command.bind('holy collect', function() 
    		if nil ~= self.bubbleLayer then
    			self.bubbleLayer:collectHolyAction()
    		end
    	end)
    -- 收集金矿
    Command.bind("mine collect", function()
        if self.minebubble ~= nil then
            self.minebubble:getCoinAction()
        end
    end)
    -- 显示建筑层所有建筑物
	local function showAll()
		self.builderLayer:showAll()
		self.earthLayer:refresh()
	end
	Command.bind("BuilderLayer showAll", showAll)
	-- 转到第一页
	local function turnToHomePage()
		self:jumpToPage(1)
	end
	Command.bind("ShowHomePage", turnToHomePage)
	-- 调转到该建筑物（先跳转页面）
	local function turnToBuilding(id, callback)
	    local bd = findBuilding(id)
		local icon = bd.icon
		local page = BuildingData.getPageById(id)
		local currPage = PageData.getCurrPage()
	    local function turnPageFinish()
	    	EventMgr.removeListener(EventType.ScenePage, turnPageFinish)
		    if nil ~= callback then
		    	callback()
		    end
	    end
		if currPage ~= page then
			local delta = math.abs(currPage - page)
			if delta == 1 or delta == 7 then
		    	EventMgr.addListener(EventType.ScenePage, turnPageFinish)
				self:doRotate(0.25 * math.abs(page - currPage), (page - 1) * -45)
			else
				self:jumpToPage(page)
				self.builderLayer:setBuildingVisible(page, icon, false)
				turnPageFinish()
			end
		else
			turnPageFinish()
		end
	end
	Command.bind('cmd turnto building', turnToBuilding)
end
-- 跳转页下标 page为页面下标
function MainCircle:jumpToPage(page)
    self.isTurn = false
    self.toAngle = 0
    PageData.setCurrPage(page)
    self.builderLayer:jumpToPage(page)
    self.earthLayer:jumpToPage(page)
    EventMgr.dispatch( EventType.ScenePage, page ) --跳转的也需要派发事件
end
-- 执行旋转， t为选择时间，a为转向的角度
function MainCircle:doRotate(t, a)
	-- if self.isTurn then return end
	self.isTurn = true

	self.toAngle = a
	local rotate = cc.RotateTo:create(t, a)

	local function rotateDoneCallback()
		self.preload = {}
		self.isTurn = false
		
		local pageIndex = self:getPageIndex()
		PageData.setCurrPage(pageIndex)
		self.builderLayer:turnTo(pageIndex)
		self.earthLayer:turnTo(pageIndex)

		EventMgr.dispatch( EventType.ScenePage, pageIndex )
	end
	local rotateDone = cc.CallFunc:create(rotateDoneCallback, {})
	
	local seq = cc.Sequence:create(rotate, rotateDone)
	self.earthLayer:runAction(seq)

	local rotateTo = cc.RotateTo:create(t, a)
	self.builderLayer:runAction(rotateTo)
	SoundMgr.playEffect("sound/ui/sfx_roll.mp3")
end
-- 转动，默认时间为0.5，a为转向的角度
function MainCircle:turnTo(a)
	if true == self.isMoved then
		self:doRotate(0.5, a)
	end
end
-- 向左转动一页
function MainCircle:turnLeft()
	local toAngles = self.earthLayer:getRotation() + self.angle
	self:doRotate(1, toAngles)
end
-- 向右转动一页
function MainCircle:turnRight()
	local toAngles = self.earthLayer:getRotation() - self.angle
	self:doRotate(1, toAngles)
end
-- 是否点击到建筑物，touchPoint为点击位置
function MainCircle:isClickBuilding(touchPoint)
    -- if true then return nil end - PageInfo.radius, - PageInfo.radius
    local cp = self.earthLayer:convertToNodeSpace(touchPoint)
    cp.x, cp.y = cp.x + PageInfo.radius, cp.y + PageInfo.radius
    local pageIndex = self:getPageIndex()
    local list = self.builderLayer:getBuilderList(pageIndex)
    -- local list = PageData.getClickList(pageIndex)
    local builder = nil
	local row = math.floor((3500 - cp.y) / 50)
	local col = math.floor(cp.x / 50)
	local key = row .. "_" .. col
    for k, v in pairs(list) do
        if v.isClick == true then
        	for _, pos in pairs(v.data.area) do
        		if pos == key then
        			return v
        		end
        	end
    	end
    end
    return builder
end
-- 注册点击事件
function MainCircle:configTouchEvent()
	local preTouchPoint = cc.p(0, 0) 	-- 上次点击位置
	local maxTouchX = 0 				-- 左右移动的最左或最右X坐标
	local clickBuilder = nil 			-- 当前点击到的建筑

	local function onTouchBegan(touch, event)
		-- 当前还在触摸 或 已经转动时，点击无效
		if self.isTouch == true then return false end
		if self.isTurn then return false end

		self.isTouch = true

		preTouchPoint = touch:getLocation()
		self.preAngle = self.toAngle

		local builder = self:isClickBuilding(preTouchPoint)
		if nil ~= builder and builder.clickBuilderBegan then
			clickBuilder = builder
			builder:clickBuilderBegan()
			builder = nil
            --self.builderLayer:clickBuilderBegan(builder)
		end

		return true
	end
	local function onTouchMoved(touch, event)
		if self.isTurn then return end -- 若已经转动，无效
		
		local touchPoint = touch:getLocation()
		local preLen = maxTouchX - preTouchPoint.x
		local len = touchPoint.x - preTouchPoint.x
		-- 设置maxTouchX值，判断此次触摸是否是 最左值 或 最右值
		if maxTouchX == 0 then 
			maxTouchX = touchPoint.x 
		elseif preLen * len > 0 then
			if len > 0 then maxTouchX = math.max(maxTouchX, touchPoint.x)
			else
				maxTouchX = math.min(maxTouchX, touchPoint.x)
			end
		else
			if len ~= 0 then
				maxTouchX = touchPoint.x
			end
		end

		-- 此处两次点击的距离>10，不是>0，是由于有些手机即使你不移动，它也默认你距离>0
		local pLen = cc.pGetDistance(preTouchPoint, touchPoint)
		if pLen > 10 then
			self.isMoved = true
			local disX = touchPoint.x - preTouchPoint.x
			local addAngle = disX * self.angle / visibleSize.width
			if isRotation(self.earthLayer.currPage, disX) == true then
				self.earthLayer:setRotation(self.preAngle + addAngle)
				self.builderLayer:setRotation(self.preAngle + addAngle)
			else
				-- 不能旋转时，只可以旋转5度
				if math.abs(addAngle) < 5 then
					self.earthLayer:setRotation(self.preAngle + addAngle)
					self.builderLayer:setRotation(self.preAngle + addAngle)
				end
			end
		end
	end
	local function onTouchEnded(touch, event)
		if self.isTurn then return end  -- 若已经转动，无效
		
		local touchPoint = touch:getLocation()
		local disX = touchPoint.x - preTouchPoint.x

		if isRotation(self.earthLayer.currPage, disX) == true then
			-- 当移动的X大于1/10屏幕宽，并且与上次最左或最右值小于100时，可旋转到下一页
			if math.abs(disX) > visibleSize.width / 10 and math.abs(touchPoint.x - maxTouchX) <= 100 then
				local curAngle = self.preAngle + (disX > 0 and 1 or -1) * self.angle
				curAngle = math.floor(360 + curAngle) % 360
				self:turnTo(curAngle)
			else
				self:turnTo(self.preAngle)
				-- LoadMgr.clearAsyncCache()
			end 
		else
			self:turnTo(self.preAngle)
		end
		-- 判断是否点击到建筑，若有执行建筑物触发方法
		local builder = clickBuilder
		if nil ~= builder and builder.clickBuilderEnded then
			builder:clickBuilderEnded(false == self.isMoved)
			builder = nil
            -- self.builderLayer:clickBuilderEnded(builder, false == self.isMoved)
		end
		-- 重新设置值
		clickBuilder = nil
		preTouchPoint = cc.p(0, 0)
		self.preAngle = 0
		maxTouchX = 0
		self.isMoved = false
		self.isTouch = false
	end
	local function onTouchCancel(touch, event)
		local builder = clickBuilder
		if nil ~= builder and self.builderLayer and self.builderLayer.doScaleBuilding then
			self.builderLayer:doScaleBuilding(builder, false)
		end
		self.isTouch = false
	end
	
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	listener:registerScriptHandler(onTouchCancel, cc.Handler.EVENT_TOUCH_CANCELLED)
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self)

	self.listener = listener
end
-- 预加载页面，暂时已废弃~~~
function MainCircle:preloadPage(curAngle)
	curAngle = math.floor(360 + curAngle) % 360
	local page = self:getPageBy(curAngle)
	if self.preload[page] ~= true then
		self.preload[page] = true
		-- self.builderLayer:preloadPageView(page)
	end
end

function MainCircle:create()
	local circle = MainCircle:new()
	circle:initCircle()
	
	return circle
end
function MainCircle:dispose()
	local eventDispatcher = self:getEventDispatcher()
	eventDispatcher:removeEventListener(self.listener)

    TimerMgr.removeTimeFun(getMineData.key)
    TimerMgr.removeTimeFun(BubbleLayer.key)

	self.skyLayer:dispose()
	self:removeChild(self.skyLayer)
	self.skyLayer = nil

    self.earthLayer:dispose()
	self:removeChild(self.earthLayer)
	self.earthLayer = nil

	self.builderLayer:dispose()
	self:removeChild(self.builderLayer)
	self.builderLayer= nil

	if nil ~= self.bubbleLayer then
		self.bubbleLayer:dispose()
		self.bubbleLayer:release()
		self.bubbleLayer = nil
	end
	if nil ~= self.minebubble then
		self.minebubble:dispose()
		self.minebubble:release()
		self.minebubble = nil
	end
	

	PageData.clearBubble()

    -- TimerMgr.removeTimeFun("state")
end

function MainCircle:getSkyLayer()
	return self.skyLayer
end
function MainCircle:getEarthLayer()
	return self.earthLayer
end
function MainCircle:getBuilderLayer()
	return self.builderLayer
end