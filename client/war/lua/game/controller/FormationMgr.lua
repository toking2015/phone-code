local function setFormationData(style, type, okFun, cancelFun, oppFormation, fightValue, exData, helpFormation, isMonsterBoss, monsterId)
	FormationData.style = style
	FormationData.type = type
	FormationData.attr = const.kAttrSoldier
	FormationData.okFun = okFun
	FormationData.cancelFun = cancelFun
	FormationData.oppFormation = oppFormation
	FormationData.oppFightValue = fightValue
	FormationData.oppExData = exData
	FormationData.helpFormation = helpFormation
	FormationData.isMonsterBoss = isMonsterBoss
	FormationData.monsterId = monsterId
	FormationData.reopen = nil
	FormationData.backupData = clone(FormationData.getTypeData(type)) --备份数据
	FormationData.lastUpIndex = nil
end

local function doShowFormation(type)
	local win = PopMgr.getWindow("FormationWin")
	if win and win:isShow() then
		-- LogMgr.error("重复打开布阵")
		return
	end
	FormationData.initFormation(type)
	local level = gameData.getSimpleDataByKey("team_level")
	PopMgr.popUpWindow("FormationWin", nil, nil, level <= 5)
end

local function showFormation(style, type, okFun, cancelFun, oppFormation, fightValue, exData, helpFormation, isMonsterBoss, monsterId)
	if SceneMgr.isSceneName("fight") then --已经在战斗场景，不能再显示布阵
		return
	end
	setFormationData(style, type, okFun, cancelFun, oppFormation, fightValue, exData, helpFormation, isMonsterBoss, monsterId)
	SceneMgr.enterScene("fight")
	doShowFormation(type)

	--音效预加载
	ModelMgr.loadSound()
end

Command.bind("formation show", function(okFun, cancelFun)
	showFormation(FormationData.STYLE_ONE, const.kFormationTypeCommon, okFun, cancelFun)
end)

Command.bind("formation show monster", function(monsterId, okFun, cancelFun, copyId, isMonsterBoss)
	local oppFormation = FormationData.getMonsterFormation(monsterId)
	local monster = findMonster(monsterId)
	local helpFormation = nil
	if monster and monster.help_monster ~= 0 then
		if copyId and not CopyData.checkClearance( copyId ) then
			helpFormation = FormationData.getMonsterFormation(monster.help_monster)
			FormationData.holdFormation(const.kFormationTypeCommon, helpFormation)
		end
	end
	showFormation(FormationData.STYLE_TWO, const.kFormationTypeCommon, okFun, cancelFun, oppFormation, monster.fightValue, copyId, helpFormation, isMonsterBoss, monsterId)
end)

Command.bind("formation show arena", function(oppFormation, okFun, cancelFun, exData)
	local style = oppFormation and FormationData.STYLE_TWO or FormationData.STYLE_ONE
	local type = oppFormation and const.kFormationTypeSingleArenaAct or const.kFormationTypeSingleArenaDef
	local fightValue = exData and exData.fight_value
	if oppFormation and exData and not ArenaData.isRealMan(exData.target_id) then
		for _,v in pairs(oppFormation) do
			v.isFake = true
		end
	end
	showFormation(style, type, okFun, cancelFun, oppFormation, fightValue, exData)
end)

--十字军东征
--@param type, const.kFormationTypeTrialSurvival等布阵类型
--@param oppFormation [可选]对手的布阵
--@param okFun [可选]开战回调
--@param cancelFun [可选]返回回调
--@param exData [可选]附加数据
Command.bind("formation show trial", function(type, monsterId, okFun, cancelFun, exData)
	local style = FormationData.STYLE_TWO
	local oppFormation = FormationData.getMonsterFormation(monsterId)
	-- local fightValue = exData and exData.fight_value
	showFormation(style, type, okFun, cancelFun, oppFormation, fightValue, exData)
end)

--大墓地
Command.bind("formation show tomb", function(monsterId, okFun, cancelFun, exData)
	local oppFormation
	local helpFormation
	if exData.attr == const.kAttrMonster then
		oppFormation = FormationData.getMonsterFormation(monsterId)
		local monster = findMonster(monsterId)
		if monster and monster.help_monster ~= 0 then
			helpFormation = FormationData.getMonsterFormation(monster.help_monster)
			FormationData.holdFormation(const.kFormationTypeTomb, helpFormation)
		end
	else
		local panel = TombData.panel_list[exData.target_id]
		if panel then
			oppFormation = panel.formation_map
		else
			LogMgr.error("没有对面玩家的布阵数据")
		end
	end
	local fightValue = nil
	showFormation(FormationData.STYLE_TWO, const.kFormationTypeTomb, okFun, cancelFun, oppFormation, fightValue, exData, helpFormation)
end)

--PRUserSingleArenaPanel
Command.bind("formation update arena", function(msg)
	if FormationData.oppExData and msg.target_id == FormationData.oppExData.target_id then
		local win = PopMgr.getWindow("FormationWin")
		if win and win:isShow() then
			win:updateArena()
		end
	end
end)

local function leaveFightHandler()
	if FormationData.reopen and SceneMgr.prev_scene_name == "fight" then
		FormationData.reopen = nil
		SceneMgr.enterScene("fight")
		doShowFormation(FormationData.type)
	end
end
EventMgr.addListener(EventType.SceneShow, leaveFightHandler)