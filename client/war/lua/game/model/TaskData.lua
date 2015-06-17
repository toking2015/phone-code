local __this = TaskData or {}
TaskData = __this

local taskLogMap = {}
local levelDic = {}
local acceptTaskMap = {}

local 	taskTypeName = {}
taskTypeName[const.kTaskTypeMain] = "主线任务"
taskTypeName[const.kTaskTypeBranch] = "支线任务"
taskTypeName[const.kTaskTypeDayRepeat] = "日常任务"
taskTypeName[const.kTaskTypeActivity] = "活动任务"

function __this.clear()
	__this.finishTaskData = 1
	__this.openDayLevel = 10
	acceptTaskMap = {}
end
__this.clear()
EventMgr.addListener(EventType.UserLogout, __this.clear)

function __this.taskRewardIcon( coin )
	return CoinData.getCoinUrl( coin.cate, coin.objid )
end

function __this.taskData()
    return gameData.user.task_map
end

local function sortFunc(a, b) 
	local aCanFinsh = __this.checkTaskCanFinsh( a.task_id )
	local bCanFinsh = __this.checkTaskCanFinsh( b.task_id )
	local sortVal = false
	 if aCanFinsh == bCanFinsh then
	 	local aTask = findTask( a.task_id )
	 	local bTask = findTask( b.task_id )
	 	if aTask.team_level_min == bTask.team_level_min then
	 		sortVal = a.task_id < b.task_id
	 	else
	 		sortVal = aTask.team_level_min > bTask.team_level_min
	 	end
	 else
	 	sortVal = aCanFinsh	
	 end
	return sortVal
end

function __this.getTaskDataForType( theType )
	local list = {}
	local taskList = __this.taskData()
	local task = nil
	for k,v in pairs(taskList) do
		task = findTask( v.task_id )
		if task then
			if theType == task.type then
				if __this.checkShowTask( v, list ) then
					table.insert( list, v )
				end
			end
		end
	end
	table.sort(list, sortFunc)

	return list
end

function __this.getMianTask()
	local taskList = __this.taskData()
	local mainTaskList = {}
	local task = nil
	for k,v in pairs(taskList) do
		task = findTask( v.task_id )
		if task and task.type == const.kTaskTypeMain then
			table.insert( mainTaskList, task )
		end
	end

	table.sort(mainTaskList, sortFunc)
	if #mainTaskList > 0 then
		return mainTaskList[1]
	end
	return nil
end

function __this.getTaskDayMap()
	 return gameData.user.task_day_map
end

local const = trans.const

--[[
	const.kTaskCondGut		= 1		-- 完成剧情          1%[剧情Id]%0
	const.kTaskCondMonster		= 2		-- 击杀怪物          2%[怪物Id]%[击杀次数]
	const.kTaskCondCopyGuage		= 3		-- 副本完成度达成    3%[副本Id]%[完成度]
	const.kTaskCondCopyGroup		= 4		-- 副本集群完成      4%[集群Id]%0
	const.kTaskCondItem		= 5		-- 物品收集          5%[物品Id]%0
--]]

function __this.getTypeName(type)
	local typeName = taskTypeName[type]
	return typeName
end

function __this.getTaskDesc(task)
	local desc = ''
	if task.cond.cate == const.kTaskCondTime then
		local hour = GameData.getServerDate().hour
		desc = task.cond.objid..'点至'..task.cond.val..'点,可领取体力'
	elseif task.cond.cate == const.kTaskCondVipLevel then
		desc = task.desc .. '(VIP'.. gameData.getSimpleDataByKey("vip_level") .. ')'
	elseif task.cond.cate == const.kTaskCondMonthCard then
		local _, isOpen = PayData.checkCardValid() 
		if isOpen then
			local dayCount = PayData.getCardRemainDay()
			desc = task.desc ..'(剩余'.. dayCount.. '天)'
		else
			desc = task.desc ..'(未开通)'
		end
	else
	   	desc = task.desc
	end
	return desc
end

function __this.getTaskCoins( task )
	local coins = {}
	local coin = nil
	local level = nil
	if task.cond.cate == const.kTaskCondVipLevel then
		level = findLevel( gameData.getSimpleDataByKey("vip_level") ) 
		table.insert( coins, level.task_30001 )
	elseif task.cond.cate == const.kTaskCondMonthCard then
		level = findLevel( gameData.getSimpleDataByKey("vip_level") )
		table.insert( coins, level.task_30002 )
	else
	   	coins = task.coins
	end
	return coins
end

function __this.getTaskCoinVal(task)
	local val = 1
	if task.cond.cate ~= const.kTaskCondTime then
		val = task.cond.val
	end
	return val 
end

function __this.goToFinsh( data )
	if data then
		local cate = data.cond.cate
		if cate == const.kTaskCondCopyFinished or cate == const.kTaskCondBossKillCount or cate == const.kTaskCondBossKillId or cate == const.kTaskCondMonsterTeam or cate == const.kTaskCondMonster or cate == const.kTaskCondCopyGroup then
			--1、关副本的任务：打开副本UI（精英副本任务就切换到精英副本切页）
			local type = const.kCopyMopupTypeNormal
			local copyId = 0
			if cate == const.kTaskCondCopyFinished then
				copyId = data.cond.objid
			end

			if cate == const.kTaskCondBossKillCount then
				if data.cond.objid == 2 then
					type = const.kCopyMopupTypeElite
				end
			end
			
			Command.run("NCopyUI show copy", type, copyId )
		elseif cate == const.kTaskCondSoldierCollect or cate == const.kTaskCondSoldierQuality or cate == const.kTaskCondSoldierLevelUp then
			--2、英雄升级、搜集英雄、英雄升阶、英雄升星任务：打开英雄UI
			Command.run("ui show", "SoldierUI", PopUpType.SPECIAL)
		elseif cate == const.kTaskCondTotemLevel or cate == const.kTaskCondTotemSkillLevelUp then
			--3、图腾升级、搜集图腾、图腾升星任务：打开图腾UI
			Command.run("ui show", "TotemUI", PopUpType.SPECIAL)
		elseif cate == const.kTaskCondMonthCard then
			--4、领取月卡任务：打开充值UI
			Command.run( 'ui show', "VipPayUI", PopUpType.SPECIAL )
		elseif cate == const.kTaskCondSingleArenaBattle then
			--5、竞技场任务：打开竞技场
			Command.run('ui show','ArenaUI') 
		elseif cate == const.kTaskCondVendibleBuy or cate == const.kTaskCondTotem then
			--6、到商店买东西任务：打开商店
			 Command.run('ui show','Store',PopUpType.SPECIAL) 
		elseif cate == const.kTaskCondLotteryCard then
			--7、祭坛抽卡任务：打开祭坛
			 Command.run('ui show', 'CardUI' )
		elseif cate == const.kTaskCondMarketCargoUp then
			--8、拍卖行上架任务：打开拍卖行
			Command.run( 'ui show', 'AuctionUI')
		elseif cate == const.kTaskCondBuildingSpeed then
			--9、金币加速任务：打开金矿
			--10、圣水加速任务：打开太阳井
			EventMgr.dispatch(EventType.showSpeedStyle, data.cond.objid)
		elseif cate == const.kTaskCondTotemGlyphMerge then
			--11、雕文合成任务：打开图腾雕文
			Command.run( 'totem show glyph merge' )
		elseif cate == const.kTaskCondItemMerge then
			--12、打造装备任务：打开装备UI
			Command.run( 'ui show', 'EquipmentUI' )
		elseif cate == const.kTaskCondTrialFinished then
			-- 13 十字军试炼        13%[0]%[次数]
			Command.run( 'ui show', 'TrialMainUI' )
		elseif cate == const.kTaskCondTomb then		
			-- 大墓地            28%[关数]%1	
			Command.run( 'ui show', 'TombMainUI' )	
		elseif cate == const.kTaskCondWeiXinShared then
			-- 微信分享
			local function callback(resultid , result)
				LogMgr.error("id .. " .. resultid .. "结果 .. " .. result )
				if resultid == 0 then
					Command.run( 'task set', data.task_id, 1 )
				end
			end

			local platform = cc.Application:getInstance():getTargetPlatform()
			if platform ~= cc.PLATFORM_OS_WINDOWS then --window平台不发送
				if system.sendwechat then
					system.sendwechat('www.baidu.com', callback) --微信分享
				else
					Command.run( 'task set', data.task_id, 1 )
				end
			else
				Command.run( 'task set', data.task_id, 1 )
			end
		elseif cate == const.kTaskCondFriendGiveActiveScoreTimes then
 			ChatData.isType = "haoyou"
       		Command.run('ui show' , 'ChatUI' ,PopUpType.SPECIAL)
		end
	end
end

function __this.checkShowTask(value, list )
	local task = findTask( value.task_id )
	if task.type == const.kTaskTypeBranch then
		if task.task_id >= 20020 then
			if list then
				local oldTask = nil
				for k,v in pairs(list) do
					if not __this.checkTaskCanFinsh( task.task_id ) then
						oldTask = findTask( v.task_id )
						if oldTask.cond.cate == task.cond.cate then
							if task.task_id < oldTask.task_id then
								list[k] = value
							end 
							return false
						end
					end
				end
				return true
			else
				return true
			end
		else
			return true
		end
    elseif task.cond.cate == const.kTaskCondTime then
		local hour = GameData.getServerDate().hour
		if task.cond.objid == 12 then
			if hour < task.cond.val  or hour > 20 then
				return true
			end
		else
			if hour >= 14 and hour <= task.cond.val then
				return true
			end
		end
	else
		return true
	end
	return false
end

function __this.setTaskMap(data)
	for _,v in pairs(data) do
		table.insert(__this.taskData(), v)
	end
end

function __this.hasTask(id)
	for _, v in pairs(__this.taskData()) do
		if v.task_id == id then
			return true
		end
	end

	return false
end

function __this.hasOrOnceTask( id )
	return __this.hasTask( id ) or __this.hasLogTask( id )
end

function __this.getTask(id)
	for _, v in pairs(__this.taskData()) do
		if v.task_id == id then
			return v
		end
	end

	return nil
end

function __this.getTaskName(id)
	local jTask = findTask(id)
	return jTask and jTask.name or id
end

function __this.haveTaskGut( id, gutId )
    if __this.getTask( id ) ~= nil or __this.hasLogTask( id )then
		return GutMgr:checkGutEndForId( gutId )
	end
	return false 
end

function __this.addTask(data)
	if false == __this.hasTask(data.task_id) then
		table.insert(__this.taskData(), data)
	end
end

function __this.deleteTask(data)
	local set = nil
	for k, v in pairs(__this.taskData()) do
        if v.task_id == data.task_id then
			__this.taskData()[k] = nil
			break
		end
	end
end

function __this.updateTask(data)
	for k, v in pairs(__this.taskData()) do
        if v.task_id == data.task_id then
			v.cond = data.cond
		end
	end
end

function __this.checkTaskCanFinsh(id)
	local canFinsh = false
	local dataTask = __this.getTask( id )
	if dataTask ~= nil then
        local jsonTask = findTask( id )
        if jsonTask ~= nil then
        	if jsonTask.type ~= const.kTaskTypeDayRepeat or gameData.getSimpleDataByKey("team_level") >= __this.openDayLevel then
		        if jsonTask.cond.cate ~= const.kTaskCondTime then
					if jsonTask ~= nil then
						canFinsh = dataTask.cond >= jsonTask.cond.val
					end
				else
					local hour = GameData.getServerDate().hour
		            canFinsh = ( hour >= jsonTask.cond.objid and hour < jsonTask.cond.val )
				end
			end
		end
	end
	return canFinsh
end

function __this.checkHaveCanFinsh()
	local list = __this.taskData()
	for k,v in pairs( list ) do
		if __this.checkTaskCanFinsh( v.task_id ) then
			return true
		end
	end
	return false
end

function __this.checkHaveDayCanFinsh()
	local list = __this.taskData()
	local task = nil
	for k,v in pairs( list ) do
		task = findTask( v.task_id )
        if task ~= nil and task.type == const.kTaskTypeDayRepeat and __this.checkTaskCanFinsh( v.task_id ) then
			return true
		end
	end
	return false
end

function __this.checkHaveOtherCanFinsh()
	local list = __this.taskData()
	local task = nil
	for k,v in pairs( list ) do
		task = findTask( v.task_id )
        if task ~= nil and task.type ~= const.kTaskTypeDayRepeat and __this.checkTaskCanFinsh( v.task_id ) then
			return true
		end
	end
	return false	
end

function __this.setTaskLogMap(data)
	taskLogMap = data
end

function __this.getTaskLogMap()
	return taskLogMap
end

function __this.hasLogTask(id)
	if nil ~= taskLogMap then
		for _, v in pairs(taskLogMap) do
			if v.task_id == id then
				return true
			end
		end
	end
	return false
end

function __this.addLogTask(data)
	taskLogMap[data.task_id] = data
	EventMgr.dispatch( EventType.TaskFinsh, data.task_id )
end

function __this.hasDayTask( task_id )
	return __this.getDayTask( task_id ) ~= nil
end

function __this.getDayTask( task_id )
	for k,v in pairs(__this.getTaskDayMap()) do
		if v.task_id == task_id then
			return v
		end
	end
	return nil
end

function __this.checkFinshDayTask( task_id )
	for k,v in pairs(__this.getTaskDayMap()) do
		if v.task_id == task_id then
			return true
		end
	end
	return false
end

function __this.updateDayTask( data )
	local dayTask = __this.getDayTask( data.task_id )
	if dayTask ~= nil then
		dayTask.create_time = data.create_time
		dayTask.finish_time = data.finish_time
	else
		table.insert( gameData.user.task_day_map, data )
	end
end

function __this.setDayTaskList( data )
	gameData.user.task_day_map = data
end

function __this.initLeveTask()
    local data = GetDataList( 'Task' )
    local selfLevel = gameData.getSimpleDataByKey("team_level")
	local level = 0
	
	for _,value in pairs(data) do
        level = value.team_level_min 
        if level == nil then
            level = 0
        end
        
		if nil == levelDic[level] then
			levelDic[level] = {}
		end

        if value.task_id ~= 0 and ( value.team_level_max ~= nil or value.team_level_max >= selfLevel ) then
        	if ( value.type ~= const.kTaskTypeDayRepeat and not __this.hasLogTask( value.task_id ) and not __this.getTask(value.task_id ) ) or ( value.type == const.kTaskTypeDayRepeat ) then 		
				table.insert(levelDic[level], value)
			end
		end
	end
end

function __this.RmoveAcceptTask( taskId )
	local task = findTask( taskId )
    local list = levelDic[task.team_level_min]
	if list ~= nil and task.type ~= const.kTaskTypeDayRepeat then
		local index = nil
		table.foreach(	list, 
						function(i, v) 
							if v.task_id == taskId then
								index = i
							end
						end )

		if index ~= nil then
			table.remove( levelDic[task.team_level_min], index )
		end
	end
end

function __this.searchAcceptTask()
	local lv = gameData.getSimpleDataByKey("team_level")
	for i=0,lv do
    	local levelTaskList = levelDic[i]
    	if levelTaskList ~= nil then
    		for k, v in pairs(levelTaskList) do
                if ( v.team_level_max == nil or v.team_level_max == 0 or v.team_level_max >= lv ) and 
                    ( v.team_level_min == nil or v.team_level_min == 0 or v.team_level_min <= lv ) and
                    ( v.front_id == nil or v.front_id == 0 or __this.hasLogTask( v.front_id ) ) and
                    ( v.copy_id == nil or v.copy_id == 0  or gameData.user.copy_log_map[ v.copy_id ] ~= nil ) 
                then
                    if __this.getTask(v.task_id ) == nil then
                    	if ( v.type ~= const.kTaskTypeDayRepeat and not __this.hasLogTask( v.task_id ) ) or ( v.type == const.kTaskTypeDayRepeat and not __this.checkFinshDayTask( v.task_id ) ) then 
                    		if table.indexOf( acceptTaskMap, v.task_id ) == -1 then
    					   		Command.run( 'task accept', v.task_id )
    					   		table.insert( acceptTaskMap, v.task_id )
    					   	end
    					end
    				end
    			end
    		end
    	end
	end
end

--任务自动完成处理
function __this.onTaskUpdate(taskId)
    if __this.checkTaskCanFinsh(taskId)then
		local task = findTask( taskId )
		if task then
			if task.auto_submit == 1 then
				__this.goSubmit(taskId)
			end
		end
	end
end

--切换主场景提交任务
function __this.onMainSceneShowSubTask( name )
	if name == 'main' then
		__this.onTaskList()
	end
end

--登陆时候的任务检测
function __this.onTaskList()
	local taskList = __this.taskData()
    for k,v in pairs(taskList) do
		__this.onTaskUpdate( v.task_id )
	end
end

function __this.goSubmit( id )
	local task = findTask( id )
	if task then
		if task.auto_submit == 1 then
			Command.run('task auto finish', id)
			__this.OnTaskSendFinsh( id )
		elseif task.auto_submit == 2 then
			local function callback()
				Command.run('task auto finish', id)
				__this.OnTaskSendFinsh( id )
			end			
			CoinData.openRewardGetUI( task.coins, nil, nil, callback )
		else
			Command.run( 'task finish', id )
			__this.OnTaskSendFinsh( id )
		end
	end
end

function __this.OnTaskSendFinsh(id )
	local task = findTask( id )
	if id <= 10030 and task and task.type == const.kTaskTypeMain then	
		Command.run("loading wait show", "task")
	end
end

function __this.OnTaskCanFinsh( id )
	__this.onTaskUpdate(id)
end

function __this.OnTaskAdd( id )
	local task = findTask( id )
	if task and task.type == const.kTaskTypeMain then	
		Command.run("loading wait hide", "task")
	end
end

EventMgr.addListener( EventType.SceneShow, __this.onMainSceneShowSubTask )
EventMgr.addListener( EventType.TaskAdd, __this.OnTaskAdd )
EventMgr.addListener( EventType.UserTaskUpdate, __this.OnTaskCanFinsh )
EventMgr.addListener( EventType.TeamLevelUp, __this.searchAcceptTask)
