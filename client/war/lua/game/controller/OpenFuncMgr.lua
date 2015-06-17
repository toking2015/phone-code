OpenFuncMgr = {}
OpenFuncMgr.isOpening = false --是否正在开启

function OpenFuncMgr.clear()
	OpenFuncMgr.isOpening = false
end
OpenFuncMgr.clear()
EventMgr.addListener(EventType.UserLogout, function()
    OpenFuncMgr.clear()
end)

local function checkRunOpen(openData)
	if openData then
		if toint(openData.run_type) == 0 then
			EventMgr.dispatch(EventType.OpenFunc, openData) --派发事件
		else
			local function callback(icon)
				OpenFuncMgr.flyToUI(icon, openData)
			end
			OpenFuncMgr.showFuncOpen(openData.id, callback)
		end
	end
end
local function checkRunOpenList(list)
	for i = 1, #list do
		checkRunOpen(list[i])
	end
end
Command.bind("openfunc checkRunOpen", checkRunOpen)
local function onLevelUp(msg)
	for i = msg.old_level + 1, msg.new_level do
		local list = OpenFuncData.getOpenDataByTerm(OpenFuncData.TERM_LEVEL, i)
		checkRunOpenList(list)
	end
end

local function onTaskAccepted(taskid)
	local list = OpenFuncData.getOpenDataByTerm(OpenFuncData.TERM_TASK_ACCEPTED, taskid)
	checkRunOpenList(list)
end

local function onTaskFinished(taskid)
	local list = OpenFuncData.getOpenDataByTerm(OpenFuncData.TERM_TASK_FINISHED, taskid)
	checkRunOpenList(list)
end

local function onCopyClear(copyid)
	local list = OpenFuncData.getOpenDataByTerm(OpenFuncData.TERM_COPY_CLEAR, copyid)
	checkRunOpenList(list)
end

EventMgr.addListener(EventType.TeamLevelUp, onLevelUp)
EventMgr.addListener(EventType.TaskAdd, onTaskAccepted)
EventMgr.addListener(EventType.TaskFinsh, onTaskFinished)
EventMgr.addListener(EventType.CopyClearance, onCopyClear)

local buildingMap = {} -- page => {msg}

local function checkRunBuilding(msg)
	local openData = OpenFuncData.getOpenData(OpenFuncData.TYPE_BUILDING, msg.building.building_type)
	if openData.run_open ~= 1 then --判断是否需要弹出标记
		return
	end
	local page = BuildingData.getPageById(openData.id)
	BuildingData.hideMap[openData.icon] = true
	local list = buildingMap[page]
	if not list then
		list = {}
		buildingMap[page] = list
	end
	table.insert(list, msg)
	-- circle:getBuilderLayer():setBuildingVisible(page, openData.icon, false)
	OpenFuncMgr.checkRunPage()
end

function OpenFuncMgr.checkRunPage()
	local scene = SceneMgr.getCurrentScene()
	if scene.name == "main" then
		local circle = scene:getCircle()
		if circle then
			local pageIndex = circle:getPageIndex()
			OpenFuncMgr.onScenePage(pageIndex, true)
		end
	end
end

function OpenFuncMgr.onScenePage(pageIndex, isUnEvent )
	local list = buildingMap[pageIndex]
	if list then
		if OpenFuncMgr.checkCanRun() then
			for _,v in ipairs(list) do
				OpenFuncMgr.doRunBuilding(v)
			end
			buildingMap[pageIndex] = nil
		end
	end

	if isUnEvent ~= true then
		EventMgr.dispatch( EventType.ScenePageBuilding, pageIndex )
	end
end
EventMgr.addListener(EventType.ScenePage, OpenFuncMgr.onScenePage)

function OpenFuncMgr.doRunBuilding(msg)
	local id = msg.building.building_type
	local openData = OpenFuncData.getOpenData(OpenFuncData.TYPE_BUILDING, id)
	local function callback(icon)
		OpenFuncMgr.turnAndFlyToBuilding(icon, openData, msg)
	end
	local function onBeginHandler()
		local scene = SceneMgr.getCurrentScene()
		if scene.getCircle then
			local circle = scene:getCircle()
			if circle then
				local page = BuildingData.getPageById(id)
				circle:getBuilderLayer():setBuildingVisible(page, openData.icon, false)
			end
		end
	end
	onBeginHandler()
	OpenFuncMgr.showBuildingOpen(openData.id, callback, onBeginHandler)
end

local function testRunBuilding(id)
	local building = gameData.findArrayData(gameData.user.building_list, "building_type", id)
	checkRunBuilding({set_type=const.kObjectUpdate, building=building})
end
Command.bind("openfunc testRunBuilding", testRunBuilding)

EventMgr.addListener(EventType.UserBuildingAdd, checkRunBuilding)

-- 飞向建筑
function OpenFuncMgr.turnAndFlyToBuilding(icon, openData, msg)
	if not icon then
        OpenFuncMgr.isOpening = false
		return
	end
	local scene = SceneMgr.getCurrentScene()
	if scene.name ~= "main" then
		icon:removeFromParent()
		OpenFuncMgr.isOpening = false
		return
	end
	local function onComplete()
		-- BuildingData.addBuilding(msg)
		local circle = scene:getCircle()
		local builderLayer = circle:getBuilderLayer()
		local page = BuildingData.getPageById(openData.id)
		BuildingData.hideMap[openData.icon] = nil
		builderLayer:setBuildingVisible(page, openData.icon, true)
		OpenFuncMgr.isOpening = false
		OpenFuncMgr.checkPriorityShow()
		builderLayer:openBuildingAction(page, openData.icon)
	end
	local function secondStep() --可以在这里把坐标传过来
		-- onComplete()
		-- local circle = scene:getCircle()
		-- local pos = circle:getWorldPosition(openData.id)
		-- local action1 = cc.MoveTo:create(0.5, pos)
		-- local action2 = cc.RemoveSelf:create()
		-- local action3 = cc.CallFunc:create(onComplete)
		-- icon:runAction(cc.Sequence:create(action1, action2, action3))
		local action1 = cc.RemoveSelf:create()
		local action2 = cc.CallFunc:create(onComplete)
		icon:runAction(cc.Spawn:create(action1, action2))
	end
	Command.run("cmd turnto building", openData.id, secondStep)
end

--飞向UI
function OpenFuncMgr.flyToUI(icon, openData)
	local pos = cc.p(0, 0)
	if openData.run_data then
		local btn = MainUIMgr.getRoleBottom():getButtonByName(openData.run_data)
		pos = cc.p(btn:getPosition())
		local size = btn.getSize and btn:getSize() or btn:getContentSize()
		pos.x = pos.x + size.width / 2
		pos.y = pos.y + size.height / 2
		pos = btn:convertToWorldSpace(pos)
	end
	local function onComplete()
		if openData.final_command and openData.final_command ~= "" then
			Command.parse(openData.final_command)
			OpenFuncMgr.isOpening = false
			OpenFuncMgr.checkPriorityShow()
			EventMgr.dispatch(EventType.OpenFunc, openData) --派发事件
		end
	end
	local action1 = cc.MoveTo:create(1, pos)
	local action2 = cc.RemoveSelf:create()
	local action3 = cc.CallFunc:create(onComplete)
	icon:runAction(cc.Sequence:create(action1, action2, action3))
end
function OpenFuncMgr.showBuildingOpen(id, callback, onBeginHandler)
	OpenFuncMgr.doShowOpen(OpenFuncData.TYPE_BUILDING, id, callback, onBeginHandler)
end

function OpenFuncMgr.showFuncOpen(id, callback, onBeginHandler)
	OpenFuncMgr.doShowOpen(OpenFuncData.TYPE_FUNC, id, callback, onBeginHandler)
end

function OpenFuncMgr.doShowOpen(type, id, callback, onBeginHandler)
	OpenFuncData.addUIData({type=type, id=id, callback=callback, onBeginHandler=onBeginHandler})
	OpenFuncMgr.checkPriorityShow()
end

function OpenFuncMgr.checkPriorityShow()
	PopMgr.checkPriorityPop("OpenFuncUI", PopOrType.Com, function()
		if not OpenFuncData.hasUIData() then
		    return
		end
		if not OpenFuncMgr.checkCanRun() then
			return
		end
		OpenFuncMgr.isOpening = true
		PopMgr.popUpWindow("OpenFuncUI", true, PopUpType.MODEL, true)
 	end)
end

function OpenFuncMgr.checkCanRun()
	if not SceneMgr.isSceneName("main") then
		return
	end
	local copy = PopMgr.getWindow("NCopyUI")
	if copy and copy:isShow() then
		return
	end
	if PopMgr.getRemoveOnce() then
        return
	end
	if OpenFuncMgr.isOpening then
		return
	end
	return true
end

local function onSceneShow()
    if SceneMgr.isSceneName("main") then
    	OpenFuncMgr.checkRunPage()
		TimerMgr.callLater(OpenFuncMgr.checkPriorityShow, 0.2)
	end
end

local function onWindowClose(data)
	if data and data.winName == "NCopyUI" then
		OpenFuncMgr.checkRunPage()
		OpenFuncMgr.checkPriorityShow()
	end
end

EventMgr.addListener(EventType.SceneShow, onSceneShow)
EventMgr.addListener(EventType.CloseWindow, onWindowClose)