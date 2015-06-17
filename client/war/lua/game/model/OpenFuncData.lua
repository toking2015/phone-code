OpenFuncData = {}

OpenFuncData.TYPE_BUILDING = 1
OpenFuncData.TYPE_FUNC = 2
--ID
OpenFuncData.ID_CHAT = 11


--开启条件：1等级2接任务3完成任务4活动
OpenFuncData.TERM_LEVEL = 1
OpenFuncData.TERM_TASK_ACCEPTED = 2
OpenFuncData.TERM_TASK_FINISHED = 3
OpenFuncData.TERM_ACTIVITY = 4
OpenFuncData.TERM_COPY_CLEAR = 5

function OpenFuncData.clear()
	OpenFuncData.dataList = {} -- 数据列表
end
OpenFuncData.clear()
EventMgr.addListener(EventType.UserLogout, OpenFuncData.clear)

function OpenFuncData.hasUIData()
	return #OpenFuncData.dataList > 0
end

function OpenFuncData.removeUIData()
	if OpenFuncData.hasUIData() then
		return table.remove(OpenFuncData.dataList)
	end
end

function OpenFuncData.addUIData(data)
	table.insert(OpenFuncData.dataList, data)
end

function OpenFuncData.getOpenData(type, id)
	if OpenFuncData.TYPE_BUILDING == type then
		return findBuilding(id)
	end
	return findOpen(id)
end

--只针对Open表
function OpenFuncData.getOpenDataByTerm(open_type, open_term)
	local list = GetDataList("Open")
	local openList = {}
	for _,v in pairs(list) do
		v = findOpen(v.id)
		if v.open_type == open_type and v.open_term == open_term then
			table.insert(openList, v)
			-- return v
		end
	end
	return openList
end

function OpenFuncData.checkIsOpenFunc(id, showTips)
	return OpenFuncData.checkIsOpen(OpenFuncData.TYPE_FUNC, id, showTips)
end

function OpenFuncData.checkIsOpenBuilding(id, showTips)
	return OpenFuncData.checkIsOpen(TYPE_BUILDING, id, showTips)
end

function OpenFuncData.checkIsOpen(type, id, showTips)
	local openTips = nil
	if OpenFuncData.TYPE_BUILDING == type then
		return BuildingData.checkBuildingExist(id, showTips),(BuildingData.checkBuildingExist(id, showTips) and nil or "建筑未开放")
	end
	local data = findOpen(id)
	local result = true
	if data then
		if data.open_type == OpenFuncData.TERM_LEVEL then
			result = gameData.getSimpleDataByKey("team_level") >= data.open_term
			openTips = string.format("战队[%s]级开启", data.open_term)
		elseif data.open_type == OpenFuncData.TERM_TASK_ACCEPTED then
			result = TaskData.getTask(data.open_term) ~= nil or TaskData.hasLogTask(data.open_term)
			openTips = string.format("接受[%s]任务后开启", data.open_term)
		elseif data.open_type == OpenFuncData.TERM_TASK_FINISHED then
			result = TaskData.hasLogTask(data.open_term)
			openTips = string.format("完成[%s]任务后开启", TaskData.getTaskName(data.open_term))
		elseif data.open_type == OpenFuncData.TERM_ACTIVITY then
			result = data.open_term ~= 0
			openTips = string.format("活动[%s]未开启", TaskData.getTaskName(data.open_term))
		elseif data.open_type == OpenFuncData.TERM_COPY_CLEAR then
			result = CopyData.checkClearance(data.open_term)
			openTips = string.format("通关[%s]副本后开启", CopyData.getCopyName(data.open_term))
		end
	end
	if showTips and not result then
		TipsMgr.showError(openTips)
	end
	return result, openTips
end