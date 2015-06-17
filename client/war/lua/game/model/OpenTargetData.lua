local __this = {JOpenTargetMap = {},cangetDayMap ={},valueMap = {},countDayMap={}} -- cangetDayMap[day][jdata.id]
OpenTargetData = __this
__this.selectDay = 1
__this.selectIndex = 1
__this.typeBuy = 4

 __this.event_list = {EventType.InfLevelUp,EventType.UserSimpleUpdate,EventType.UserTotemUpdate,
                      EventType.UserTotemChange,EventType.UserPayUpdate,EventType.UserVarUpdate,
                      EventType.NewDayBegain,EventType.TeamLevelUp,EventType.ArenaRole,
                      EventType.TotemSlotResult,EventType.UserEquipMerge,EventType.UserSoldierEquipExt,EventType.UserItemUpdate,EventType.TempleInfo}
 --事件
function __this.addListener( ... )
     for i,v in pairs(__this.event_list) do
        EventMgr.addListener( v, function()
        __this.updateForce()
    end )
    end
    __this.sendMsg()
    __this.hasListning = true
end

function __this.sendMsg( ... )
   Command.run("temple info") --收集
end

function __this.removeListener( ... )
    if __this.hasListning then
        for i,v in pairs(__this.event_list) do
            EventMgr.removeListener( v, function()
            __this.updateForce()
        end )
        end
         EventMgr.removeListener(EventType.UserDataLoaded,function ( ... )
        __this.sendMsg()
        end)
        __this.hasListning = nil
    end
end

 function __this.setSelectIndex( index )
    if __this.selectIndex == index then
        return
    end
     __this.selectIndex = index
     EventMgr.dispatch( EventType.actOpenTargetUpdate)
 end

 function __this.setSelectDay( day )
    if __this.setSelectDay == day then
        return
    end
     __this.selectDay = day
    local datalist = __this.getJOpenTargetDay(iday)
    if __this.selectIndex ~= 1 then
        __this.setSelectIndex(1)
    else
        EventMgr.dispatch( EventType.actOpenTargetUpdate)
    end
 end

--获取天数据
 function __this.getJOpenTargetDay( iday )
    local day = iday or __this.selectDay
    local count_day = 0
    if __this.JOpenTargetMap[day] == nil then
        local list = GetDataList("OpenTarget")[day]
        local dayMap = {}
        __this.JOpenTargetMap[day] = dayMap
        local typeMap = {}
        local index = 1
        local indexMap = {}
        if list == nil or #list == 0 then
            return nil
        end
        for _,v in pairs(list) do
            if v.day == day then
                if __this.countDayMap[day] == nil and v.if_type and v.if_type >0 and v.if_type ~= const.kOpenTargetIfTypeAll then
                    count_day = count_day + 1
                end
                if typeMap[v.a_type] == nil then
                    typeMap[v.a_type] = {}
                    if dayMap[index] == nil then
                        dayMap[index] = typeMap[v.a_type]
                        index = index + 1
                    end
                end
                table.insert(typeMap[v.a_type],v)
            end
        end
        -- for k,v in pairs(indexMap) do
        --     table.insert(dayMap,v)
        -- end
    end
    if __this.countDayMap[day] == nil then
        __this.countDayMap[day] = count_day
    end
    return __this.JOpenTargetMap[day]
 end
  --获取数据处理
 function __this.getJOpenTarget( day,index )
    local re_data
    local n_day = day or __this.selectDay
    local n_index = index or __this.selectIndex
    if __this.getJOpenTargetDay(n_day) then
        re_data = __this.getJOpenTargetDay(n_day)[n_index]
    end
    return re_data
 end
 --排序，可领取的放前面，已领取的放后面
 function __this.getSorJopenTarget( jdatalist )
    local re_list
    if jdatalist then
        table.sort(jdatalist,function ( a,b )
        --都可领取
        if __this.getCangetItem(a) and __this.getCangetItem(b) then
            return a.id < b.id 
        elseif __this.hasGetItem(a) and __this.hasGetItem(b) then
            return a.id < b.id 
        elseif __this.getCangetItem(a) then
            return true
        elseif __this.getCangetItem(b) then
            return false
        elseif __this.hasGetItem(a) then
            return false
        elseif __this.hasGetItem(b) then
            return true
        else
            return a.id < b.id 
        end
        end)
    end
    return jdatalist
 end
 --获取某天数据长度
 function __this.getLenDayData( day )
     local nday = day or __this.selectDay
     local day_data = __this.getJOpenTargetDay(nday)
     local len = #day_data
     return len
 end

 function __this.getCurOpenDay( force )
    if force or __this.cur_openday == nil then
        --偏移6小时
        local time = gameData.getServerTime() - 6 * DateTools.TIME_OF_HOUR
        local openTime = __this.getCurrentOpenTime()
        if openTime > time then
            __this.cur_openday = 1
        else 
            local cur_day = __this.getDifDay(time,openTime)
            if cur_day == 0 then
                __this.cur_openday = 1
            elseif cur_day > 0 then
                __this.cur_openday = cur_day + 1
            end
        end
    end
    return __this.cur_openday
 end

  --是否开放
 function __this.getIsOpen( ... )
    local cur_openday = __this.getCurOpenDay()
    if cur_openday >=1 and cur_openday <= 10 then
        if __this.hasListning == nil then
            __this.addListener()
        end
        return true
    else
        if __this.hasListning then
            __this.removeListener()
        end
        return false
    end
 end

 function __this.getDifDay( targettime,stime )
   local dif_day = 0
   if targettime and stime then
        local target_date = gameData.getServerDate(targettime)
        local target_time = gameData.parseServerTime(target_date.year,target_date.month,target_date.day)
        local s_date = gameData.getServerDate(stime)
        local s_time = gameData.parseServerTime(s_date.year,s_date.month,s_date.day)
        if s_time then
            dif_day = math.floor((target_time - s_time) / DateTools.TIME_OF_DAY)
        end
   end
   return dif_day
end

function __this.getCanget( ... )
    local cur_openday =__this.getCurOpenDay()
    if cur_openday > 0 then
        for i = 1,cur_openday do
            if __this.getCangetDay( i ) then
                return true
            end
        end
    end
    return false
end
function __this.updateForce( ... )
    if __this.getIsOpen() == false then
        return
    end
    __this.getCurOpenDay(true)
    __this.updateCanget()
    EventMgr.dispatch(EventType.actOpenTargetUpdate)
end
--更新可领取
function __this.updateCanget( ... )
    __this.cangetDayMap = {}
    __this.valueMap = {}
    if __this.getIsOpen() then
        local cur_openday =__this.getCurOpenDay()
        if cur_openday > 7 then
            cur_openday = 7
        end
        for i=1,cur_openday do
            local datalist =__this.getJOpenTargetDay(i)
            if datalist then
                for index,list in pairs(datalist) do
                    if list then
                        for k,data in pairs(list) do
                            if __this.valueMap[i] == nil then
                                __this.valueMap[i] = {}
                            end
                            __this.valueMap[i][data.id] = __this.getValueByData(data)
                            if __this.getCangetItemType(data) or __this.getCanBuyItem(data) then
                                if __this.cangetDayMap[i] == nil then
                                    __this.cangetDayMap[i] = {}
                                end
                                __this.cangetDayMap[i][data.id] = true
                            end
                        end
                    end
                end
            end
        end
    end
end

 --第几天是否能领取
function __this.getCangetDay( day )
    local n_day = day or __this.selectDay
    if n_day > __this.getCurOpenDay() then -- 如果还没到
        return false
    end
    if __this.cangetDayMap[n_day] then
        return true
    else
        return false
    end
end
--第几天第几项是否能领取
function __this.getCangetIndex( day,index)
    local n_day = day or __this.selectDay
    local n_index = index or __this.selectIndex
    local jdatalist = __this.getJOpenTarget(day,index)
    if jdatalist then
        for k,v in pairs(jdatalist) do
            if __this.getCangetItem(v) == true then
                return true
            end
        end
    end
    return false
end
--第几天第几项是否已达成
function __this.getDoneIndex( day,index )
    local n_day = day or __this.selectDay
    local n_index = index or __this.selectIndex
    local jdatalist = __this.getJOpenTarget(day,index)
    if jdatalist then
        for k,v in pairs(jdatalist) do
            if v.a_type == 4 then
                if __this.hasBuyItem(v) == false then
                    return false
                end
            elseif __this.hasGetItem(v) == false then
                return false
            end
        end
        return true
    end
    return false
end

function __this.getRateCountItem( jdata )
   local value = 0 
   if __this.valueMap[jdata.day] and __this.valueMap[jdata.day][jdata.id] then
        value = __this.valueMap[jdata.day][jdata.id]
   end
   return value
end

function __this.getRateStr( jdata )
    local re_str = ""
    if jdata.if_type == 1 then  
    elseif jdata.a_type == 2 then --副本
        if jdata.if_type == 5 then --等级
            re_str =string.format("%d/%d",__this.getRateCountItem(jdata),jdata.if_value_1)
        else
            local copy_type = const.kCopyMopupTypeElite
            if jdata.if_type == 3 then
                copy_type =const.kCopyMopupTypeNormal
            end
            local copy_id = CopyData.getMaxPassCopyStart(jdata.if_value_1,copy_type)
            if copy_id then
                local copy = findCopy(copy_id)
                if copy then
                    re_str ="当前: " .. ( copy.name or tostring(copy.id))
                end
            end
        end
    else
        local total  = 0
        if jdata.if_type == const.kOpenTargetIfTypeAll then
            total = __this.countDayMap[jdata.day] or 0
        elseif jdata.if_value_1 then
            total = jdata.if_value_1
        end
        re_str =string.format("%d/%d",__this.getRateCountItem(jdata),total)
    end
    return re_str
end

--某ITEM是否能领取
 function __this.getCangetItem( jdata )
    if jdata and jdata.day then
        if jdata.day > __this.getCurOpenDay() then -- 如果还没到
            return false
        end
        if __this.cangetDayMap[jdata.day] and __this.cangetDayMap[jdata.day][jdata.id] then
            return true
        end
    end
    return false
 end

--item是否能领取
 function __this.getCangetItemType( jdata )
    if jdata.a_type == 4 then
        return false
    elseif __this.hasGetItem(jdata) then
        return false
    else
        return __this.getDoneItemType(jdata)
    end
 end

--item是否已达成
 function __this.getDoneItemType( jdata )
    if jdata then
            local value = __this.getValueByData(jdata)
            if jdata.if_type == 1 then
                return true
            elseif jdata.if_type == 8 then
                if jdata.if_value_1 and value and value > 0 and value <= jdata.if_value_1 then
                    return true
                else
                    return false
                end
            elseif jdata.if_type == const.kOpenTargetIfTypeAll then
                if value > 0 and value >= __this.countDayMap[jdata.day] then
                    return true
                end
            elseif jdata.if_value_1 and value and value >= jdata.if_value_1 then
                return true
            else
                return false
            end
    end
        return false
 end

function __this.getValueByData( jdata )
    local value = 0 
    if jdata then
        if jdata.if_type == 2 then --累积充值
            value = gameData.user.pay_info.pay_sum
        elseif jdata.if_type == 3 then
            value = CopyData.getCopyStars(jdata.if_value_2,1)
        elseif jdata.if_type == 4 then
            value = CopyData.getCopyStars(jdata.if_value_2,2)
        elseif jdata.if_type == 5 then
            value = gameData.getSimpleDataByKey("team_level")
        elseif jdata.if_type == 6 then
            value = __this.getEquiptCount(const.kCoinEquipWhite + (jdata.if_value_2 - 1))
        elseif jdata.if_type == 7 then
            value  = __this.getSoldierCount(jdata.if_value_2)
        elseif jdata.if_type == 8 then
            value = gameData.user.other.single_arena_rank
        elseif jdata.if_type == 9 then
            value  = gameData.user.tomb_info.history_win_count
        elseif jdata.if_type == 10 then --图腾
            value = __this.getTotemCount(jdata.if_value_2)
        elseif jdata.if_type == 11 then --英雄组合
            value = __this.getSoldierList( )
        elseif jdata.if_type == 12 then -- 雕纹
            value = __this.getSoueStone(jdata.if_value_2)
        elseif jdata.if_type == const.kOpenTargetIfTypeAll then --当天所有
            value = __this.getAllDoneByDay(jdata.day)
        end
    end
    return value
end
--获取当天所有已完成的条件
function __this.getAllDoneByDay( day )
    local value = 0
   local datalist =__this.getJOpenTargetDay(day)
    if datalist then
        for index,list in pairs(datalist) do
            if list then
                for k,data in pairs(list) do
                    if data.if_type and data.if_type > 0 and data.if_type ~= const.kOpenTargetIfTypeAll and __this.getDoneItemType(data) == true then
                        value = value + 1
                    end
                end
            end
        end
    end
    return value
end
--获取英雄组合数
function __this.getSoldierList( ... )
    local value = 0
    value = #TempleData.getData().group_list
    return value
end

--获取对应品质神符数
function __this.getSoueStone( quality )
    local value = 0
    local souestonelist = TempleData.getData().glyph_list
    if souestonelist then
        for i,v in pairs(souestonelist) do
            if v and v.embed_type and v.embed_type > 0 then
                local stone = findTempleGlyph(v.id)
                if stone then
                    if stone.quality and stone.quality >= quality then
                        value = value + 1
                    end
                end
            end
        end
    end
    return value
end

 function __this.getSoldierCount(cstart )
    local sList = SoldierData.getTable()
    local re_count = 0
    for k,v in pairs(sList) do
        if v.star >= cstart then
            re_count = re_count + 1
        end
    end
    return re_count
 end
 function __this.getTotemCount( start )
    local re_count = 0
    local list = TotemData.getData()
    for _,v in pairs(list) do
        if v.level >= start then
            re_count = re_count + 1
        end
    end
    return re_count
 end
--获取某颜 色装备最大的数量数
 function __this.getEquiptCount( grate,count )
    local recount = 0
    local cur_count = 0
    for i=1,4 do
        for j=1,4 do
            if EquipmentData:getEquipmentCountForQuality(i,j,grate) >= 6 then
                recount = recount + 1
            end
        end
    end
    return recount
 end

 function __this.hasBuyItem( jdata )
    if jdata then
        local getted = VarData.getVar(string.format("opent_target_buy_%d_%d",jdata.day,jdata.id))
        if getted and tonumber(getted) >= 1 then
            return true
        end
    end
    return false
 end

 function __this.getCanBuyItem( jdata )
    if jdata then
        if jdata.day <= __this.getCurOpenDay() then
            if jdata.a_type == 4 and __this.hasBuyItem(jdata)== false then
                return true
            end
        end
    end
    return false
 end

 function __this.hasGetItem( jdata )
    if jdata then
        local getted = VarData.getVar(string.format("opent_target_take_%d_%d",jdata.day,jdata.id))
        if getted and tonumber(getted) >= 1 then
            return true
        end
    end
    return false
 end

 function __this.getCurrentOpenTime( ... )
    return gameData.getOpenTime() - 6 * DateTools.TIME_OF_HOUR
end

function __this.getActivitTimeStr( day )
    local n_day = day or __this.selectDay
    local openTime = __this.getCurrentOpenTime()
    local enTime = openTime + DateTools.TIME_OF_DAY * 10
    local open_date = gameData.getServerDate(openTime)
    local end_date = gameData.getServerDate(enTime)
    local re_str = string.format("活动时间：%d年%d月%d日 06:00:00 至 %d年%d月%d日 06:00:00",open_date.year,open_date.month,open_date.day,end_date.year,end_date.month,end_date.day)
    return re_str
end