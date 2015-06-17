DateTools = DateTools or {}
--时间工具，都是基于秒来计算的
DateTools.TIME_OF_MINUTE = 60;
DateTools.TIME_OF_HOUR = DateTools.TIME_OF_MINUTE * 60;
DateTools.TIME_OF_DAY = DateTools.TIME_OF_HOUR * 24;
DateTools.TIME_OF_WEEK = DateTools.TIME_OF_DAY * 7;

--获取毫秒数
function DateTools.getMiliSecond()
	return system.time_msec()
end

--获取当前时间戳
function DateTools.getTime()
	return os.time()
end

function DateTools.getDate(time)
    return os.date("%x", time)
end

-- hh:mm:ss
function DateTools.getCurrTime(time)
	if nil == time then
		time = '' .. gameData.getServerTime()
	end
	local currTime = os.date("%X", time)
	if string.len(currTime) < 8 then
		currTime = "0" .. currTime
	end
    return currTime
end

-- 判断是否已过一天
function DateTools.isOneDayPass(t1, t2)
    if DateTools.getYear(t1) == DateTools.getYear(t2) then
        if DateTools.getMonth(t1) == DateTools.getMonth(t2) then
            local d1, d2 = DateTools.getDay(t1), DateTools.getDay(t2)
            if math.abs(d1 - d2) >= 1 then
                if math.abs(d1 - d2) == 1 then
                    local max = math.max(t1, t2)
                    local h = DateTools.getHour(max)
                    if h >= 6 then
                        return true
                    else
                        return false
                    end
                else
                    return true
                end
            elseif math.abs(d1 - d2) == 0 then --开服时间临近6:00，过了6:00后亦认为是一天
                local open_hour = DateTools.getHour(math.min(t1, t2))
                local curr_hour = DateTools.getHour(math.max(t1, t2))
                if open_hour < 6 and curr_hour >= 6 then
                    return true
                else
                    return false
                end
            else
                return false
            end
        else
            return true
        end
    else
        return true
    end
end

function DateTools.getYear(time)
	return toint(os.date("%y", time))
end

function DateTools.getMonth(time)
	return toint(os.date("%m", time))
end

function DateTools.getDay(time)
	return toint(os.date("%d", time))
end

function DateTools.getHour(time)
	return toint(os.date("%H", time))
end

function DateTools.getMinute(time)
	return toint(os.date("%M", time))
end

function DateTools.getSecond(time)
	return toint(os.date("%S", time))
end

--X天X时X分X秒
--@param maxPart 最多的部分数，比如为2的时候，只显示3天3时
function DateTools.secondToString(time, maxPart)
	local result = ""
	maxPart = maxPart or 4
	local part = 0
	if time > DateTools.TIME_OF_DAY then
		result = "" .. math.floor(time / DateTools.TIME_OF_DAY) .. "天"
		part = part + 1
	end
	if part < maxPart and (result ~= "" or time > DateTools.TIME_OF_HOUR) then
		result = result .. math.floor(time % DateTools.TIME_OF_DAY / DateTools.TIME_OF_HOUR) .. "时"
		part = part + 1
	end
	if part < maxPart and (result ~= "" or time > DateTools.TIME_OF_MINUTE) then
		result = result .. math.floor(time % DateTools.TIME_OF_HOUR / DateTools.TIME_OF_MINUTE) .. "分"
		part = part + 1
	end
	if part < maxPart then
		result = result .. time % DateTools.TIME_OF_MINUTE .."秒"
		part = part + 1
	end
	return result
end


--X:(天):X(时):X(分):X(秒)
--00:00:00:00
--@param maxPart 最多的部分数，比如为2的时候，只显示3(天):3(时)
function DateTools.secondToStringTwo(time, maxPart)
    local result = ""
    maxPart = maxPart or 4
    local part = 0
    local t = 0
    if time >= DateTools.TIME_OF_DAY then
        t = math.floor(time / DateTools.TIME_OF_DAY)
        if t/10 < 1 then 
           result = "0" .. math.floor(time / DateTools.TIME_OF_DAY) .. ":"
        else 
           result = "" .. math.floor(time / DateTools.TIME_OF_DAY) .. ":"
        end       
        part = part + 1
    end
    if part < maxPart and (result ~= "" or time >= DateTools.TIME_OF_HOUR) then
        t = math.floor(time % DateTools.TIME_OF_DAY / DateTools.TIME_OF_HOUR)
        if t/10 < 1 then 
            result = result .."0".. math.floor(time % DateTools.TIME_OF_DAY / DateTools.TIME_OF_HOUR) .. ":"
        else 
            result = result .. math.floor(time % DateTools.TIME_OF_DAY / DateTools.TIME_OF_HOUR) .. ":"
        end     
        part = part + 1
    end
    if part < maxPart and (result ~= "" or time >= DateTools.TIME_OF_MINUTE) then       
        t = math.floor(time % DateTools.TIME_OF_HOUR / DateTools.TIME_OF_MINUTE)
        if t/10 < 1 then 
            result = result .. "0" .. math.floor(time % DateTools.TIME_OF_HOUR / DateTools.TIME_OF_MINUTE) .. ":"
        else 
            result = result .. math.floor(time % DateTools.TIME_OF_HOUR / DateTools.TIME_OF_MINUTE) .. ":"
        end       
        part = part + 1
    end
    if part < maxPart then
        t = time % DateTools.TIME_OF_MINUTE
        if t/10 < 1 then 
            result = result .. "0" .. time % DateTools.TIME_OF_MINUTE ..""
        else 
            result = result .. time % DateTools.TIME_OF_MINUTE ..""
        end  
        part = part + 1
    end
    return result
end

--2014
function DateTools.getYearInt(time)
    return toint(os.date("%Y" , time))
end 
--转换为yyyymmdd的整型格式
function DateTools.toDateInt(time)
	return toint(os.date("%y%m%d", time))
end

--如2014-12-12
function DateTools.toDateString(time)
    return tostring(os.date("%Y-%m-%d" , time))
end 
--如11:00:00
function DateTools.toTimeString(time)
    return tostring(os.date("%H:%M:%S", time))
end 

--转换为hhmmss的整型格式
function DateTools.toTimeInt(time)
	return toint(os.date("%H%M%S", time))
end

function DateTools.toFormatString(time, format)
	return os.date(format, time)
end
