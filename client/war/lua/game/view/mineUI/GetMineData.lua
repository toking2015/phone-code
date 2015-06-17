--金矿需要读取得数据
--by weihao  
getMineData = {}
getMineData.building = nil       --建筑
getMineData.buildingId = nil     --建筑id
getMineData.buildingLevel = nil  --建筑等级
getMineData.prodSpeed = nil      --金矿产生速度
getMineData.curMineCount = nil   --现在金矿产出的数量
getMineData.maxMineCount = nil   --最大容量
getMineData.addSpeed = nil       --比下级添加多少速度
getMineData.addMineCount = nil   --比下级添加多少容量
getMineData.requireGrade = nil   --升级需要达到的等级
getMineData.oldtime = 0   --获取收取时间

getMineData.key = "getMineDatakey"  
getMineData.isget = false --是否收集
getMineData.isCoin = false --是否有气泡
function getMineData.getBuildingData()
    local u_building = BuildingData.getDataByType(const.kBuildingTypeGoldField)
    if u_building ~= nil then 
        getMineData.oldtime = u_building.ext.time_point
        getMineData.buildingId = u_building.guid
        getMineData.buildingLevel = u_building.data.info_level
        getMineData.curMineCount = u_building.ext.production
        local speedData = findBuildingSpeed(getMineData.buildingLevel)
        if nil ~= speedData then
            local nextSpeedData = findBuildingSpeed(getMineData.buildingLevel )
            if  getMineData.buildingLevel < 10 then  
                nextSpeedData = findBuildingSpeed(getMineData.buildingLevel + 1)
            end 
            getMineData.prodSpeed = speedData.speed2
            getMineData.addSpeed = nextSpeedData.speed2 - getMineData.prodSpeed
            getMineData.maxMineCount = speedData.speed2 * 8 * 60
            local nextMaxMineCount = nextSpeedData.speed2 * 8 * 60
            getMineData.addMineCount = nextMaxMineCount - getMineData.maxMineCount
            -- 暂时10为顶峰数值
            if getMineData.buildingLevel < 10 then  
--                getMineData.requireGrade = findBuildingUpgrade(getMineData.buildingLevel + 1).u_level_[const.kBuildingTypeGoldField]

                local list = GetDataList('BuildingUpgrade')[const.kBuildingTypeWaterFactory]
--                LogMgr.debug("getMineData.buildingLevel .. " .. getMineData.buildingLevel)
                getMineData.requireGrade = tonumber(list[getMineData.buildingLevel+1].u_level )
--                LogMgr.debug("getMineData.requireGrade .. " .. getMineData.requireGrade)
            else 
                getMineData.requireGrade = 10
            end 
        end
    else
        getMineData.buildingId = 1006     --建筑id
        getMineData.buildingLevel = 1  --建筑等级
        getMineData.prodSpeed = 1      --金矿产生速度
        getMineData.curMineCount = 1   --现在金矿产出的数量
        getMineData.maxMineCount = 1   --最大容量
        getMineData.addSpeed = 1       --比下级添加多少速度
        getMineData.addMineCount = 1   --比下级添加多少容量
        getMineData.requireGrade = 1   --升级需要达到的等级
        getMineData.oldtime = 0   --获取收取时间
    end 

end
-- 根据时间求气泡等级
local function chargeBubbleLevel(time)
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
--获取气泡时间
local function timeInterval()
    getMineData.getBuildingData()
    local servTime = GameData.getServerTime()
    local extTime = getMineData.oldtime
    local second  = ((getMineData.curMineCount)/getMineData.prodSpeed)*60 -- 经历过的秒数
    
--    extTime = servTime - second
    return (servTime - extTime + second)/60 
end

function getMineData.Update()
    local time = timeInterval() 
    local timelevel = chargeBubbleLevel(time)
    if timelevel >=1 and timelevel <=10 then 
       --展示等级
       if getMineData.isget == false then 
           EventMgr.dispatch(EventType.MineBubbleShow,timelevel)
           getMineData.isget = false
       end
    else 
       EventMgr.dispatch(EventType.HideMine)
    end    
end

