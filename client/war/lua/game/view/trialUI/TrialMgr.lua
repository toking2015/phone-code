TrialMgr = {}

TrialMgr.prePath = "image/ui/TrialUI/"

TrialMgr.formationTrailType = {} --布阵=>试炼
TrialMgr.formationTrailType[const.kFormationTypeTrialSurvival] = const.kTrialSurvival
TrialMgr.formationTrailType[const.kFormationTypeTrialStrength] = const.kTrialStrength
TrialMgr.formationTrailType[const.kFormationTypeTrialAgile] = const.kTrialAgile
TrialMgr.formationTrailType[const.kFormationTypeIntelligence] = const.kTrialIntelligence
TrialMgr.trailFormationType = {}--试炼=>布阵
TrialMgr.trailFormationType[const.kTrialSurvival] = const.kFormationTypeTrialSurvival
TrialMgr.trailFormationType[const.kTrialStrength] = const.kFormationTypeTrialStrength
TrialMgr.trailFormationType[const.kTrialAgile] = const.kFormationTypeTrialAgile
TrialMgr.trailFormationType[const.kTrialIntelligence] = const.kFormationTypeIntelligence

TrialMgr.currentTrial = nil

function TrialMgr.clear()
	if EventMgr.hasListener(EventType.FightEnd, TrialMgr.listener ) then
		EventMgr.removeListener(EventType.FightEnd, TrialMgr.listener)
	end
	Command.run( 'ui hide', 'TrialMainUI' )
end
TrialMgr.clear()
EventMgr.addListener(EventType.UserLogout, TrialMgr.clear)

function TrialMgr.setTouchEnabledChild(view, flag)
	view:setTouchEnabled(flag)
	for __, v in pairs(view:getChildren()) do
		TrialMgr.setTouchEnabledChild(v, flag)
	end
end

function TrialMgr.checkRewardEnd(userTrial, trial_id, index)
	local userTrial = userTrial or TrialMgr.getReward(trial_id)
	if not userTrial then
		return true
	end

	local list = TrialMgr.getJsonRewardCounts(trial_id)
	if userTrial.trial_val < list[index].trial_val then
		TipsMgr.showError("本次翻牌未达成")
		return false
	end

	local count = 0
	for __, userTrialReward in pairs(GameData.user.trial_reward_map[trial_id]) do
		if 0 ~= userTrialReward.flag then
			count = count + 1
		end
	end
	if count < 1 then
		TipsMgr.showError("还有免费次数")
		return false
	end

	return true
end

function TrialMgr:listener()
	Command.run("ui show", "TrialMainUI", PopUpType.SPECIAL)
end

function TrialMgr.showRewardList(trial_id)
	-- local typeList = {}
	-- local list = {}
	-- for __, userTrialReward in pairs(GameData.user.trial_reward_map[trial_id]) do
	-- 	if 0 ~= userTrialReward.flag then
	-- 		local reward = findReward(userTrialReward.reward)
	-- 		if reward and not table.empty(reward.coins) then
	-- 			for __, coin in pairs(reward.coins) do
	-- 				local flag = false
	-- 				for __, c in pairs(list) do
	-- 					if c.cate == coin.cate and c.objid == coin.objid then
	-- 						c.val = c.val + coin.val
	-- 						flag = true
	-- 						break
	-- 					end
	-- 				end

	-- 				if not flag then
	-- 					table.insert(list, {cate=coin.cate, objid=coin.objid, val=coin.val})
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- for key, val in pairs(list) do
	-- 	table.insert(typeList, val.cate)
	-- end

	-- showGetEffect(list, typeList)
end

--整点刷新处理
function TrialMgr.refreshData()
	local login_time = gameData.time.server_time
	local serv_time = gameData.getServerTime()
    local isOne = DateTools.isOneDayPass(serv_time, login_time) -- 判断是否隔天

    if not isOne or DateTools.getHour(login_time) < 6 and DateTools.getHour(serv_time) >= 6 then
		Command.run("trial update")
	end
end

function TrialMgr.initRewardList()
	local jsons = GetDataList("Trial")
	for __, json in pairs(jsons) do
		if not GameData.user.trial_reward_map[json.id] then
			GameData.user.trial_reward_map[json.id] = {}
		end
		if table.empty(GameData.user.trial_reward_map[json.id]) then
			Command.run("trial reward_list", json.id)
		end
	end
end

function TrialMgr.SetReward(id, index)
	if not GameData.user.trial_reward_map[id] or 6 ~= #GameData.user.trial_reward_map[id] then
		return
	end

	GameData.user.trial_reward_map[id][index + 1].flag = 1

	EventMgr.dispatch(EventType.TrialRewardUpdate)
	EventMgr.dispatch(EventType.TrialUpdate)

	local count = 0
	for __, userTrialReward in pairs(GameData.user.trial_reward_map[id]) do
		if 0 ~= userTrialReward.flag then
			count = count + 1
		end
	end

	if 4 == count then
		TipsMgr.showError("本次翻牌结束")
	end
end

function TrialMgr.rewardUpdate(id, reward_list)
	if not GameData.user.trial_reward_map[id] then
		GameData.user.trial_reward_map[id] = {}
	end

	GameData.user.trial_reward_map[id] = reward_list

	EventMgr.dispatch(EventType.TrialRewardUpdate)
	EventMgr.dispatch(EventType.TrialUpdate)
end

function TrialMgr.getRewardCounts(trial_id)
	if not GameData.user.trial_reward_map[trial_id] then
		GameData.user.trial_reward_map[trial_id] = {}
	end

	return GameData.user.trial_reward_map[trial_id]
end

function TrialMgr.trialUpdata(userTrial)
	for i, value in pairs(GameData.user.trial_map) do
		if userTrial.trial_id == value.trial_id then
			GameData.user.trial_map[i] = userTrial
	
			EventMgr.dispatch(EventType.TrialRewardUpdate)
			EventMgr.dispatch(EventType.TrialUpdate)
			return
		end
	end

	table.insert(GameData.user.trial_map, userTrial)

	EventMgr.dispatch(EventType.TrialRewardUpdate)
	EventMgr.dispatch(EventType.TrialUpdate)
end

function TrialMgr.getTrial(id)
	for __, userTrial in pairs(GameData.user.trial_map) do
		if id == userTrial.trial_id then
			return userTrial
		end
	end

	return nil
end

function TrialMgr.getReward(id)
	for __, trialReward in pairs(GameData.user.trial_reward_map) do
		if id == trialReward.trial_id then
			return trialReward
		end
	end

	return nil
end

--获取已达成的列表
function TrialMgr.getJsonRewards(trial_id, trial_val)
	local l = {}
	local jsons = GetDataList("TrialRewardCount")
	for __, list in pairs(jsons) do
		for __, json in pairs(list) do
			if json.trial_id == trial_id and json.trial_val <= trial_val then
				table.insert(l, json)
			end
		end
	end

	return l
end

--获取奖励列表
function TrialMgr.getJsonRewardCounts(trial_id)
	local jsons = GetDataList("TrialRewardCount")
	for __, list in pairs(jsons) do
		for __, json in pairs(list) do
			if json.trial_id == trial_id then
				return list
			end
		end
	end

	return nil
end

--获取奖励数量
function TrialMgr.getJsonRewardCount(trial_id)
	local jsons = GetDataList("TrialRewardCount")
	for __, list in pairs(jsons) do
		for __, json in pairs(list) do
			if json.trial_id == trial_id then
				return #list
			end
		end
	end

	return 0
end

--获取某个试炼最大总量
--@param trial_id	唯一标识
--@param val 		试炼值
--@return [>=试炼值的下一个奖励数据]	[前一个返回值的索引位置]	[<试炼值之前的试炼值总值]
function TrialMgr.getMaxVal(trial_id, val)
	local list = TrialMgr.getJsonRewardCounts(trial_id)
	if table.empty(list) then
		return 0, 0, 0
	end

	local trial_val = 0
	local index = 0
	local val_num = 0
	if val then
		for i, json in pairs(list) do
			trial_val = json.trial_val
			if val < json.trial_val then
				break
			else
				val_num = json.trial_val
				index = i
			end
		end
	end

	return trial_val, index, val_num
end


function TrialMgr.runSecond( obj,dir,Com )
    local angle = dir * 75
    local orbit = cc.OrbitCamera:create(0.05,1, 0, 0, angle, 0, 0)
    local function OnCom( )
        if Com then
            Com()
        end
    end
    local callBack = cc.CallFunc:create(OnCom)
    local action = cc.Sequence:create(orbit:reverse(),callBack)
    obj:runAction(action)
end

function TrialMgr.runFirst( obj,dir,next )
    local angle = dir * 105
    local orbit = cc.OrbitCamera:create(0.05,1, 0, 0, angle, 0, 0)
    local callBack = cc.CallFunc:create(next)
    local action = cc.Sequence:create(orbit,callBack)
    obj:runAction(action)
end

--判断是否还有未领取奖励
function TrialMgr.isRedPoint()
	local jsons = GetDataList("Trial")
	for __, json in pairs(jsons) do
		local userTrial = TrialMgr.getTrial(json.id)
		if userTrial and userTrial.try_count >= json.try_count then
			local list = TrialMgr.getJsonRewards(json.id, userTrial.trial_val)
			if userTrial.reward_count < #list then
				return true
			end
		end
	end

	return false
end