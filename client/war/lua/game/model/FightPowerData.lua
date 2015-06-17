local __this = {dataMap={},stypeMap={},valueMap={}}
FightPowerData = __this
__this.curType = 0
__this.curStype = 0
-- curtype:1:英雄，2：图腾，3：装备，4：神符

function __this.updateDataUI( ... )
    EventMgr.dispatch(EventType.FightPowerUpdate)
end


function __this.getDataList()
    if #__this.dataMap <= 0 then
        __this.dataMap = GetDataList("Fightpower")
    end
    return __this.dataMap
end
--获取所有数据
function __this.getDataListType( type,s_type )
    type = type or __this.curType
    local datalist = __this.getDataList()
    local redata = nil
    if s_type == nil then
        redata = datalist[type]
    else
        local key = type ..'_'.. s_type
        if __this.stypeMap[key] == nil then
            __this.stypeMap[key] = {}
            for k,v in pairs(datalist[type]) do
                if v.s_type == s_type then
                    table.insert(__this.stypeMap[key],v)
                end
            end
        end
        redata = __this.stypeMap[key]
    end
    return redata
end
--获取等级对应的数据
function __this.getDataListCurType( type )
    type = type or __this.curType
    local relist = {}
    local typelsit = __this.getDataListType(type)
    for k,v in pairs(typelsit) do
        if v and relist[v.s_type] == nil then
            local curjdata = __this.getDataListTypeData(type,v.s_type)
            if curjdata then
                relist[v.s_type] = curjdata
            end
        end
    end
    return relist
end
--获取等级对应的某一项数据
function __this.getDataListTypeData( type,s_type )
    type = type or __this.curType
    local redata = nil
    local cur_level = gameData.getSimpleDataByKey("team_level")
    if s_type then
        local levellist = __this.getDataListType(type,s_type)
        if levellist then
            for k,v in pairs(levellist) do
                if v.level <= cur_level then
                    redata = v
                else
                    break
                end
            end
        end
    end
    return redata
end

function __this.setCurType( curType )
    __this.curType = curType
    __this.updateDataUI()
end
--相关点击事件处理
function __this.clickStype( curType )
    -- body
end

function __this.getPointAll( ... )
    local allpoint = 0
    local openCount = 0
    for i=1,4 do
        if __this.cheakOpen(i) then
            openCount = openCount + 1
            allpoint = allpoint + __this.getPointType(i)
        end
    end
    allpoint = math.floor(allpoint / openCount)
    return allpoint
end

function __this.getPointType( type )
    type = type or __this.curType
    local curlist = __this.getDataListCurType(type)
    local point = 0
    if __this.cheakOpen(type) then
        local count = 0
        for k,v in pairs(curlist) do
            if v then
                local addPoind = __this.getPointTypeStype(type,v.s_type)
                point = point + addPoind
                count = count + 1
            end
        end
        point = math.floor(point / count)
    end
    return point
end

function __this.getPointTypeStype( type,stype )
    local curjdata = __this.getDataListTypeData(type,stype)
    local point = 0
    local value = __this.getValueTypeStype(type,stype)
    if curjdata then
        point =math.min(math.floor(value / curjdata.grate_s * 100),100) 
    end
    return point
end

function __this.getDatalistKeyValueSum( list,key )
    local count = 0
    if list then
        for k,v in pairs(list) do
            if v and v[key] then
                count = count + v[key]
            end
        end
    end
    return count
end

function __this.getValueTypeStype( type,stype )
    local value = 0
    type = type or __this.curType
    if type and stype then
        if type == 1 or type ==2 then --英雄 图腾
            local formatlist = FormationData.getTypeData(const.kFormationTypeCommon)
            if type == 1 then
                local soldierlist = {}
                for k,v in pairs(formatlist) do
                    if v and v.attr == const.kAttrSoldier and v.guid~=0 then
                        local soldier = SoldierData.getSoldier(v.guid)
                        if soldier then
                            table.insert(soldierlist,soldier)
                        end
                    end
                end
                if stype == 1 then --品质
                    value = __this.getDatalistKeyValueSum(soldierlist,"quality")
                elseif stype ==2 then --星级
                    value = __this.getDatalistKeyValueSum(soldierlist,"star")
                elseif stype ==3 then --数量
                    value = #SoldierData.getTable()
                end
            elseif type == 2 then -- 图腾
                local formtotemlist = {}
                for k,v in pairs(formatlist) do
                    if v and v.attr == const.kAttrTotem and v.guid~=0 then
                        local totem = TotemData.getTotem(v.guid)
                        if totem then
                            table.insert(formtotemlist,totem)
                        end
                    end
                end
                if stype == 1 then --能力
                    value = __this.getDatalistKeyValueSum(formtotemlist,"level")
                elseif stype ==2 then --数量
                    value = #TotemData.getData()
                end
            end
        elseif type == 3 then --装备套装战力
            local equip_type = const.kEquipPlate
            if stype == 1 then --板
                equip_type = const.kEquipPlate
            elseif stype ==2 then --锁
                equip_type = const.kEquipMail
            elseif stype ==3 then -- 皮
                equip_type = const.kEquipMail
            elseif stype ==4 then --布
                equip_type = const.kEquipCloth
            end
            value = EquipmentData:getEquipmentScoreForSuit( equip_type)
        elseif type == 4 then -- 神符
            local templelist = TempleData.getData().glyph_list
            if stype == 1 then --等级
                value = __this.getDatalistKeyValueSum( templelist,"level")
            elseif stype ==2 then --品质
                for k,v in pairs(templelist) do
                    if v and v.id then
                        local jtemple = findTempleGlyph(v.id)
                        if jtemple then
                            value = value + jtemple.quality
                        end
                    end
                end
            end
        end
    end
    return value
end

function __this.getOldPoint( type,s_type )
    type = type or __this.curType
    if __this.valueMap[type] and s_type then
        return __this.valueMap[type][s_type]
    end
    return nil
end

function __this.updateValueMap( type,stype ,value)
    type = type or __this.curType
    if type and stype then
        if __this.valueMap[type] == nil then
            __this.valueMap[type] = {}
        end
        __this.valueMap[type][stype] = value
    end
end

function __this.cheakOpen( type ,showTips)
    local result = false
    local openTips = ""
    if type then
        local type_list = __this.getDataListType(type)
        if type_list and #type_list > 0 then
            local data = type_list[1]
            if data and data.open_type and data.open_term then
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
                    elseif data.open_type == 6 then --相关建筑
                        result = BuildingData.checkBuildingOpen(data.open_term)
                        openTips = "建筑未开启"
                    end
                    if data.open_desc and data.open_desc ~= "" then
                        openTips = data.open_desc
                    end
                    if showTips and not result then
                        TipsMgr.showError(openTips)
                    end
                end
            end
        end
    end
    return result,openTips
end

function __this.showUIByName( name )
    local canshow = false
    if __this.curStype ~= 0 then
        if name == "SoldierUI" and __this.curType == 1 then
            canshow = true
        end
        if name == "TotemUI" and __this.curType == 2 then
            canshow = true
        end
        if name == "EquipmentUI" and __this.curType == 3 then
            canshow = true
        end
        if name == "TempleUI" and (__this.curType == 4 or __this.curType == 1 )then
            canshow = true
        end
    end
    if canshow then
        Command.run("ui show","FightPowerUI")
        EventMgr.removeListener( EventType.HideWinName, function(name)
        __this.showUIByName(name)
    end )
    end
end

function __this.itemClickHandle( type )
    if __this.curType and type then
        __this.curStype = type
        if __this.curType == 1 then --英雄
            if __this.curStype == 3 then --打开神殿中英雄收集那切页
                if __this.cheakOpen(4,true) then
                    Command.run("ui show","TempleUI")
                else
                     __this.curStype = 0
                    return
                end
            else
                Command.run("ui show","SoldierUI")
            end
        elseif __this.curType == 2 then --图腾
            Command.run("ui show","TotemUI")
        elseif __this.curType == 3 then --装备
            Command.run("ui show","EquipmentUI")
        elseif __this.curType == 4 then --神符
            Command.run("ui show","TempleUI")
        end
        Command.run("ui hide","FightPowerUI")
        EventMgr.addListener( EventType.HideWinName, function(name)
        __this.showUIByName(name)
    end )
    end
end



