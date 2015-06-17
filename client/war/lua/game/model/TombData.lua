local __this = {}

__this.panel_list = {}

function __this:init()
	self.area = 0 
	for i, tombTarget in pairs(GameData.user.tomb_target_list) do
		if 0 == tombTarget.reward then
			-- self.area = math.floor((i - 1) / 5)
			break
		else
			self.area = math.floor(i / 5)
		end
	end

	self.reward = GameData.user.tomb_info.reward_count

	if 0 == #GameData.user.tomb_target_list then
		Command.run("tomb target_list")
	end
end

--整点刷新处理
function __this.refreshData()
	local login_time = gameData.time.server_time
	local serv_time = gameData.getServerTime()
    local isOne = DateTools.isOneDayPass(serv_time, login_time) -- 判断是否隔天

    if not isOne or DateTools.getHour(login_time) < 6 and DateTools.getHour(serv_time) >= 6 then
		Command.run("tomb info")
	end
end

--获取最大重置次数
function __this.getTryMaxCount()
	local count = 1
	local v = findGlobal("tomb_vip_add_count_level")
	if v then
		if GameData.getSimpleDataByKey("vip_level") >= tonumber(v.data) then
			count = count + 1
		end
	end

	return count
end

--获取剩余重置次数
function __this.getTryCount()
	return TombData.getTryMaxCount() - GameData.user.tomb_info.try_count
end

function __this.getCurrentTomb()
	if table.empty(GameData.user.tomb_target_list) then
		return nil
	end

	return GameData.user.tomb_target_list[GameData.user.tomb_info.win_count + 1]
end

function __this.getPanelFightSoldier(panel, guid)
	local able = nil
	local quality = 0
	for __, ext in pairs(panel.fightextable_map) do
		if guid == ext.guid then
			able = ext.able
			break
		end
	end

	for __, soldier in pairs(panel.soldier_map) do
		if guid == soldier.guid then
			quality = soldier.quality
			break
		end
	end

	return able, quality
end

function __this.getTargetFightSoldier(attr, guid)
	local list = SoldierData.getTable(attr)
	if not list or table.empty(list) then
		return nil
	end

	for __, soldier in pairs(list) do
		if soldier.guid == guid then
			return soldier
		end
	end

	return nil
end

function __this.getTombId(area)
	if 0 == #GameData.user.tomb_target_list then
		return 1
	end

	local tombTarget = GameData.user.tomb_target_list[area * 5 + 5]
	local data = GetDataList("Tomb")
	for __, json in pairs(data) do
		if tombTarget.target_id == json.monster_id then
			return json.id
		end
	end

	return 1
end

function __this:listener()
	Command.run("ui show", "TombMainUI", PopUpType.SPECIAL)
end

function __this:setTargetList(list)
	GameData.user.tomb_target_list = list
	self:init()
	EventMgr.dispatch(EventType.tombUiUpdata)
end

function __this.setTarget(player_index, target)
	local list = GameData.user.tomb_target_list
	if player_index + 1 > #list then
		return
	end

	list[player_index + 1] = target
	EventMgr.dispatch(EventType.tombUiUpdata)
end

function __this:setPanel(target_id, panel)
	self.panel_list[target_id] = panel
	EventMgr.dispatch(EventType.tombUiUpdata)
end

function __this:getPanel(target_id)
	return self.panel_list[target_id]
end

function __this.setReward(tombTarget)
	local index = gameData.user.tomb_info.win_count
	if index > #GameData.user.tomb_target_list then
		return
	end

	GameData.user.tomb_target_list[index] = tombTarget
	EventMgr.dispatch(EventType.tombUiUpdata)
end

function __this.checkNext(area)
	if area * 5 + 5 >= #GameData.user.tomb_target_list then
		return false
	end

	local index = area * 5 + 1
	for i = index, #GameData.user.tomb_target_list, 1 do
		if i >= index + 5 then
			break
		end

		if 0 == GameData.user.tomb_target_list[i].reward then
			return false
		end
	end

	return true
end

function __this.tombReset(info, list, init)
	GameData.user.tomb_info = info
	if list then
		GameData.user.tomb_target_list = list
	end

	if init then
		TombData:init()
	end

	EventMgr.dispatch(EventType.tombUiUpdata)
end

function __this.loadFightModelAsync(tombTarget, level, callback)
	local list = {}
	-- local index = area * 5 + 1
	-- for i = index, #GameData.user.tomb_target_list, 1 do
	-- local tombTarget = GameData.user.tomb_target_list[i]
	if const.kAttrMonster == tombTarget.attr then
        table.insert( list, { id = tombTarget.guid, attr = tombTarget.attr, 1 } )
	else
		local target = TombData:getPanel(tombTarget.target_id)
		if target then
			local flag = false
			for __, formation in pairs(target.formation_map) do
				if const.kAttrTotem ~= formation.attr then
					for __, soldier in pairs(target.soldier_map) do
						if formation.guid == soldier.guid then
							table.insert( list, { id = soldier.soldier_id, attr = formation.attr, level } )
							flag = true
							break
						end
					end
				end

				if flag then
					break
				end
			end
		end
	end
	-- end

	LoadMgr.loadFightModelListAsyncForWait( list, callback )
end

TombData = __this