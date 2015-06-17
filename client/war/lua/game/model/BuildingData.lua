local __this = BuildingData or {}
BuildingData = __this

local MaxSpeedTimes = 200
local MaxBuildingLevel = 10

function __this.clear()
    --因为建筑开启而需要隐藏的建筑
    --icon => true
    __this.hideMap = {}
end
__this.clear()
EventMgr.addListener(EventType.UserLogout, __this.clear)

function __this.getList()
    return gameData.user.building_list or {}
end

function __this.addBuilding(msg)
	gameData.changeArray( BuildingData.getList(), 'building_type', msg.set_type, msg.building )
    LogMgr.log( 'building', debug.dump(msg) )
    EventMgr.dispatch( EventType.UserBuildingUpdate, {data = msg.building} )
end

function __this.getDataByType(type)
    local list = BuildingData.getList()
    local building = gameData.findArrayData(list, "building_type", type)
--    if (building == nil) then
--        building = {building_type = type, building_guid = 0, data = {info_type = type, info_level = 1}, ext = {production = 0, time_point = 0}}
--    	table.insert(list, building)
--    end
    return building
end

function __this.getBuildingLevel(type)
    local u_building = __this.getDataByType(type)
    if nil == u_building then
        LogMgr.debug("建筑不存在")
        return 0
    end
    return u_building.data.info_level
end

--检查建筑是否开启
function __this.checkBuildingExist(type)
    local building = BuildingData.getDataByType(type)
    if building == nil then
        return false
    else
        local data = findBuilding(type)
        local re_team, re_task, re_copy = data.common_open, data.task_open, data.copy_open
        local team_level = gameData.getSimpleDataByKey('team_level')
        local copy_id = CopyData.user.copy.copy_id
        local task = TaskData.getMianTask()
        local task_id = task and task.task_id or 0
        if team_level >= re_team and copy_id >= re_copy and task_id >= re_task then
            return true
        else
            return false
        end
    end
    return true
end

--根据建筑id获取它所在的页数
function __this.getPageById(id)
    local jBuilding = findBuilding(id)
    if jBuilding and jBuilding.icon then
        local page = math.floor(jBuilding.icon / 1000)
        return page
    end
    return 0
end

function __this.getBuildingProdSpeed(type, bLevel)
    if nil == bLevel then bLevel = __this.getBuildingLevel(type) end
    if type == trans.const.kBuildingTypeWaterFactory then
        return findBuildingSpeed(bLevel).speed6
    elseif type == const.kBuildingTypeGoldField then
        return findBuildingSpeed(bLevel).speed2
    else
        return 0
    end
end

-- 生成圣水的时间间隔
function __this.timeInterval(type)
    if type == nil then type = trans.const.kBuildingTypeWaterFactory end
    local u_building = BuildingData.getDataByType(type)
    if not u_building then
        return 0,0
    end
    local servTime = GameData.getServerTime()
    local extTime = u_building.ext.time_point
    -- local speedData = findBuildingSpeed(u_building.data.info_level).speed6
    local speedData = __this.getBuildingProdSpeed(type)
    local second  = (( u_building.ext.production)/speedData)*60 -- 经历过的秒数
    return (servTime - extTime + second )/60, (servTime - extTime + second )
end

-- 根据时间求气泡等级
function __this.chargeBubbleLevel(time)
    local lev = 0
    if time >= 10 and time < 58 then
        lev = 1
    elseif time >= 58 and time < 442 then
        lev = math.floor((time-10)/48) + 1
    elseif time >=442 then -- and time <= 480
        lev = 10
    end
    return lev
end

function __this.judgeBubbleByTime()
    local time, _ = __this.timeInterval() 
    local bubblelevel = __this.chargeBubbleLevel(time)
    if bubblelevel >=1 and bubblelevel <=10 then 
       -- 显示气泡
       EventMgr.dispatch(EventType.BuildingBubbleShow,{isShow = true, level = bubblelevel})
       -- return true, bubblelevel
    else 
       EventMgr.dispatch(EventType.BuildingBubbleShow,{isShow = false, level = 0})
       -- return false
    end 
end

function __this.getCurrProdCount(type)
    type = type or const.kBuildingTypeWaterFactory
    local u_building = BuildingData.getDataByType(type)
    if not u_building then
        return 0
    end
    local level = u_building.data.info_level
    if level == nil then level = 1 end
    if level > MaxBuildingLevel then level = MaxBuildingLevel end
    local production = u_building.ext.production
    -- local speed = tonumber(findBuildingSpeed(level).speed6)
    local speed = __this.getBuildingProdSpeed(type)
    local cur = math.floor((GameData.getServerTime() - u_building.ext.time_point)/60 * speed)
    cur = cur + production
    if cur > speed*8*60 then
        cur = speed*8*60
    end   

    return cur
end
-- 获取建筑当前加速次数
local stList = {[2] = "building_goldfiel_speed_time", [6] = "building_waterfactory_speed_time"}
local mtList = {[2] = "building_gold_times", [6] = "building_water_times"}
function __this.obtainSpeedTimes(type)
    if type == nil then type = trans.const.kBuildingTypeWaterFactory end
    local bType = stList[type]
    if VarData.getVarData()[bType] == nil then
        VarData.getVarData()[bType]= {}
        VarData.getVarData()[bType].value = 0
    end
   return VarData.getVarData()[bType].value
end
-- 
function __this.obtainCoinCount(type)
    if type == nil then type = trans.const.kBuildingTypeWaterFactory end
    local timesData = findBuildingCoin(type)
    if timesData == nil then
        LogMgr.error("type 错误")
        return 0
    end
    local lev = __this.getBuildingLevel(type)
    if lev == nil then lev = 1 end
    if lev > MaxBuildingLevel then lev = MaxBuildingLevel end
    local valueData = timesData.value[lev]
    return valueData and valueData.val or 0
end

function __this.getMaxSpeedTimes(type)
    if type == nil then type = trans.const.kBuildingTypeWaterFactory end
    local bType = mtList[type]
    local vip_level = gameData.getSimpleDataByKey('vip_level')
    if vip_level == nil then vip_level = 0 end
    if vip_level > 20 then vip_level = 20 end
    local speedTimes = findLevel(vip_level)[bType]
    if speedTimes == nil then
        LogMgr.debug("Vip等级对应的建筑加速不存在")
        speedTimes = 0
    end

    return speedTimes
end

-- 建筑随加速次数消耗的钻石数
function __this.consumeDiamond(type)
    if type == nil then type = trans.const.kBuildingTypeWaterFactory end
    local speedTimes = __this.obtainSpeedTimes(type) -- 当前加速次数
    speedTimes = speedTimes + 1
    if speedTimes >= MaxSpeedTimes then
        speedTimes = MaxSpeedTimes
    end
    local cost =  findBuildingCost(speedTimes)["cost"..type].val

    return cost
end

-- 十次加速花费钻石
function __this.tenConsumeDiamond(type)
    if type == nil then type = trans.const.kBuildingTypeWaterFactory end
    local speedTimes = __this.obtainSpeedTimes(type) -- 当前加速次数
    local cost = 0
    for i = speedTimes + 1, speedTimes + 10 do
        if i > MaxSpeedTimes then
            break
        end
        cost = findBuildingCost(i)["cost"..type].val + cost
        LogMgr.debug('i = ', i, 'cost = ', cost)
    end
    return cost
end

-- 根据建筑id判断除副本以外是否开放
function __this.checkBuildingOpen(id)
    local bData = findBuilding(id)
    if 1 ~= bData.run_open then
        return
    end
    return __this.checkBuildingExist(id)
end
