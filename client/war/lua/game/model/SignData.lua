local __this = {dayMap={}, resultMap={}}
SignData = __this

function __this.addMarkLog(sign)
    local arr = __this.getServerData().sign_list
    gameData.changeArray(arr, "day_id", const.kObjectAdd, sign)
    __this.resultMap[sign.day_id] = true
end

function __this.addRewardLog(id)
    local arr = __this.getServerData().sum_list
    arr[#arr + 1] = id
end

function __this.getDate(str)
    local _,_,year,month,day = string.find(str, "(%d+)-(%d+)-(%d+)")
    return toint(year),toint(month),toint(day)
end
--是否有东西可领取
function __this.getCanGet(force)
    if force or __this._canget == nil then
        local canget = false
        if __this.canSign() then
            canget = true
        elseif __this.canGetSum() then
            canget = true
        elseif __this.canGetHaoHua() then
            canget = true
        end
        __this._canget = canget
    end
    return __this._canget
end
--是否能签到
function __this.canSign( time )
    local cansign = false
   time = time or __this.getCurrentSeverTime()
   local dif_day = __this.getCountInOpenDay(time)
   if dif_day > 0 then
        if __this.isOneDay(time,__this.getCurrentSeverTime()) and __this.hasSign(time) == false then
            cansign = true
        end
    end
    return cansign
end

function __this.hasSign( time )
    local hassign = false
    time = time or __this.getCurrentSeverTime()
    local dif_day = __this.getCountInOpenDay(time)
    if dif_day > 0 then
        local jSign = findSignDay(dif_day)
        if jSign and __this.getServerDay(jSign.id) then
            hassign = true
        end
    end
    return hassign
end

--是否能领取累积奖励
function __this.canGetSum( ... )
   local canget = false
    local curCount = __this.getCount()
    local count = __this.getNextCount()
   local nextReward = __this.getNextTotalReward(count)
   if curCount >= count and nextReward and not __this.getServerReward(nextReward.id) then
        canget = true
   end
   return canget
end
--是否能领取豪华奖励
function __this.canGetHaoHua( ... )
    local canget = false
    if __this.hasGetHaoHua() == false and __this.isRechargeHaoHua() then
        canget =  true
    end
    return canget
end

function __this.isRechargeHaoHua( ... )
    local rechargeCount = tonumber(VarData.getVar("sign_today_recharge_count"))
    local tarCount = tonumber(findGlobal("sign_haohua_reward_recharge_count").data)
    return rechargeCount >= tarCount
end

function __this.hasGetHaoHua( ... )
    local getTime = VarData.getVar( 'sign_today_haohua_take_time' )
    if getTime ~= 0 then
        return true
    else
        return false
    end
end

--获取当前签到奖励
function __this.getCurJSinData( ishaohua )
    local jdata
    local day_count = __this.getCountInOpenDay()
    --如果没开服，即显示第一天
    if day_count == 0 then
        day_count = 1
    end
    if not ishaohua then
        --如果已签到，即显示明天的
        if __this.getServerDay(day_count) then
            day_count = day_count + 1
        end
    else
        --如果已经领取，即显示明天的
        local getTime = VarData.getVar( 'sign_today_haohua_take_time' )
        if getTime ~= 0 then
            day_count = day_count + 1
        end
    end
    if day_count >= #GetDataList( 'SignDay' ) then
        day_count = #GetDataList( 'SignDay' )
    end
    jdata =  findSignDay(day_count)
    return jdata
end

--获取将获得奖励的次数
function __this.getNextCount( count )
    count = count or 1
    if count >= #GetDataList( 'SignSum' ) then
        return count
    end
    local nextReward = __this.getNextTotalReward(count)
    if nextReward and not __this.getServerReward(nextReward.id) then
        return count
    else
        return __this.getNextCount(count + 1)
    end
end

--获取当前显示的奖励
function __this.getNextTotalReward(count)
    count = count or __this.getNextCount()
    local result
    local reward_list = GetDataList( 'SignSum' )
    for k,v in pairs(reward_list) do
        if v then
            if v.sum_days == count then
                result = v
                break
            elseif v.sum_days > count then
                break
            end
        end
    end
    return result
end
--@type 类型，0表示所有
function __this.getCount( )
    local result = 0
    if __this.getServerData().sign_list then
        result = #__this.getServerData().sign_list
    end
    return result
end

--获取7天时间
function __this.getItemTimeList( ... )
   local wday = __this.getCurrentSeverDate().wday
   wday = wday - 1
   if wday == 0 then
        wday = 7
   end
   local itemTimeList = {}
   for i = 1,7 do 
        local dif = i -  wday
        local dayTimer = __this.getCurrentSeverTime() + dif * DateTools.TIME_OF_DAY
        table.insert( itemTimeList, dayTimer )
   end
   return itemTimeList
end


--当前时间与开服时间相差的天数
function __this.getCountInOpenDay( time )
    time = time or __this.getCurrentSeverTime()
    local dif_day = 0
    local openTime = __this.getCurrentOpenTime()
    if openTime > time and __this.getDifDay(openTime,time) == 0 then
        dif_day = 1
    else 
        local cur_day = __this.getDifDay(time,openTime)
        if cur_day == 0 then
            dif_day = 1
        elseif cur_day > 0 then
            dif_day = cur_day + 1
        end
    end
    return dif_day
end

function __this.getDifDay( targettime,stime )
   local dif_day = 0
   if targettime and stime then
        local target_date = gameData.getServerDate(targettime)
        local target_time = gameData.parseServerTime(target_date.year,target_date.month,target_date.day)
        local s_date = gameData.getServerDate(stime)
        local s_time = gameData.parseServerTime(s_date.year,s_date.month,s_date.day)
        if s_time == nil then
            return dif_day
        end
        dif_day = math.floor((target_time - s_time) / DateTools.TIME_OF_DAY)
   end
   return dif_day
end

function __this.isOneDay( time1,time2 )
    if time2 and time1 then
        local date1 = gameData.getServerDate(time1)
        local date2 = gameData.getServerDate(time2)
        if date1.year == date2.year and date1.month == date2.month and date1.day == date2.day then
            return true
        end
    end
    return false
end

--服务器时间
function __this.getCurrentSeverTime( ... )
    --偏移6小时
    return gameData.getServerTime() - 6 * DateTools.TIME_OF_HOUR
end

function __this.getCurrentOpenTime( ... )
    return gameData.getOpenTime() - 6 * DateTools.TIME_OF_HOUR
end

--服务器日期
function __this.getCurrentSeverDate( time )
    return gameData.getServerDate(time or __this.getCurrentSeverTime())
end

function __this.getServerDay(id) --return  SSign
    local sign_list = __this.getServerData().sign_list
    for _,sign in ipairs(sign_list) do
        if (sign.day_id == id) then
            return sign
        end
    end
    return nil
end

function __this.getServerReward(id) --return Bool
    local sum_list = __this.getServerData().sum_list
    for _,v in ipairs(sum_list) do
        if (v == id) then
            return true
        end
    end
    return false
end

function __this.getServerData()
    return gameData.user.sign_info 
end

EventMgr.addListener(EventType.UserVarUpdate, function ( key )
    if key == "sign_today_haohua_take_time" or key == "sign_today_recharge_count" then
        __this.getCanGet(true)
        EventMgr.dispatch(EventType.UserMarkUpdate)
    end
end )
EventMgr.addListener(EventType.NewDayBegain, function ( )
    __this.getCanGet(true)
    EventMgr.dispatch(EventType.UserMarkUpdate)
end )


