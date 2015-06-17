local function checkPushBack()
	if SceneMgr.isSceneName("copyUI") then
		local sc = SceneMgr.getCurrentScene()
		if sc.checkPushBack then
			sc:checkPushBack()
		end
	end
end

trans.call.PRCopyOpen = function(msg)
    Command.run("loading wait hide", 'copy_open')
    if msg.result ~= 0 then
        return
    end
    
    local stream = zlib.uncompress( msg.data.data, msg.data.size )
    local object = seq.stream_to_object( "SUserCopy", stream )
    gameData.user.copy = object
    
    CopyData.user.copy = clone(object)
    --接受副本copy id 0
    ActionMgr.save( 'copy', 'recv PRCopyOpen:' .. CopyData.user.copy.copy_id )
    
    EventMgr.dispatch( EventType.UserCopyUpdate )
    EventMgr.dispatch(EventType.UpdateCopyLog)
end

trans.call.PRCopyData = function(msg)
    local stream = zlib.uncompress( msg.data.data, msg.data.size )
    local object = seq.stream_to_object( "SUserCopy", stream )
    gameData.user.copy = object
    
    CopyData.user.copy = clone(object)
    
    --接受副本copy id 0
    ActionMgr.save( 'copy', 'recv PRCopyData:' .. CopyData.user.copy.copy_id )
end

trans.call.PRCopyLogList = function (msg)
--	LogMgr.log( 'copy', "返回副本日志:" .. debug.dump(msg) )
	CopyData.isSendMsg = false
	
	gameData.user.copy_log_map = msg.data
	if gameData.user.copy.copy_id ~= 0 then
		EventMgr.dispatch(EventType.CopyClearance, gameData.user.copy.copy_id) --通关副本
	end
    
    TaskData.searchAcceptTask()
    checkPushBack()
    --    EventMgr.dispatch(EventType.UpdateCopyLog)
end

trans.call.PRCopyClose = function(msg)
    ActionMgr.save( 'copy', 'recv PRCopyClose: result-' .. msg.result )

    Command.run("loading wait hide", 'copy')
    CopyData.wait_close = false;
    if 0 ~= msg.result then
    	return
    end
    
    gameData.user.copy.copy_id = 0
    local copy_id = CopyData.getNextCopyId()
    Command.run( 'copy open', copy_id )
end

trans.call.PRCopyRefurbish = function(msg)
    CopyData.wait_ref = false
    Command.run("loading wait hide", 'copy')
    
    local stream = zlib.uncompress( msg.data.data, msg.data.size )
    local object = seq.stream_to_object( "SUserCopy", stream )
    
    gameData.user.copy = object
    CopyData.user.copy.fight = clone(object.fight)
    CopyData.user.copy.seed = clone(object.seed)
    
    --接受副本copy id 0
    ActionMgr.save( 'copy', 'recv PRCopyRefurbish:' .. CopyData.user.copy.copy_id )
    
    if CopyData.user.copy ~= nil then
	    local posi = CopyData.user.copy.posi
	    local index = CopyData.user.copy.index

	    CopyData.user.copy = clone( gameData.user.copy )
	    CopyData.user.copy.posi = posi
	    CopyData.user.copy.index = index
	    CopyRewardData.prePosi = posi + 1
	end
	
    CopyMgr.isChange = false
    EventMgr.dispatch( EventType.RefreshCopyUpdate )
end

trans.call.PRCopyBossFight = function(msg)
	CopyData.getBossReward = msg.coins
	FightDataMgr:copyEnter(msg.fight, msg.seed, msg.coins)
end

trans.call.PRCopyBossMopup = function(msg)
	EventMgr.dispatch(EventType.ShowResultList, msg.coins)
end

trans.call.PRCopyLog = function(msg)
	gameData.user.copy_log_map[msg.data.copy_id] = msg.data
    TaskData.searchAcceptTask()
    checkPushBack()
end

-- { 'mopup_type', 'uint8' },		-- 副本扫荡类型 [ kCopyMopupTypeNormal | kCopyMopupTypeElite ]
-- { 'mopup_attr', 'uint8' },		-- 副本值类型 [ kCopyMopupAttrRound | kCopyMopupAttrTimes ]
-- { 'boss_id', 'uint32' },			-- 0 为需要将相关类型所有扫荡次数同时重置为 value
-- { 'value', 'uint32' },			-- 扫荡次数
trans.call.PRCopyMopupData = function(msg)
--	LogMgr.log('debug', ">>>>>>>>>>>>>>添加或修正Boss日志:" .. debug.dump(msg))

	local mopup_type = msg.mopup_type
	local mopup_attr = msg.mopup_attr
	local boss_id = msg.boss_id
	local value = msg.value

	local mopup = gameData.user.mopup
	
	local round = mopup.normal_round
	local times = mopup.normal_times
	local reset = mopup.normal_reset

	if mopup_type == trans.const.kCopyMopupTypeElite then
		round = mopup.elite_round
		times = mopup.elite_times
		reset = mopup.elite_reset
	end

	if mopup_attr == trans.const.kCopyMopupAttrRound then
		local r = round[boss_id] or 255
		round[boss_id] = value
        local copy_id = CopyData.getCopyIdByBossId(mopup_type, boss_id)
        CopyData.getComStars(copy_id, r, value)
		-- if nil ~= r and r > 0 and value == 0 then
		-- 	times[boss_id] = 0
		-- 	reset[boss_id] = 0
		-- end
		-- if r == nil then
		CopyData.addNewBoss(mopup_type, boss_id, value)
		-- end
	elseif mopup_attr == trans.const.kCopyMopupAttrTimes then
		times[boss_id] = value
	else
		reset[boss_id] = value
	end

	EventMgr.dispatch(EventType.UpdateCopyBoss)
	EventMgr.dispatch( EventType.UserCopyUpdate )
end

trans.call.PRCopyAreaPresentTake = function(msg)
--	LogMgr.log( 'debug', ">>>>>>>>>>>>>>返回通关奖励领取数据:" .. debug.dump(msg) )
	EventMgr.dispatch(EventType.GetPresent, msg)
end

trans.call.PRCopyAreaData = function(msg)
--	LogMgr.log( 'debug', ">>>>>>>>>>>>>>返回通关奖励领取记录:" .. debug.dump(msg) )
	local log = gameData.user.area_log_map
	log[msg.data.area_id] = msg.data
end

--测试服务器战斗校验错误debug用
copy_commit_event_fight_data = nil
trans.call.PRCopyCommitEventFight = function(msg)
	if CopyData.user.copy then
		ActionMgr.save( 'copy', 'recv PRCopyCommitEventFight result:' .. msg.result .. "  id:" .. CopyData.user.copy.copy_id .. "  posi:" .. msg.posi .. "  index:" .. msg.index )
	end

    if msg.result == trans.const.kErrFightFailure then 
        copy_commit_event_fight_data = msg
    end
end

trans.call.PRCopyCommitEvent = function (msg)
	--接收 副本 100001 commit posi 2 数据返回
	if not CopyData.user.copy then
		return
	end

	ActionMgr.save( 'copy', 'recv PRCopyCommitEvent result:' .. msg.result .. "  id:" .. CopyData.user.copy.copy_id .. "  posi:" .. msg.posi .. "  index:" .. msg.index )
end

function trans.call.PRCopyFightLogLoad(msg)
	CopyData.bossRecordData[msg.copy_id] = msg.list
	EventMgr.dispatch(EventType.COPY_FIGHTLOG_LOADED)
end