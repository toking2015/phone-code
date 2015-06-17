-- create by Live --
-- 定时器事件管理
TimerMgr = TimerMgr or {}

local frameMap = {}
local releaseMap = {} --下一帧释放的对象
local lastHour = nil
local main_timer_id = nil
local funList = {}

--下一帧释放，应对文本事件内存泄露的问题
function TimerMgr.releaseLater(ref)
	ref:release()
end

---延迟调用
function TimerMgr.callLater(fun, delay)
	local id = nil
	local function callback()
		TimerMgr.killTimer(id)
		fun()
	end
	id = TimerMgr.startTimer(callback, delay, false)
	return id
end

--如果要跟窗口的销毁自动销毁runNextFrame，使用performNextFrame
function TimerMgr.runNextFrame(call, ...)
    local time_id = 0
    local args = {...}
    local function time_call()
        TimerMgr.killTimer(time_id)
        call(unpack(args))
    end
    time_id = TimerMgr.startTimer(time_call, 0)
    return time_id
end

---每一帧调用函数
--【注意】需要手动调用killPerFrame(fun)释放定时器
--@param fun 回调函数
---
function TimerMgr.callPerFrame(fun)
	if (not frameMap[fun]) then
		local id = TimerMgr.startTimer(fun, 0, false)
		frameMap[fun] = id
	end
end

---释放每帧调用的函数
--@param fun 关联的回调函数
---
function TimerMgr.killPerFrame(fun)
	local id = frameMap[fun]
	if id then
		TimerMgr.killTimer(id)
		frameMap[fun] = nil
	end
end

---启动定时器，并返回定时器id
--【注意】关闭窗口的时候，需要手动调用killTimer
--@param fun 回调函数
--@param interval 间隔（秒）
--@param paused 默认直接开始，true则需要手动开始
--@return 返回计时器ID
---
-- local longMap = {}
function TimerMgr.startTimer(fun, interval, paused)
	-- local function doTimer(...)
	-- 	if longMap[fun] then
	-- 		longMap[fun] = nil
	-- 	end
	-- 	debug.resetTime("doTimer")
	-- 	fun(...)
	-- 	if debug.showTime("doTimer") > debug.timeThreshold then
	-- 		longMap[fun] = true
	-- 	end
	-- end
	-- return cc.Director:getInstance():getScheduler():scheduleScriptFunc( doTimer, interval, paused )
	return cc.Director:getInstance():getScheduler():scheduleScriptFunc( fun, interval, paused )
end

---关闭定时器
--@param timer_id 计时器ID
---
function TimerMgr.killTimer(timer_id)
	if timer_id then
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(timer_id)
	end
end

local function doTimer(delay)
	for _, func in pairs(funList) do
		func(delay)
	end
end

function TimerMgr.startMainTimer()
	if not main_timer_id then 
  	    main_timer_id = TimerMgr.startTimer(doTimer, 1)
    end 
end

function TimerMgr.addTimeFun(key, func)
	funList[key] = func
end

function TimerMgr.removeTimeFun(key)
	funList[key] = nil
end

local function hourEventFun()
    if not gameData or not gameData.time or gameData.time.server_time == 0 then
		return
	end
	
	local date = gameData.getServerDate()
	if date.hour ~= lastHour then
		lastHour = date.hour
		if date.min <= 1 then
			EventMgr.dispatch(EventType.hour, lastHour)
		end
	end
end

TimerMgr.startMainTimer()
TimerMgr.startTimer(hourEventFun, 30)
