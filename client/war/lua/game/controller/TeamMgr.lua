local max_xp = nil
local oldLevel = 0
local function onSimpleChange(evt)
	local level = gameData.getSimpleDataByKey("team_level")
	if level ~= oldLevel then --升级成功
		oldLevel = level
		max_xp = findLevel(oldLevel).team_xp
		--处理升级成功的逻辑，比如弹出窗口
		-- PopMgr.checkPriorityPop("TeamUpgradeUI", function()
		-- 	Command.run("ui show", "TeamUpgradeUI", PopUpType.MODEL)
		-- end)
	end
	local xp = gameData.getSimpleDataByKey("team_xp")
	if xp >= max_xp then
		max_xp = 4294967295 --uint.max_value, 防止重复升级
		local jNextLevel = findLevel(level + 1)
		if jNextLevel then
			Command.run("team levelup") --请求升级
		end
	end
end
local function onDataLoaded(evt)
	EventMgr.removeListener(EventType.UserDataLoaded, onDataLoaded)
	oldLevel = gameData.getSimpleDataByKey("team_level")
	if oldLevel >= MainScene.MaxTeamLevel then -- 最大戰隊等級
		LogMgr.debug("达到战队最大等级")
		oldLevel = MainScene.MaxTeamLevel
		gameData.setSimpleDataByKey("team_level", oldLevel)
	end
	local jLevel = findLevel(oldLevel)
	max_xp = jLevel.team_xp
	onSimpleChange(evt)
end
-- EventMgr.addListener(EventType.UserSimpleUpdate, onSimpleChange)
EventMgr.addListener(EventType.UserDataLoaded, onDataLoaded)

Command.bind("team rename check", function()
	if TeamData.getChangeNameCount() == 0 then
		TeamData.forceRename = true
		Command.run("ui show", "RenameUI", PopUpType.SPECIAL)
	end
end)

local function checkGetFirstSoldier(name)
	if name ~= "main" then
		return
	end
	EventMgr.removeListener(EventType.SceneShow, checkGetFirstSoldier)
	local function doCheckGetFirstSoldier()
		local isAutoUp = gameData.user.simple.team_level == 1 and not FormationData.getIsUp(const.kFormationTypeCommon, 1, const.kAttrSoldier)
	    if isAutoUp then
	        local soldier = SoldierData.getSoldier(1)
	        if soldier then
	            --弹出获得老牛的提示画面！
	            -- SoldierData.soldierGetUI(nil, soldier.soldier_id) --不弹出获得老牛
	            FormationData.upByGuid(const.kFormationTypeCommon, 1, const.kAttrSoldier, true) --前两个英雄自动上阵
	            EventMgr.dispatch( EventType.ShowGetRow, 1 )
	            return
	        end
	    end
	    EventMgr.dispatch( EventType.ShowGetRow, 2 ) 
	end 
	TimerMgr.runNextFrame(doCheckGetFirstSoldier)
end
EventMgr.addListener(EventType.SceneShow, checkGetFirstSoldier)
