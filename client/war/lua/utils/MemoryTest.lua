--检测内存泄漏
--使用方法
--1. 在local_test.lua添加 MemoryTest.setIsOpen(true)
--2. 在点击按钮的地方调用 MemoryTest.startLog()
--3. 在UI的OnShow完成后调用 MemoryTest.stopLog()
--4. 调用 MemoryTest.showLog() 打印详情
--5. 在Writable/memory.txt 可以查看内存泄露堆栈详情
MemoryTest = MemoryTest or {}

local stepCount = 0
local isOpen = false

function MemoryTest.setIsOpen(value)
	isOpen = value
	if value then
		LogMgr.open("memory")
	else
		LogMgr.close("memory")
	end
end

local function clearLog()
	MemoryTest.logList = {}
	MemoryTest.badUIMap = {}
end

local function recordLog(uiName)
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
    local log = wdebug.get_ccobj_log()
    if #log > 0 then
    	LogMgr.log("memory", uiName .. " .. memory leak count: " .. #log)
    	table.insert(MemoryTest.logList, uiName .. " .. memory leak count: " .. #log)
	    for i = 1, #log do
	    	table.insert(MemoryTest.logList, uiName .. " .. memory leak at - " .. i .. "\n" .. log[i])
	    end
	end
end

local function writeLog()
	local content = ""
	if MemoryTest.logList then
		content = table.concat(MemoryTest.logList, "\n")
		if #MemoryTest.logList > 0 then
			LogMgr.log("memory", content)
		end
	end
	local badContent = ""
	if MemoryTest.badUIMap then
		for k,v in pairs(MemoryTest.badUIMap) do
			badContent = badContent .. string.format("%s: %s\n", k, v)
		end
	end
	content = content .. badContent
	-- content = badContent
	seq.write_stream_file("memory.txt", seq.string_to_stream(content))
end

function MemoryTest.startLog(noClear)
	if not isOpen then
		return
	end
	if not noClear then
		clearLog()
	end
	LogMgr.log("memory", "内存测试——开始记录...")
    wdebug.clear_ccobj_log()
    wdebug.start_ccobj_log()
end

function MemoryTest.stopLog()
	if not isOpen then
		return
	end
	LogMgr.log("memory", "内存测试——停止记录...")
    wdebug.stop_ccobj_log()
end

function MemoryTest.showLog(noRecord)
	if not isOpen then
		return
	end
	LogMgr.log("memory", "内存测试——显示记录...")
	if not noRecord then
		recordLog("内存测试")
	end
	writeLog()
end

local delta = 3 --单个UI的步骤
local function uiStepHandler()
	local uiName = MemoryTest.uiList[math.ceil(MemoryTest.current / delta)]
	if not uiName then
		MemoryTest.timer_id = TimerMgr.killTimer(MemoryTest.timer_id)
		MemoryTest.showLog(true)
		return
	end
	if MemoryTest.current % delta == 0 then -- 显示记录
		recordLog(uiName)
	elseif MemoryTest.current % delta == 1 then --打开UI
		MemoryTest.startLog(true)
		LogMgr.log("memory", "开始测试："..uiName)
		debug.resetTime(uiName)
		PopMgr.popUpWindow(uiName)
		local time = debug.showTime(uiName)
		if time >= 0.25 then
			MemoryTest.badUIMap[uiName] = time
		end
		local win = PopMgr.getWindow(uiName)
		win.onBeforeClose = nil --屏蔽掉不允许关闭的选项
	elseif MemoryTest.current % delta == 2 then -- 关闭UI
		MemoryTest.stopLog()
		PopMgr.removeWindowByName(uiName)
		ModelMgr:releaseUnFormationModel() --释放模型
		LoadMgr.clearAsyncCache()
	end
	MemoryTest.current = MemoryTest.current + 1
end

function MemoryTest.runUITest(uiList)
	if not isOpen then
		return
	end
	MemoryTest.uiList = uiList
	SceneMgr.enterScene("test") --跳转场景
	clearLog()
	MemoryTest.current = 1
	MemoryTest.timer_id = TimerMgr.startTimer(uiStepHandler, 1)
end

local function memorytest_run_ui(uiName)
	local uiList = {}
	if not uiName then
		local dict = PopMgr.getWinCreateDic()
		for k,_ in pairs(dict) do
			table.insert(uiList, k)
		end
	else
		table.insert(uiList, uiName)
	end
	MemoryTest.runUITest(uiList)
end

Command.bind("memorytest_run_ui", memorytest_run_ui)
Command.bind("memory 1", MemoryTest.startLog)
Command.bind("memory 2", MemoryTest.stopLog)
Command.bind("memory 3", MemoryTest.showLog)
Command.bind("speed_test", function(uiName)
	debug.resetTime(uiName)
	PopMgr.popUpWindow(uiName)
	local time = debug.showTime(uiName)
	if time >= 0.25 then
		LogMgr.error("慢：", time)
	else
		LogMgr.error("快：", time)
	end
end)