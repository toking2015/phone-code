-- Create By Live --
-- 主场景状态管理 --
-- 当前只有白天状态 --
-- 当前只有三种天气状态：NONE，RAIN（下雨），SNOW（下雪）

World = {
	DAY = 1,
	NIGHT = 2
}

Weather = {
	NONE = 1,
	RAIN = 2,
	SNOW = 3
}


MainState = {
	mainLayer = nil, -- 主场景的Circle层
	skyLayer = nil,  -- 主场景的Circle中的skyLayer层

	state = World.DAY,
	weather = Weather.NONE,

	particle = nil, -- 当前播放粒子对象

	currGround = 0, -- 已废弃
	toGround = 0, --已废弃
	currSky = 255, -- 当前skyLayer透明度
	toSky = 255, -- 要转变的skyLayer透明度

	pass = 0, -- 转变天气后到当前所经过的时间

	skyId = 0, -- skyLayer的定时器id
	stateId = 0, -- 天气状态的定时器id
	rainId = 0, -- 下雨的定时器id
	snowId = 0, -- 下雪的定时器id

	value = 1 -- 决定当前天气状态的值
}

function MainState:init(main)
	self:setMain(main)
	
    local function changeWeather()
        local num = math.random(0, 10)

        local function stopRain()
            TimerMgr.killTimer(self.rainId)
            self:removeRain()
        end
        local function stopSnow()
            TimerMgr.killTimer(self.snowId)
            self:removeSnow()
        end

        if num % 3 == 2 then
            LogMgr.log( 'debug',">>>>>Rain>>>>>")
            self:showRain()
            local duration = math.random(60, 120)
            self.rainId = TimerMgr.startTimer(stopRain, duration, false)
        elseif num % 3 == 0 then
            LogMgr.log( 'debug',">>>>>Snow>>>>>")
            self:showSnow()
            local duration = math.random(60, 120)
            self.snowId = TimerMgr.startTimer(stopSnow, duration, false)
        else
            LogMgr.log( 'debug',">>>>>Day>>>>>")
        end
    end
--    Command.bind('weather change', changeWeather)

	local function callback()
		TimerMgr.killTimer(self.skyId)
		if self.value == 1 then
			self:showRain()
		elseif self.value == 2 then
			self:removeRain()
		elseif self.value == 3 then
		    self:showSnow()
		elseif self.value == 4 then
            self:removeSnow()
		end
		self.value = self.value + 1
		if self.value > 4 then
			self.value = 1
		end
	end

	EventMgr.addListener(EventType.ChangeMainState, callback)

    -- changeWeather()
    self.stateId = TimerMgr.startTimer(changeWeather, 300, false)
end

function MainState:setMain(main)
	self.mainLayer = main
	self.skyLayer = main:getSkyLayer()
end

function MainState:showRain()
	self:showWeather("rain.plist")
	self.sound_id = SoundMgr.playEffect("sound/ui/ambience_rain.mp3")
	if self.state == World.DAY then
		local currSky = self.skyLayer:getSkyOpacity()
		self:chnState(nil, nil, currSky, 120)
	end
end
function MainState:removeRain()
	self:removeWeather()
	if self.state == World.DAY then
		local currSky = self.skyLayer:getSkyOpacity()
		self:chnState(nil, nil, currSky, 255)
	end
end

function MainState:showSnow()
	do
		return --TASK #6384::【手游】主场景下雪的特效
	end
	self:showWeather("snow.plist", 815, 528)
	
	if self.state == World.DAY then
	    local currSky = self.skyLayer:getSkyOpacity()
	    self:chnState(nil, nil, currSky, 120)
	end
end
function MainState:removeSnow()
    self:removeWeather()
    if self.state == World.DAY then
        local currSky = self.skyLayer:getSkyOpacity()
        self:chnState(nil, nil, currSky, 255)
    end
end

-- 显示天气特效
function MainState:showWeather(plist, x, y)
	self:removeWeather()
	if x == nil and y == nil then
	   self.particle = Particle:create(plist, visibleSize.width / 2, visibleSize.height)
	else
        self.particle = Particle:create(plist, x, y)
	end
	self.mainLayer:addChild(self.particle, 20)
end

-- 移除天气特效
function MainState:removeWeather()
	if nil ~= self.particle then
--		self.mainLayer:removeChild(self.particle)
        self.particle:removeFromParent()
		self.particle = nil
		self.sound_id = SoundMgr.stopEffect(self.sound_id)
	end
end

function MainState:chnState(_currGround, _toGround, _currSky, _toSky)
	local pass = 0
	local currGround = _currGround
	local toGround = _toGround
	local currSky = _currSky
	local toSky = _toSky

	function tick(delay)
		pass = pass + delay

		local sky = 0
		if currSky ~= nil and toSky ~= sky then
			if toSky ~= currSky then
				sky = currSky + (toSky - currSky) * pass
				if (sky >= toSky and toSky > currSky) or (sky <= toSky and toSky < currSky) then
					sky = toSky
				end
				self.skyLayer:chnOpacity(sky)
			end
		end
		if pass >= 1 then
			TimerMgr.killTimer(self.skyId)
		end
	end

	self.skyId = TimerMgr.startTimer(tick, 0, false)
end

function MainState:stopChanging()
    TimerMgr.killTimer(self.rainId)
    TimerMgr.killTimer(self.snowId)
	TimerMgr.killTimer(self.skyId)
	TimerMgr.killTimer(self.stateId)
end

function MainState:dispose()
	LogMgr.log( 'debug',"MainState dispose ...... ")
    TimerMgr.killTimer(self.rainId)
    TimerMgr.killTimer(self.snowId)
	TimerMgr.killTimer(self.skyId)
	TimerMgr.killTimer(self.stateId)
	self:removeWeather()
end