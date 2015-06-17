-- Create By Hujingjiang --
require "lua/game/view/copytips/CopyTipsMainUI.lua"

CopyMgr = {strength = 0, isChange = false, isShowFormation=false}

local copy = nil
local sid = nil
local copyCate = 0

function CopyMgr.equipPush(userItem)
	CopyMgr.equipList = CopyMgr.equipList or {}
	CopyMgr.srcEquipList = CopyMgr.srcEquipList or {}
	-- if 
	-- 	not SceneMgr.isSceneName("copy") 
	-- 	and not SceneMgr.isSceneName("copyUI") 
	-- 	and not SceneMgr.isSceneName("fight")
	-- then
	-- 	return
	-- end

	local item = findItem(userItem.item_id)
	if not item or 1 ~= item.type then
		return
	end

	table.insert(CopyMgr.equipList, userItem)
	EventMgr.addListener(EventType.CopyTipsShow, CopyMgr.equipShow)

	local r_item = EquipmentData:getEquipmentForCondition(item.equip_type, nil, item.subclass)
	CopyMgr.srcEquipList[userItem.guid] = r_item

	if SceneMgr.isSceneName("copyUI") then
		local ui = PopMgr.getWindow("CopyTipsMainUI")
	    if not ui then
	    	EventMgr.dispatch(EventType.CopyTipsShow)
	    end
	end
end

function CopyMgr.equipShow()
	if not CopyMgr.equipList or 0 == #CopyMgr.equipList then
		EventMgr.removeListener(EventType.CopyTipsShow, CopyMgr.equipShow)
		return
	end

	PopMgr.checkPriorityPop("CopyTipsMainUI", PopOrType.Com, function ( ... )
		local userItem = table.remove(CopyMgr.equipList, 1)
		local srcUserItem = CopyMgr.srcEquipList[userItem.guid]
		CopyMgr.srcEquipList[userItem.guid] = nil
		Command.run("ui show", "CopyTipsMainUI")
		EventMgr.dispatch(EventType.CopyTipsEquip, {userItem, srcUserItem})
	end)
end

-- 开始监听Chunk事件，进入副本新场景需执行
function CopyMgr.start()
	EventMgr.addListener(EventType.DoNextChunk, CopyMgr.delayDoChunk)
end
-- 停止监听Chunk事件，退出副本场景时执行
function CopyMgr.stop()
	EventMgr.removeListener(EventType.DoNextChunk, CopyMgr.delayDoChunk)
	TimerMgr.killTimer(sid)
	
	copy = nil
	sid = nil
end
-- 执行延迟下一个探索
function CopyMgr.delayDoChunk()
    LogMgr.debug(">>>>>>>>> 执行延迟下一个探索")
    CopyData.isMetBoss = false
	TimerMgr.killTimer(sid)

	local copy = CopyData.user.copy
	local posi = copy.posi + 1
	local index = copy.index
	local chunk = copy.chunk[posi]
	LogMgr.log( 'debug',">>>>>>>>>>> next posi = " .. posi)
	if nil ~= copy.reward and nil ~= copy.reward[posi] then
		local cate = copy.reward[posi].cate
		copyCate = cate

		LogMgr.log( 'debug',"CopySceneBG showSearch cate = " .. cate)

		if chunk.cate == const.kCopyEventTypeFightMeet then
			if index == 1 then
				Command.run("CopySceneBG doSpecialSearch")				
				return
			end 
		end

		if cate == 0 then
			LogMgr.log( 'debug',">>>>>>>>>>>>>>3 seconds later , searching for next chunk ......")

			local delay = 0.5
			
			local chunk = CopyData.getCurrChunk()
			local evtType = chunk.cate
			
			if evtType == const.kCopyEventTypeGut then --and cate == 2 
				delay = 0.1
			end
			sid = TimerMgr.startTimer(CopyMgr.doChunk, delay)
		else
			Command.run("CopySceneBG showSearch", true)
		end
	end
end
Command.bind("CopyMgr delayDoChunk", CopyMgr.delayDoChunk)
-- 执行chunk事件
function CopyMgr.doChunk()
	TimerMgr.killTimer(sid)

	Command.run("CopySceneBG doSpecialSearch")
end
--获取副本剧情
function CopyMgr.getCopyGut(copy_id, chunk)
	if not CopyMgr.copy_gut or copy_id ~= CopyMgr.copy_gut.id then
		local json = GetDataList("CopyGut")
		CopyMgr.copy_gut = {id = copy_id, jsons = {}}
		for __, line in pairs(json) do
			if copy_id == line.id then
				table.insert(CopyMgr.copy_gut.jsons, line)
			end
		end
	end

	for __, json in pairs(CopyMgr.copy_gut.jsons) do
		if chunk.cate == json.chunk.cate and chunk.objid == json.chunk.objid then
			return FightFileMgr:copyTab(json)
		end
	end

	return nil
end
-- 发送攻击boss协议
function CopyMgr.fightMonster(monster)
	local function sendFight()
		local g_copy = gameData.user.copy
		--锁定协议处理（不会再触发消息回调）
		trans.lock_queue( true )
       
		EventMgr.removeListener(EventType.RefreshCopyUpdate, sendFight)
		LogMgr.log( 'debug',"发送战斗，怪物名称 = " .. monster.name .. " , 类型 = " .. monster.type)
		local copy = CopyData.user.copy
		if not copy.chunk then
			return
		end
	    local fChunk = copy.chunk[copy.posi + 1]
	    local val = fChunk.val
	    if not copy.seed[val] then
	    	return
	    end
	    
	    local seed = copy.seed[val].value
	    LogMgr.log( 'debug',"val = " .. val .. " , seed = " .. seed)
	    local fight = copy.fight[val]
	    local fightClone = clone(fight)
	    LogMgr.info("为什么会黑屏！！！")
	    FightDataMgr:copyEnter(fightClone, seed, g_copy.coins[copy.posi + 1], true, CopyMgr.getCopyGut(g_copy.copy_id, fChunk))
	    Command.run("loading wait hide", "opening")
	    Command.run("loading can frog", true)
	end
	LogMgr.info("准备开战7")
	if CopyMgr.isChange == true then -- 当有阵容调整则先等待阵容刷新
		LogMgr.info("准备开战8")
		EventMgr.addListener(EventType.RefreshCopyUpdate, sendFight)
		-- Command.run("loading wait show", "copy")
        Command.run("copy refurbish")
	else
        if CopyData.isNeedRefurish == true then -- 当需要刷新数据则先请求阵容刷新
        	LogMgr.info("准备开战9")
            EventMgr.addListener(EventType.RefreshCopyUpdate, sendFight)
            -- Command.run("loading wait show", "copy")
            Command.run("copy refurbish", 'copy_fight')
        else
        	LogMgr.info("准备开战10")
            sendFight()
		end
	end
--	CopyData.isNeedRefurish = false
end
-- 显示副本布阵攻打怪物，若isDirect为true则直接攻打怪物
function CopyMgr.showCopyFormation(isDirect)
	local chunk = CopyData.getCurrChunk()
	if not chunk then --容错处理
		return
	end
	LogMgr.log( 'debug',"怪物id = " .. chunk.objid .. " , 战斗id = " .. chunk.val)
	local monster = findMonster(chunk.objid)
	LogMgr.info("准备开战5")
    if monster then
    	LogMgr.info("准备开战6")
	    CopyData.isMonsterBoss = (monster.type == 2)
	    if isDirect == true then
	    	CopyMgr.fightMonster(monster)
	    else
			local function fightMonster()
				-- if CopyMgr.isChange then
					Command.run("loading wait show", "copy")
				-- end
			    CopyMgr.fightMonster(monster)
	    	end
	    	Command.run("formation show monster", chunk.objid, fightMonster, nil, CopyData.user.copy.copy_id, CopyData.isMonsterBoss)
	    end
	else
        LogMgr.log( 'debug',"查找不到该怪物")
    end
end
-- 显示boss布阵（攻打boss时）
function CopyMgr.showBossFormation()
    local boss_type = CopyData.fightBossType
    local boss_id = CopyData.fightBossID
	local function fightMonster()
        CopyData.isMonsterBoss = true
		Command.run("loading wait show", "copy")
		if CopyMgr.isChange then
			Command.run("copy refurbish")
		end
		Command.run("copy fihgtBoss", boss_type, boss_id)
	end
	CopyData.isShowFormation = true
	Command.run("formation show monster", boss_id, fightMonster, nil, CopyData.getCopyIdByBossId(boss_type, boss_id), true)
end
-- 是否直接攻打怪物，isDirect为true不需布阵直接攻打，默认为false
function CopyMgr.fightMonsterDirect(isDirect)
	local u_copy = CopyData.user.copy
	
	if true == CopyData.enabledSearch() then
	
		if not u_copy or #u_copy.chunk == 0 then
		
			TimerMgr.runNextFrame(CopyMgr.fightMonsterDirect, isDirect)
			return
		else
		
			function toFightMonster()
				EventMgr.removeListener(EventType.RefreshCopyUpdate, toFightMonster)
				CopyMgr.showCopyFormation(isDirect)
			end
			
			EventMgr.addListener(EventType.RefreshCopyUpdate, toFightMonster)
            Command.run("copy refurbish", 'direct_fight')
		end
	else
        --StrengthUI.showBuyStrengt("体力不足，")
        Command.run("show actTips",const.kCoinStrength)
    end
end
Command.bind("CopyMgr directFight", CopyMgr.fightMonsterDirect)

-- 提交直接攻打单一过程boss的事件
function CopyMgr.commitNormalFight(fight_id)
	local data = CopyData.fightData
	if data.isWin == true then
		trans.lock_queue( false )
		Command.run('copy commit oneMonster', fight_id)
	end
end
-- 预加载战斗模型
function CopyMgr.doFunciton(fight)
    if fight == nil then
        return
    end

    local path = "image/map/" .. CopyData.getWarMap(copyId) .. ".jpg"
    LoadMgr.loadImageAsync(path, LoadMgr.MANUAL, "copy")
   
    for key, fpinfo in ipairs(fight.fight_info_list) do
        if fpinfo.camp == const.kFightRight then
            for key, soldier in ipairs(fpinfo.soldier_list) do
                LoadMgr.loadFightModelAsync( soldier.soldier_id, soldier.attr, 5 )
            end
        end
    end
end

--等级升级时检测是否有新的副本开启
function CopyMgr.checkOpenNextCopy(oldLevel, newLevel)
	local copy_id = CopyData.getNextCopyId()
    if copy_id ~= 0 then
        if not CopyData.checkOpenAreaBy(copy_id, oldLevel) and CopyData.checkOpenAreaBy(copy_id, newLevel) then
        	CopyData.wait_open = false
       		if SceneMgr.isSceneName("copy") then
        		EventMgr.dispatch(EventType.UserCopyUpdate)
       		end

        	if SceneMgr.isSceneName("main") then
        		--调用副本提示
        	end
        end
    end
end

--TASK #7745::【手游5月版】如果有新副本开启的时候，在主界面上要弹出气泡
function CopyMgr.checkNextCopy()
	if not SceneMgr.isSceneName("main") then
		return false
	end

	local copy_id = CopyData.getNextCopyId()
	if 0 == copy_id or not CopyData.checkOpenAreaBy(copy_id, gameData.user.simple.team_level) then
		return false
	end

	local task = TaskData.getMianTask()
	if not task then
		return false
	end

	--玩家完成10034任务后&&玩家在主界面并且停留时间超过10秒钟（指没有任何动作）
	if 10034 < task.task_id then

	end

	--玩家接到10033或者10034任务&&玩家在主界面
	if 10033 == task.task_id or 10035 == task.task_id then-- or 10034 == task.task_id then
		return true
	end

	local copy = findCopy(copy_id)
	if not copy then
		return false
	end

	--玩家的任务在10032前并且出现的任务是通关副本&&玩家在主界面
	if task.task_id < 10032 and #copy.chunk > 0 then
		return true
	end

	return false
end

local function onScneeShow( ... )
	CopyData.isShowFormation = false
end

EventMgr.addListener( EventType.SceneShow, onScneeShow )