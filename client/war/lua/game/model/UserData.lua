local __this = UserData or {}
UserData = __this

function __this.getSimpleData()
    return gameData.user.simple
end

function __this.getInfoData()
    return gameData.user.info
end

function __this.getFightValue()
	return gameData.user.simple.fight_value
end

function __this.updateFightValue()
	local value = FormationData.getFightValueByType(const.kFormationTypeCommon)
	if value ~= __this.getFightValue() then
		gameData.user.simple.fight_value = value
		EventMgr.dispatch(EventType.UserSimpleUpdate)
	end
end

------角色数据缓存-------
local STATE_INIT = 1
local STATE_LOADING = 2
local STATE_TIMEOUT = 3
local STATE_STANDBY = 4

local clsMap = {}

clsMap["SUserSimple"] = {
	cacheMap = {},
	questFunc = function(guid) Command.run("user simple", guid) end,
	timeout = 300
}

local function createCacheObject()
	local obj = {
		callList = {},
		time = 0,
		data = nil
	}
	return obj
end

local function checkTimeout(timeout, cacheTime)
	local timeNow = DateTools.getTime()
	return timeNow > cacheTime + timeout
end

local function checkState(clsObj, cacheObj)
	local state = STATE_INIT
	if cacheObj then
		if cacheObj.time == 0 then
			state = STATE_INIT
		elseif cacheObj.data == null then
			state = STATE_LOADING
		elseif checkTimeout(clsObj.timeout, cacheObj.time) then
			state = STATE_TIMEOUT
		else
			state = STATE_STANDBY
		end
	end
	return state
end

local function hasCache(guid, clsName)
	if guid == 0 then
		return false
	end
	local clsObj = clsMap[clsName]
	if not clsObj then
		return false
	end
	local obj = clsObj.cacheMap[guid]
	if not obj then
		return false
	end
	local state = checkState(clsObj, obj)
	return state ~= STATE_INIT and state ~= STATE_LOADING
end

local function addCallFunc(callList, callback)
	if callback then
		table.insert(callList, callback)
	end
end

function UserData.loadCache(guid, callback, clsName, timeout_return, force_update)
	if guid == 0 then
		return nil
	end
	local clsObj = clsMap[clsName]
	if not clsObj then
		return nil
	end
	local cacheMap = clsObj.cacheMap
	local cacheObj = cacheMap[guid]
	if not cacheObj then
		cacheObj = createCacheObject()
		cacheMap[guid] = cacheObj
	end
	local state = checkState(clsObj, cacheObj)
	local needQuest = #cacheObj.callList == 0
	if timeout_return == nil then --默认超时也返回
		timeout_return = true
	end
	if force_update then
		timeout_return = false
		if state == STATE_STANDBY then
			state = STATE_TIMEOUT
		end
	end
	if state == STATE_STANDBY then
		return cacheObj.data
	end
	addCallFunc(cacheObj.callList, callback)
	if needQuest then
		-- cacheObj.questTime = DateTools.getTime()
		clsObj.questFunc(guid)
	end
	if state == STATE_TIMEOUT and timeout_return == true then
		return cacheObj.data
	end
	return nil
end

--根据ID获取用户的SUserSimple
function UserData.loadSimple(guid, callback, timeout_return, force_update)
	return UserData.loadCache(guid, callback, "SUserSimple", timeout_return, force_update)
end

function UserData.saveCache(clsName, guid, data)
	local clsObj = clsMap[clsName]
	if not clsObj then
		return
	end
	local cacheObj = clsObj.cacheMap[guid]
	if not cacheObj then
		cacheObj = createCacheObject()
		clsObj.cacheMap[guid] = cacheObj
	end
	cacheObj.data = data
	cacheObj.time = DateTools.getTime()
	if #cacheObj.callList > 0 then
		local callList = cacheObj.callList
		cacheObj.callList = {}
		for _,v in ipairs(callList) do
			v(data)
		end
	end
end
