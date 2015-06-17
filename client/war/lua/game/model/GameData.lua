-- create by Live --

local __this = {
    id = 0, --角色id
    user = {},          --SUserData
}

__this.time = {
    open_time = 0,
    server_time = 0,
    minuteswest = 0,
    dsttime = 0,
    timeoffset = 0, --客户端与服务器的时间差【单位：秒】
    lastLoginTime = 0,
    isDayFirstLogin = false
}

function __this.setServerTime(server_time, minuteswest, dsttime, open_time)
    __this.time.open_time = open_time
    __this.time.server_time = server_time
    __this.time.minuteswest = minuteswest
    __this.time.dsttime = dsttime
    __this.time.timeoffset = server_time - os.time()
    local timeZone = -minuteswest * DateTools.TIME_OF_MINUTE / DateTools.TIME_OF_HOUR
    LogMgr.info("服务器时间：", server_time, os.date("%Y年%m月%d日 %H:%M:%S", server_time), string.format("时区:%s", timeZone))
end

--开服时间戳
function __this.getOpenTime()
    return __this.time.open_time
end

-- 是否为开服第二天
function __this.isOpenPassOneDay()
    return DateTools.isOneDayPass( __this.getServerTime(),__this.time.open_time)
end 

function __this.getServerDate(time)
    time = time or __this.getServerTime()
    return os.date( '*t', time)
end

--当前服务器时间
function __this.getServerTime()
    return os.time() + __this.time.timeoffset
end

function __this.parseServerTime(year, month, day, hour, min, sec, isdst)
    hour = hour or 0
    min = min or 0
    sec = sec or 0
    isdst = isdst or __this.time.dsttime == 1
    return os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec, isdst=isdst})
end

function __this.getSimpleDataByKey(key)
    if not __this.user.simple then
        __this.user.simple = {}
    end
    return __this.user.simple[key]
end

function __this.setSimpleDataByKey(key, value)
    __this.user.simple[key] = value
end

function __this.addSimpleDataByKey(key, value)
    __this.user.simple[key] = tonumber(__this.user.simple[key]) + value
end

function __this.getCurExpData()
    local upLevel = 0
    local obtainExp, _ = CopyRewardData.getCurReward()
    local curExp = __this.getSimpleDataByKey("team_xp") + CopySceneUI.countCopyExp + obtainExp
    local teamLevel = __this.getSimpleDataByKey("team_level")
    if teamLevel >= MainScene.MaxTeamLevel then
        -- 戰隊最大等級
        LogMgr.debug("达到战队最大等级")
        teamLevel = MainScene.MaxTeamLevel
    end
    local maxExp = findLevel(teamLevel).team_xp
    local level = 0
    -- local cur, max = curExp, maxExp
    while curExp >= maxExp do 
        upLevel = upLevel + 1
        curExp = curExp - maxExp
        level = teamLevel + upLevel
        if level >= MainScene.MaxTeamLevel then
            LogMgr.debug("达到战队最大等级")
            level = MainScene.MaxTeamLevel
            maxExp = findLevel(level).team_xp
            break
        end
        maxExp = findLevel(level).team_xp
    end
    -- 返回当前升级后剩的exp和能升到的等级数
    return curExp, (teamLevel+upLevel) > MainScene.MaxTeamLevel and MainScene.MaxTeamLevel or (teamLevel+upLevel)
end

function __this.checkLevel(level)
    return __this.getSimpleDataByKey("team_level") and __this.getSimpleDataByKey("team_level") >= level
end

--修改 map, indices 对象数据
--__this.changeMap( __this.item_map[ trans.const.kBagFuncCommon ], 'guid', msg.set_type, msg.item )
function __this.changeMap( map, key, set_type, data )
    if set_type == trans.const.kObjectUpdate then
        map[ key ] = data
    elseif  set_type == trans.const.kObjectAdd then
        map[ key ] = data
    elseif set_type == trans.const.kObjectDel then
        map[key] = nil
    end
end

--查找数组对象索引, 返回  <= 0 为数据不存在
--__this.findArrayIndex( __this.user.item )
function __this.findArrayIndex( arr, key, val )
    for i = 1, #arr do
        if arr[i][ key ] == val then
            return i
        end
    end
    return 0
end

--查找数组对象数据
function __this.findArrayData( arr, key, val )
    local index = __this.findArrayIndex( arr, key, val )
    if index <= 0 then
        return nil
    end
    return arr[ index ]
end

--修改数组对象数据
function __this.changeArray( arr, key, set_type, data )
    __this.changeArrayByValue(arr, key, set_type, data, data[key])
end

function __this.changeArrayByValue(arr, key, set_type, data, value)
    local index = __this.findArrayIndex( arr, key, value )
    
    if set_type == trans.const.kObjectUpdate or set_type == trans.const.kObjectAdd then
        if index <= 0 then
            index = #arr + 1
        end 
        arr[ index ] = data
    elseif set_type == trans.const.kObjectDel then
        if index > 0 then
            table.remove( arr, index )
        end
    end
end

function __this.indexOfArray(arr, val)
    for i = 1, #arr do
        if arr[i] == val then
            return i
        end
    end
    return 0
end

gameData = __this
GameData = __this