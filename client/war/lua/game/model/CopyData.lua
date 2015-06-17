

-- 搜索事件名称
local searchName = {}
searchName[const.kCopyEventTypeBox]     = "宝箱"      -- 2
searchName[const.kCopyEventTypeReward]  = "奖励"      -- 3
searchName[const.kCopyEventTypeGut]     = "剧情"      -- 4
searchName[const.kCopyEventTypeShop]    = "商人"      -- 5
searchName[const.kCopyEventTypeFight]   = "战斗"      -- 6
searchName[const.kCopyEventTypeFightMeet] = "迎敌"    -- 7

local __this = {}
--副本SUserData部分镜象数据, 用于存放用户离线敏感镜象信息
__this.user = {}
-- 当前剧情id
__this.currGid = 0
-- 精英副本开放等级
__this.elite_open_level = tonumber(findGlobal("elite_boss_open_level").data)
-- 当前在副本使用体力
__this.strength = 0
-- 当前打开的副本区域信息
__this.area_id = 0
__this.area_type = const.kCopyMopupTypeNormal
__this.boss_id = 0
__this.copy_id = 0

--最新副本id[用于记录最新副本建筑物表现标识]
__this.new_copy_id = 0
function __this.setCurrAreaInfo(area_id, area_type, boss_id, copy_id)
    __this.area_id = area_id
    __this.area_type = area_type
    __this.boss_id = boss_id or 0
    __this.copy_id = copy_id or 0
end
-- 获得的boss奖励
__this.getBossReward = nil
-- 测试标志 是否第一次进入副本
__this.isFirstInto = false
-- 攻打怪物是否boss
__this.isMonsterBoss = false
-- 是否遇怪
__this.isMetBoss = false
-- 需存储的战斗信息
__this.fightData = nil
-- 前一个副本id
__this.pre_copy_id = 0
-- 新出现的普通boss
__this.newNormalBoss = nil
-- 新出现的精英boss
__this.newEliteBoss = nil
-- 是否攻打boss
__this.isFightBoss = false
-- 攻打boss的类型
__this.fightBossType = 0
-- 攻打boss的id
__this.fightBossID = 0
--攻打boss的副本id
__this.fightBossCopyId = 0
-- 进入探索副本的id
__this.into_copy_id = 0
-- 获得星星数据
__this.starReward = nil
-- 当前获得的新区域boss列表
__this.newAreaBossList = {}
-- 当前所拥有的区域boss列表
__this.areaBossList = {}
-- 是否需要刷新副本数据
__this.isNeedRefurish = false
-- 当前是否请求服务器信息
__this.isSendMsg = false
-- 战斗是否升级
__this.isTeamUpgrade = false
-- 副本探索声音
__this.stepSound = "footstep_floor"

__this.CopyIdList = nil --副本id列表

-- 重置副本参数，打开CopyUIScene时调用
function __this.clearCopyParam()
    __this.isMonsterBoss = false
    -- __this.isFightBoss = false
    -- __this.fightBossType = 0
    __this.fightBossID = 0
    __this.starReward = nil
    __this.getBossReward = nil
end

function __this.getCopyName(id)
    local jCopy = findCopy(id)
    return jCopy and jCopy.name or id
end

-------------- 区域副本开通相关 -------------------
-- 初始化当前所通关的区域列表
function __this.initAreaBossList()
    local id = __this.getMaxPassCopy()
    if id ~= 0 then
        local areas = math.floor(id / 1000)
        for i = 1, areas do
            if nil == __this.areaBossList[i] then
                __this.areaBossList[i] = {[const.kCopyMopupTypeNormal] = {}, [const.kCopyMopupTypeElite] = {}}
            end
            __this.areaBossList[i][const.kCopyMopupTypeNormal] = __this.getPassBossList(i, const.kCopyMopupTypeNormal)
            __this.areaBossList[i][const.kCopyMopupTypeElite] = __this.getPassBossList(i, const.kCopyMopupTypeElite)
        end
    end
end
-- 是否已有当前boss卡牌
function __this.hasAreaBoss(area_id, stype, boss_id)
    if nil ~= __this.areaBossList then
        if nil ~= __this.areaBossList[area_id] then
            local list = __this.areaBossList[area_id][stype]
            if nil ~= list then
                for k, v in pairs(list) do
                    if v.boss_id == boss_id then
                        return true
                    end
                end
            end
        end
    end
    return false
end
-- 新增区域boss
function __this.addAreaBoss(area_id, stype, boss)
    if __this.areaBossList[area_id] == nil then
        __this.areaBossList[area_id] = {[const.kCopyMopupTypeNormal] = {}, [const.kCopyMopupTypeElite] = {}}
    end
    table.insert(__this.areaBossList[area_id][stype], boss)
end
-- 获取当前副本的boss id 为 当前副本 (id / 10)
function __this.getCopyBoss(id, stype)
    local boss_id = (id - 1) * 100 + 1
    if stype == const.kCopyMopupTypeElite then boss_id = boss_id * 10 end
    return {copy_id = id, boss_id = boss_id, type = stype}
end
-- 获取area_id区域的boss列表
function __this.getAreaBossList(area_id, isPass)
    LogMgr.debug(">>>>>>>>>>>>getBossList : area = " .. area_id)
    if nil == isPass then isPass = false end
    local list = {}
    local copy_id = __this.user.copy.copy_id
    local group_id = math.floor(copy_id / 10)
    local area = findArea(area_id)
    local len = #area.copy
    LogMgr.debug(">>>>>>>>>>>len = " .. len)
    for i = 1, len do
        LogMgr.debug(">>>>>>>>> " .. area.copy[i] .. " , " .. group_id)
        if area.copy[i] > group_id then break end
        local tmp = __this.getCopyBoss(area.copy[i])
        if tmp.copy_id < copy_id then
            table.insert(list, v)
        end
    end
    return list
end

-- stype 为 boss类型 ， k 为boss_id ，v 为回合数
function __this.getBossData(area_id, stype, boss_id, v)
--    LogMgr.debug(">>>>> getBossData: area = " .. area_id .. " , type = " .. stype .. " id = " .. k)
    local u_id = math.floor(boss_id / 1000) * 10 + (boss_id % 10)
    if stype == trans.const.kCopyMopupTypeElite then
        u_id = math.floor(boss_id / 10000) * 10 + math.floor((boss_id % 100) / 10)
    else
        if v >= 255 then
            return nil
        end
    end
    -- local boss_id = k
    local copy_id = __this.user.copy.copy_id
    if copy_id == nil then copy_id = __this.getMaxPassCopy() end
    if math.floor(u_id / 1000) == area_id and u_id <= __this.user.copy.copy_id then
        return {copy_id = u_id, boss_id = boss_id, round = v, type = stype}
    end
    return nil
end
-- 添加新boss卡牌
function __this.addNewBoss(stype, boss_id, v)
    local u_id = math.floor(boss_id / 1000) * 10 + (boss_id % 10)
    if stype == trans.const.kCopyMopupTypeElite then
        u_id = math.floor(boss_id / 10000) * 10 + math.floor((boss_id % 100) / 10)
    end
    local area_id = math.floor(u_id / 1000)
    if false == __this.hasAreaBoss(area_id, stype, boss_id) then
        local data = __this.getBossData(area_id, stype, boss_id, v)
        if nil ~= data then
            if nil == __this.newAreaBossList[area_id] then
                __this.newAreaBossList[area_id] = {}
             end
            __this.newAreaBossList[area_id][stype] = data
            __this.addAreaBoss(area_id, stype, data)
        end
        LogMgr.debug(">>>>>>>>>>添加Boss：" .. debug.dump(data))
    else
        LogMgr.debug(">>>>>>>>>>已经有该Boss：area_id = " .. area_id .. " , type = " .. stype .. " , id = " .. boss_id)
    end
end
-- 判断stype类型的boss_id是否通关
function __this.hasPassBoss(boss_id, stype, check)
    local mopup = gameData.user.mopup
    local round = mopup.normal_round
    if stype == trans.const.kCopyMopupTypeElite then
        round = mopup.elite_round
    end
    for k, v in pairs(round) do
        if k == boss_id then
            if not check and stype == const.kCopyMopupTypeElite then
                return true
            else
                if v < 255 then
                    return true
                end
            end
            break
        end
    end
    return false
end
-- 获取area_id区域已通关的boss列表
function __this.getPassBossList(area_id, stype)
    local list = {}

    local mopup = gameData.user.mopup
    local round = mopup.normal_round
    if stype == trans.const.kCopyMopupTypeElite then
        round = mopup.elite_round
    end

    LogMgr.debug(">>>>>>>>> pass : " .. debug.dump(round))
    for k, v in pairs(round) do
        local data = __this.getBossData(area_id, stype, k, v)
        if nil ~= data then
            table.insert(list, data)
        end
    end
    table.sort(list, function (a, b)  return a.copy_id < b.copy_id end)
    
    return list
end
-- 获取area_id区域stype类型的boss列表
function __this.getAreaPassBossList(area_id, stype)
    if nil == __this.areaBossList[area_id] then
        __this.areaBossList[area_id] = {[const.kCopyMopupTypeNormal] = {}, [const.kCopyMopupTypeElite] = {}}
    end
    local list = __this.areaBossList[area_id][stype]

    return list
end
-- 获取stype类型的area_id区域是否有新Boss，用于打开区域添加新副本时的表现效果
function __this.getNewBoss(area_id, stype)
    if __this.newAreaBossList[area_id] ~= nil then
        return __this.newAreaBossList[area_id][stype]
    end
    return nil
end
-- 获取area_id区域的stype类型的有效副本
function __this.getAreaCopyList(area_id, stype, check, checkArea)
    local id = __this.getNextCopyId()
    local area = findArea(area_id)
    local list = {}
    local copy = area.copy
    local areaFlag = nil
    for i = 1, #copy do
        if copy[i] ~= 0 and copy[i] ~= nil then
            local copy_id = copy[i] * 10 + 1
            if not check then
                table.insert(list, copy_id)
            else
                if id >= copy_id then
                    if stype == const.kCopyMopupTypeElite then
                        local boss = __this.getCopyBoss(copy_id, stype)
                        if nil ~= boss then
                            if areaFlag or true == __this.hasPassBoss(boss.boss_id, stype) then
                                table.insert(list, copy_id)

                                if checkArea then
                                    areaFlag = true
                                end
                            end
                        end
                    else
                        table.insert(list, copy_id)
                    end
                end
            end
        end
    end
    return list
end
-- 获取当前所有通关区域
function __this.getAllAreaCopyList()
    local normalCopyList, eliteCopyList = {}, {}
    local id = __this.getNextCopyId()
    -- if __this.checkOpenAreaBy(id) == false then
    --     id = __this.getMaxPassCopy()
    -- end
    local len = math.floor(id / 1000)
    for i = 1, len do
        local normalList = __this.getAreaCopyList(i, const.kCopyMopupTypeNormal)
        local eliteList = __this.getAreaCopyList(i, const.kCopyMopupTypeElite, true, true)
        if #normalList > 0 then normalCopyList[i] = normalList end
        if #eliteList > 0 then eliteCopyList[i] = eliteList end
    end
    local list = {[const.kCopyMopupTypeNormal] = normalCopyList, [const.kCopyMopupTypeElite] = eliteCopyList}
    return list
end

-------------- 副本获得星数相关 ---------------
-- 根据死亡人数计算所得星数
function __this.getStars(rounds)
    local stars = 0
    if rounds == 0 then
        stars = 3
    elseif rounds == 1 then
        stars = 2
    elseif rounds >1 and rounds < 255 then
        stars = 1
    end
    return stars
end
-- 计算与上一次的星数比较，若大于上一次的星数，则赋值给__this.starReward
function __this.getComStars(copy_id, prevRound, nextRound)
    local prevStars = __this.getStars(prevRound)
    local nextStars = __this.getStars(nextRound)
    local stars = nextStars - prevStars
    if stars > 0 then
        __this.starReward = {copy_id = copy_id, star = stars}
    end
end
-- 获取已打败boss的星数 , boss_id 为 boss的id , boss_type 为 boss类型
function __this.getBossStars(boss_id, boss_type)
    local stars = 0
    local mopup = gameData.user.mopup
    local map = mopup.normal_round
    if boss_type == 2 then
        map = mopup.elite_round
    end
    -- LogMgr.debug(">>>>>>>>>>> CopyLog: " .. debug.dump(mopup))
    local rounds = map[boss_id]
    if nil ~= rounds then
        if rounds == 0 then
            stars = 3
        elseif rounds == 1 then
            stars = 2
        elseif rounds >1 and rounds < 255 then
            stars = 1
        end
    end
    return stars
end
-- 获取id副本所获得的星数
function __this.getCopyStars(id, stype)
    local guage, count = 0, 3

    local boss = __this.getCopyBoss(id, stype)
    guage = __this.getBossStars(boss.boss_id, stype)

    return guage, count
end
-- 获取当前副本所获取的星数
function __this.getCurCopyStars()
    if not CopyMgr.bossData then
        return 0
    end

    return CopyData.getCopyStars(CopyMgr.bossData.copy_id, CopyMgr.bossData.type)
end
-- 获取area_id区域stype类型已获得的星数
function __this.getAreaGetStar(area_id, stype)
    local stars = 0
--    local u_copy = __this.user.copy
    local copy_id = __this.getMaxPassCopy()--u_copy.copy_id

    local mopup = gameData.user.mopup
    local round = mopup.normal_round
    if stype == trans.const.kCopyMopupTypeElite then
        round = mopup.elite_round
    end

    for k, v in pairs(round) do
        local u_id = math.floor(k / 1000) * 10 + (k % 10)
        if stype == const.kCopyMopupTypeElite then
            u_id = math.floor(k / 10000) * 10 + math.floor((k % 100) / 10)
        end
        if math.floor(u_id / 1000) == area_id and u_id <= copy_id then
            stars = stars + __this.getStars(v)
        end
    end

    return stars
end
-- 获取area_id的所有星数
function __this.getAreaAllStars(area_id)
    local count = 0

    local u_copy = __this.user.copy
    local area = findArea(area_id)

    local len = #area.copy
    for j = 1, len do
        local group_id = area.copy[j]
        for i = 1, 9 do
            local copy_id = group_id * 10 + i
            local s_copy = findCopy( copy_id )
            if s_copy == nil then
                break
            end
            
            if s_copy.type == const.kCopyTypeBoss then
                count = count + 3
            end
        end
    end

    return count
end
-- 获取通关奖励状态
function __this.getPresentType(area_id, showType, curr, max)
    -- 0:未开放  1:未通关  2:通关未领取    3:未满星   4:满星未领取 5:满星已领取
    local isGet = 0 
    local list = __this.getAllAreaCopyList()
    if not list[showType] or not list[showType][area_id] then
        return isGet
    end

    local __l = list[showType][area_id]
    local maxCopyId = __this.getMaxPassCopy(showType, true)
    isGet = 1
    if maxCopyId < __l[#__l] then
        return isGet
    end

    isGet = 2
    local log = gameData.user.area_log_map
    local obj = log[area_id]
    if not obj then
        return isGet
    end
    if const.kCopyMopupTypeNormal == showType then
        if 0 == obj.normal_pass_take_time then
            return isGet
        end

        isGet = 3
        if curr ~= max then
            return isGet
        end

        isGet = 4
        if 0 == obj.normal_full_take_time then
            return isGet
        end

        isGet = 5
        return isGet
    end

    if 0 == obj.elite_pass_take_time then
        return isGet
    end

    isGet = 3
    if curr ~= max then
        return isGet
    end

    isGet = 4
    if 0 == obj.elite_full_take_time then
        return isGet
    end

    isGet = 5
    return isGet

    -- if curr == max then
    --     isGet = 1
    --     local log = gameData.user.area_log_map
    --     local obj = log[area_id]
    --     local take_time = 0
    --     if nil ~= obj then
    --         if showType == const.kCopyMopupTypeNormal then
    --             take_time = obj.normal_take_time 
    --         else
    --             take_time = obj.elite_take_time
    --         end
    --         if nil ~= take_time and take_time > 0 then
    --             isGet = 2   
    --         end
    --     end
    -- end
    -- return isGet
end

--------------- 副本进度及开放 -------------------
-- 获取id副本的日志
function __this.getCopyLogById(id)
    local map = gameData.user.copy_log_map
    for k,v in pairs(map) do
        if v.copy_id == id then
            return v
        end
    end
    return nil
end

--获取当前副本或通关的最大副本ID
function __this.getMaxCopyId()
    local curCopyId = gameData.user.copy.copy_id
    if curCopyId == 0 then
        curCopyId = CopyData.getMaxPassCopy() --最大通关副本ID
    end
    return curCopyId
end

--TODO:需要优化
-- 获取当前已通关的最后一个副本id
function __this.getMaxPassCopy(stype, check)
    local log = gameData.user.copy_log_map
    local id = 0
    if log then
        for k, v in pairs(log) do
            if id < k then
                if stype and const.kCopyMopupTypeElite == stype then
                    local boss = __this.getCopyBoss(k, stype)
                    if boss and __this.hasPassBoss(boss.boss_id, stype, check) then
                        id = k
                    end
                else
                    id = k
                end
            end
        end
    end
    return id
end
--获取当前于某星通关的最高副本
function __this.getMaxPassCopyStart( start,stype )
    local log = gameData.user.copy_log_map
    local id = 0
    for k, v in pairs(log) do
        if id < k and __this.getCopyStars(k,stype) >= start then
            if stype and const.kCopyMopupTypeElite == stype then
                local boss = __this.getCopyBoss(k, stype)
                if boss and __this.hasPassBoss(boss.boss_id, stype) then
                    id = k
                end
            else
                id = k
            end
        end
    end
    return id
end
-- 获取当前副本id
function __this.getNextCopyId(stype)
    local lastId = __this.getMaxPassCopy(stype)
    if stype and const.kCopyMopupTypeElite == stype then
        return lastId
    end
    if not CopyIdList then
        CopyIdList = {}
        local copy_list = GetDataList( 'Copy' )
        for k,v in pairs(copy_list) do
            table.insert(CopyIdList, k)
        end
        table.sort(CopyIdList)
    end
    local index = Algorithm.binarySearch(CopyIdList, lastId)
    return CopyIdList[index + 1] or 0
end

-- 获取copy_id副本的进度，返回 当前进度 及 总进度数
function __this.getCopyGuage(copy_id)
    local guage = 0
    local count = 0
    
    local s_copy = findCopy( copy_id )
    guage = s_copy.guage
    count = count + s_copy.guage
    
    local u_copy = __this.user.copy
    if u_copy.copy_id == copy_id then
        guage = u_copy.posi
        count = #u_copy.chunk
    end
    
    return guage, count
end
-- 获取当前的副本进度
function __this.getCurrCopyGuage()
    local u_copy = __this.user.copy
    if u_copy.copy_id == 0 then
        return 0, 0
    end
    return __this.getCopyGuage(u_copy.copy_id)
end
--根据bossId获取副本id
function __this.getCopyIdByBossId(stype, monsterId)
    local u_id
    if stype == trans.const.kCopyMopupTypeElite then
        u_id = math.floor(monsterId / 10000) * 10 + math.floor((monsterId % 100) / 10)
    else
        u_id = math.floor(monsterId / 1000) * 10 + (monsterId % 10)
    end
    return u_id
end
--检测副本是否通关
function __this.checkClearance( copyId )
    local id = __this.getMaxPassCopy()
    return id >= copyId
end
--检测副本是否通关id1 and  未通关 id2
function __this.checkNotClearance( id1, id2, page )
    return __this.area_id == page and SceneMgr.isSceneName("copyUI") and __this.checkClearance( id1 ) and (not __this.checkClearance( id2 ) ) and CopyData.getNextCopyId(const.kCopyMopupTypeNormal) == id2
end
function __this.checkOpenAreaBy(copy_id, level, area_id)
    local copy = findCopy(copy_id)
    -- if copy.level == 5 then return false end
    level = level or gameData.user.simple.team_level
    if not copy then
        return false, "副本不存在！"
    end

    if level < copy.level then
        local area = findArea(area_id)
        if not area then
            return false
        end

        return false, "战队等级达到" .. area.level .. "级开启"
    end

    if copy.task > 0 and not TaskData.hasLogTask( copy.task ) then
        return false, "需要完成前置任务"
    end

    return true
end

function __this.checkOpenCopy( copy_id, not_show )
    local copy = findCopy(copy_id)
    local level = gameData.user.simple.team_level
    if not copy then
        if not not_show then
            TipsMgr.showError(  "副本不存在！" )
        end
        return false
    end

    if level < copy.level then
        if not not_show then
            TipsMgr.showError(  "战队等级达到" .. copy.level .. "级开启" )
        end
        return false
    end

    if copy.task > 0 and not TaskData.hasLogTask( copy.task ) then
        if not not_show then
            TipsMgr.showError(  "需要完成前置任务" )
        end
        return false
    end

    return true
end
-- 检测area_id区域是否开通
function __this.checkOpenArea(area_id)
    local copy_id = (area_id * 100 + 1) * 10 + 1
    return __this.checkOpenAreaBy(copy_id, nil, area_id)
end
-- 检测stype类型的copy_id副本是否开放
function __this.checkOpenCopyBy(copy_id, stype)
    if stype == const.kCopyMopupTypeElite then
        local boss = __this.getCopyBoss(copy_id, stype)
        if nil ~= boss then
            return __this.hasPassBoss(boss.boss_id, stype)
        end
    else
        local cid = __this.getNextCopyId()
        if copy_id <= cid then
            return true
        end
        -- if copy.level <= gameData.user.simple.team_level then
        --     return true
        -- end
    end
    return false
end

--------------- 副本内的一些数据 -------------------
-- 获取当前副本下一场战斗的数据，预加载用
function __this.getNextFight()
    local u_copy = __this.user.copy
    local u_chunk = u_copy.chunk
    local posi = u_copy.posi + 1
    for i = posi, #u_chunk do
        local chunk = u_chunk[i]
        if chunk.cate == const.kCopyEventTypeFightMeet then
            return u_copy.fight[chunk.val]
        elseif const.kCopyEventTypeFight == chunk.cate then
            return u_copy.fight[1]
        end
    end
    return nil
end
-- 获取在副本内当前攻打的boss
function __this.getCurrCopyMonster()
    local u_copy = __this.user.copy
    local chunk = __this.getCurrChunk()

    local monster_id = 0
    if chunk.cate == const.kCopyEventTypeFightMeet then
        monster_id = chunk.objid
    end

    return {copy_id = u_copy.copy_id, monster_id = monster_id}
end
-- 获取当前副本背景音乐路径
function __this.getCurrCopyMusic()
    -- local copy_id = __this.user.copy.copy_id
    local copy_id = __this.getNextCopyId()
    local copy = findCopy(copy_id)
    return copy and copy.bg_sound
end
-- 获取副本场景背景地图，copyId为副本id，默认为当前副本id
function __this.getCopyMap(copyId)
    if copyId == nil then copyId = __this.user.copy.copy_id end
    local data = findCopy(copyId)
    local copy = data.mapid.first
    return copy
end
-- 获取副本场景内战斗背景，copyId 副本ID，如果为nil，则使用当前副本ID
function __this.getWarMap(copyId)
    local data = findCopy(copyId or __this.user.copy.copy_id)
    local copy = nil
    if nil ~= data then
        copy = data.mapid.second
    end
    return copy
end

--------------- 副本探索体力 等操作 ---------------
-- 获取每次探索所需体力
function __this.getChunkStrength()
    -- LogMgr.log("copy", ">>>>>>>>>>>>>>getChunkStrength ")
    local copy = __this.user.copy
    local chunk = copy.chunk[ copy.posi + 1 ]
    local reward = copy.reward[copy.posi + 1]

    if not chunk or not reward then
        return 0
    end

    if chunk.cate == const.kCopyEventTypeFightMeet then
        if copy.index == 0 then
            -- LogMgr.log("copy", ">>>>>>>>>>>>>>本次探索需扣 " .. reward.cate)
            return reward.cate
        else
            local m_id = chunk.objid
            local monster = findMonster(m_id)
            -- LogMgr.log("copy", ">>>>>>>>>>>>>>本次探索需扣 " .. monster.strength)
            return monster.strength
        end
    else
        -- LogMgr.log("copy", ">>>>>>>>>>>>>>本次探索需扣 " .. reward.cate)
    end

    return reward.cate
end
-- 扣取当前探索体力
function __this.useChunkStrength()
    LogMgr.log("copy", ">>>>>>>>>>>>>>useChunkStrength ")
    local useStrength = CopyData.getChunkStrength()

    __this.strength = __this.strength + useStrength
    local strength = gameData.user.simple.strength - __this.strength
    LogMgr.debug(">>>>>>>>>> 减体力后，体力值为：" .. strength)
    if strength >= 0 then
        MainUIMgr.getRoleTop():setValue("con_strength", strength)
    end
    
    return useStrength
end
-- 是否足够体力探索
function __this.enabledSearch()
    LogMgr.log("copy", ">>>>>>>>>>>>>>enabledSearch ")
    local strength = __this.getChunkStrength()
    local totalStr = gameData.getSimpleDataByKey("strength")
    if strength and __this.strength and totalStr then
        return totalStr - __this.strength >= strength
    end
    return false
end
-- 获取探索事件类型
function __this.getSearchName(cate)
    return searchName[cate]
end
-- 获取当前探索chunk
function __this.getCurrChunk()
    local u_copy = __this.user.copy
    local chunk = u_copy.chunk[ u_copy.posi + 1 ]
    
    return chunk
end

------- 有关材料 --------
__this.materialList = {}

function __this.setMaterialList(list)
    __this.materialList = {}
    if #list > 0 then
        for _, v in pairs(list) do
        		if v.copy_id ~= nil then
            		__this.materialList[v.copy_id] = v
            end
        end
    end
end
function __this.updateMaterialList(material)
    local list = gameData.user.copy_material_list
    for k,v in pairs(list) do
        if v.copy_id == material.copy_id then
            table.remove(list, k)
        end
    end
    __this.materialList[material.copy_id] = nil
end
function __this.getMaterialList()
    return __this.materialList
end
function __this.getCopyMaterial(copy_id)
    return __this.materialList[copy_id]
end

--副本满星宝箱 信息
function __this.getCopyAreaReward( data )
    local area_id = data.area_id
    local showType = data.showType

    local curr, max = CopyData.getAreaGetStar(area_id, showType), CopyData.getAreaAllStars(area_id)
    local isGet = __this.getPresentType(area_id, showType, curr, max)

    local json = findArea(area_id)
    if not json then
        return nil
    end

    local reward_id = nil
    if 0 == isGet or 1 == isGet or 2 == isGet then
        if const.kCopyMopupTypeElite == showType then
            reward_id = json.elite_pass_reward
        else
            reward_id = json.normal_pass_reward
        end
    else
        if const.kCopyMopupTypeElite == showType then
            reward_id = json.elite_full_reward
        else
            reward_id = json.normal_full_reward
        end
    end

    local reward = findReward(reward_id)
    if nil ~= reward then
        return reward.coins,isGet
    end
end


__this.curSelectUI = const.kCopyMopupTypeNormal

---副本Boss攻略
__this.bossRecordID = 0
__this.bossRecordData = {} --id=>{record}
__this.bossRecordTime = {} --请求的时间id=>{time}
__this.firstCallback = nil --第一场战斗刷新副本回调

CopyData = __this
