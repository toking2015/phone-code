local function dataLoadedHandler()
	EventMgr.removeListener(EventType.UserDataLoaded, dataLoadedHandler)
    --上次打开APP的时间
    local curTime = DateTools.getTime()
    gameData.time.lastLoginTime = toint(LocalDataMgr.load_string(gameData.id, "time.lastLoginTime")) or 0
    if DateTools.toDateInt(curTime) ~= DateTools.toDateInt(gameData.time.lastLoginTime) then
        gameData.time.isDayFirstLogin = true
    end
    LocalDataMgr.save_string(gameData.id, "time.lastLoginTime", tostring(curTime))	
end

EventMgr.addListener(EventType.UserDataLoaded, dataLoadedHandler)