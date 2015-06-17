FormationData = FormationData or {}

FormationData.STYLE_ONE = 1 --普通
FormationData.STYLE_TWO = 2 --怪物
FormationData.MAX_UP_COUNT = {} --等级=>{[const.kAttrTotem]=2, [const.kAttrSoldier]=3}

FormationData.DEFAULT_NAME_COLOR = cc.c3b(0xe5, 0xff, 0xa7)

function FormationData.clear()
	FormationData.style = FormationData.STYLE_ONE
	FormationData.type = const.kFormationTypeCommon
	FormationData.attr = const.kAttrSoldier
	FormationData.okFun = nil
	FormationData.cancelFun = nil
	FormationData.oppFormation = nil --对面的布阵数据
	FormationData.oppFightValue = nil --对面的战斗力
	FormationData.oppExData = nil --对面的附加数据	
	FormationData.helpFormation = nil --帮助武将的布阵
	FormationData.isMonsterBoss = nil --是否副本怪物Boss
	FormationData.monsterId = nil --对面的怪物ID
	FormationData.reopen = nil --获得战斗记录，播放完成，需要重新打开布阵
	FormationData.backupData = nil --打开布阵的时候的阵型信息
	FormationData.lastUpIndex = nil --最后上阵的位置
	FormationData.lastFightValue = nil --最后的战斗力
end
FormationData.clear() --初始化
EventMgr.addListener(EventType.UserLogout, FormationData.clear)

function FormationData.isTypeTrial(type)
	return const.kFormationTypeTrialSurvival == type or
		const.kFormationTypeTrialStrength == type or
		const.kFormationTypeTrialAgile == type or
		const.kFormationTypeIntelligence == type
end

--能否布阵
--第一章没通过不能布阵
function FormationData.getCanFormation(type)
	if type == const.kFormationTypeCommon then
		if gameData.getSimpleDataByKey("team_level") <= 10 then
			return false
		end
		local curCopyId = CopyData.getMaxCopyId() --当前副本ID
		return curCopyId >= 2000
	end
	return true
end

--设置推荐布阵
function FormationData.setRecommendFormation(callback)
	local curCopyId = gameData.user.copy.copy_id
	local jForCopy = findFormationCopy(curCopyId)
	if jForCopy then
		local type = const.kFormationTypeCommon
		local list = {}
		for _,v in ipairs(jForCopy.add) do
			local soldier = SoldierData.getSoldierBySId(v.first, const.kSoldierTypeCommon)
			if soldier then
				table.insert(list, FormationData.createFormation(type, soldier.guid, const.kAttrSoldier, v.second, false))
			else
				-- LogMgr.error("英雄还没获得")
			end
		end
		for _,v in ipairs(jForCopy.totem) do
			local totem = TotemData.getTotemById(v.first)
			if totem then
				table.insert(list, FormationData.createFormation(type, totem.guid, const.kAttrTotem, v.second, false))
			else
				-- LogMgr.error("图腾还没获得")
			end
		end
		if #list > 0 and not FormationData.compare(list, FormationData.getTypeData(type)) then --不一样
			FormationData.setTypeData(type, list)
			FormationData.sendToServer(type, callback)
			return
		end
	end
	if callback then
		callback()
	end
end

function FormationData.getData()
	return gameData.user.formation_map
end

--根据布阵类型获取阵型数据
function FormationData.getTypeData(type)
    local map = FormationData.getData()
    if map[type] == nil then
        map[type] = {}
    end
	return map[type]
end

--初始化空的布阵
function FormationData.initFormation(type)
	local data = FormationData.getData(type)
    if type ~= const.kFormationTypeCommon and table.empty(data) then
		FormationData.setTypeData(type, clone(FormationData.getTypeData(const.kFormationTypeCommon)))
		FormationData.sendToServer(type)
	end
end

--把帮助武将的位置占领
function FormationData.holdFormation(type, helpList)
	local list = FormationData.getTypeData(type)
	for _,v in pairs(helpList) do
		local index = gameData.findArrayIndex(list, "formation_index", v.formation_index)
		if index > 0 then
			table.remove(list, index)
		end
	end
end

function FormationData.setTypeData(type, list)
	FormationData.getData()[type] = list
end

function FormationData.createFormation(type, guid, attr, index, isFake)
	return {formation_type=type, guid=guid, attr=attr, formation_index=index, isFake=isFake}
end

--获取对面玩家的UserPanel
function FormationData.getPanel(type, attr, exData)
	if not exData then
		return
	end
	if attr ~= const.kAttrSoldier and attr ~= const.kAttrTotem then
		return
	end
	local panel
	if type == const.kFormationTypeSingleArenaAct or type == const.kFormationTypeSingleArenaDef then
		if ArenaData.isRealMan(exData.target_id) then
			panel = ArenaData.UserPanels[exData.target_id]
		end
	elseif type == const.kFormationTypeTomb then
		panel = TombData.panel_list[exData.target_id]
	end
	return panel
end

function FormationData.getGlyphList(type, attr, isMirror, exData, isFake)
	if isMirror then
		local panel = FormationData.getPanel(type, attr, exData)
		return panel and panel.totem_info and panel.totem_info.glyph_list
	elseif not isFake then
		return TotemData.getGlyphList()
	end
end

--获取服务器数据，图腾和英雄
function FormationData.getSData(type, guid, attr, isMirror, exData, isFake)
	local panel = nil
	if isMirror then
		panel = FormationData.getPanel(type, attr, exData)
	end
	if attr == const.kAttrSoldier then
		if isFake then
			return findSoldierExt(guid)
		elseif isMirror then
			if panel then
                return panel.soldier_map[guid]
			end
		else
			return SoldierData.getSoldier(guid)
		end
	elseif attr == const.kAttrTotem then
		if isFake then
			return findTotemExt(guid)
		elseif isMirror then
			if panel then
				return gameData.findArrayData(panel.totem_info.totem_list, "guid", guid)
			end
		else
			return TotemData.getTotem(guid)
		end
	elseif attr == const.kAttrMonster then
		return findMonster(guid)
	end
end

--获取品质颜色与+？
function FormationData.getNameColorAndNum(v, isMirror, exData)
	local sData = FormationData.getSData(v.formation_type, v.guid, v.attr, isMirror, exData, v.isFake)
	if sData then
		if v.attr == const.kAttrSoldier then
			local quality, num = SoldierData.getQualityAndNum(sData.quality)
			return QualityData.getColor(quality), num
		elseif v.attr == const.kAttrTotem then
			return QualityData.getColor(sData.level), ""
		end
	end
	return FormationData.DEFAULT_NAME_COLOR, ""
end

function FormationData.getJsonByGuid(type, guid, attr, isMirror, exData, isFake)
 	local sData = FormationData.getSData(type, guid, attr, isMirror, exData, isFake)
	local id = guid
	if (attr == const.kAttrSoldier) then
		id = sData and sData.soldier_id or 0
	elseif (attr == const.kAttrTotem) then
		if sData then
			id = sData and sData.totem_id or sData.id
		else
			id = 0
		end
	end
	return FormationData.getJson(id, attr), sData
end

function FormationData.getIdAndType(type, guid, attr, isMirror, exData, isFake)
    local sData = FormationData.getSData(type, guid, attr, isMirror, exData, isFake)
    local id = guid
    if (attr == const.kAttrSoldier) then
        id = sData and sData.soldier_id or 0
    elseif (attr == const.kAttrTotem) then
        id = sData and sData.totem_id or sData.id or 0
    end
    return id, attr 
end 


function FormationData.getJson(id, attr)
	local result
	if (attr == const.kAttrSoldier) then
		result = findSoldier(id)
	elseif (attr == const.kAttrTotem) then
		result = findTotem(id)
	elseif (attr == const.kAttrMonster) then
		result = findMonster(id)
	end
	return result
end

--获取阵型的索引上的数据
function FormationData.getDataByIndex(type, index)
	local list = FormationData.getTypeData(type)
	return gameData.findArrayData(list, "formation_index", index)
end

function FormationData.getIndexByGuid(type, guid, attr)
	local list = FormationData.getTypeData(type)
	for _,v in pairs(list) do
		if (v.attr == attr and v.guid == guid) then
			return v.formation_index
		end
	end
	return const.kFormationPosMax
end

--获取战斗力
function FormationData.getFightValueByType(type)
	local list = FormationData.getTypeData(type)
	return FormationData.getFightValue(list)
end

--获取战斗力
function FormationData.getFightValue(list)
	local fightvalue = 0
	for _,v in pairs(list) do
		if v.guid ~= 0 then
			fightvalue = fightvalue + SoldierData.getFightValue(v.guid, v.attr)
		end
	end
	return fightvalue
end

function FormationData.getIsUp(type, guid, attr)
	return FormationData.getIndexByGuid(type, guid, attr) ~= const.kFormationPosMax
end

function FormationData.getCanUpById(id)
	local soldier = SoldierData.getSoldierBySId(id)
	local isCan = false
	if soldier then
		isCan = not FormationData.getIsUp( const.kFormationTypeCommon, guid, const.kAttrSoldier )
	end
	return isCan
end

--获取能上阵的最大人数
function FormationData.getMaxUpCount(attr)
	local level = gameData.getSimpleDataByKey("team_level")
	local levelData = findLevel(level)
	local max = 0
	if attr == const.kAttrSoldier then
		max = levelData.formation_count
	elseif attr == const.kAttrTotem then
		max = levelData.formation_totem_count
	end
	local data = FormationData.MAX_UP_COUNT[level]
	if not data then
		data = {[const.kAttrTotem]=0,[const.kAttrSoldier]=0}
		local jList = GetDataList("FormationIndex")
		for _,v in pairs(jList) do
			if not v.level or v.level <= level then
				if FormationData.isTotemPos(v.index) then
					data[const.kAttrTotem] = data[const.kAttrTotem] + 1
				else
					data[const.kAttrSoldier] = data[const.kAttrSoldier] + 1
				end
			end
		end
		FormationData.MAX_UP_COUNT[level] = data
	end
	return math.min(max, data[attr])
end

--设置位置
function FormationData.checkCanUp(type, guid, attr)
	--判断能否上阵
	local max = FormationData.getMaxUpCount(attr)
	local count = FormationData.getCount(type, attr)
	if FormationData.helpFormation then
		count = count + FormationData.getCountByList(FormationData.helpFormation)
	end
	if (count >= max) then
		return false
	end
	return true
end

function FormationData.checkCanMove(type, guid, attr, index, showTips)
	local result = true
	if not FormationData.isIndexOpen(index) then
		if showTips then
			TipsMgr.showError("阵型位置未开放")
		end
		return false
	end
	if attr == const.kAttrTotem then
		result = FormationData.isTotemPos(index)
		if showTips and not result then
			TipsMgr.showError("图腾只可放在前面")
		end
	elseif attr == const.kAttrSoldier then
		result = not FormationData.isTotemPos(index)
		if showTips and not result then
			TipsMgr.showError("前面只可放置图腾")
		end
	end
	if result and FormationData.helpFormation then
		result = gameData.findArrayIndex(FormationData.helpFormation, "formation_index", index) == 0
		if showTips and not result then
			TipsMgr.showError("不能占用助阵位置")
		end
	end
	return result
end

function FormationData.isTotemPos(index)
	return index % 3 == 0
end

function FormationData.getAttrList(type, attr) --@return 筛选类型的数据
	local result = {}
	local list = FormationData.getTypeData(type)
	for _,v in pairs(list) do
		if (v.attr == attr) then
			table.insert(result, v)
		end
	end
	return result
end

function FormationData.getCount(type, attr)
	local list = FormationData.getTypeData(type)
	return FormationData.getCountByList(list, attr)
end

function FormationData.getCountByList(list, attr)
	local count = 0
	for _,v in pairs(list) do
		if (v.guid ~= 0 and v.attr == attr) then
			count = count + 1
		end
	end
	return count
end

--交换位置
function FormationData.switchIndex(type, from, to)
	if (not to or from == to) then
		return
	end
	local v = FormationData.getDataByIndex(type, from)
	if v then
		if FormationData.checkCanMove(type, v.guid, v.attr, to, true) then
			local tar = FormationData.getDataByIndex(type, to)
			if (tar) then
				tar.formation_index = from
			end
			v.formation_index = to
			return true
		end
	end
	return false
end

function FormationData.upByGuid(type, guid, attr, isSave)
	if not FormationData.checkCanUp(type, guid, attr) then
		return false
	end
	local list = FormationData.getTypeData(type)
	local oldIndex = FormationData.getIndexByGuid(type, guid, attr)
	if oldIndex ~= const.kFormationPosMax then
		return false --已经在阵型
	end
	local result = false
	local indexList = FormationData.getRecommendIndexList(type, guid, attr)
	for _,index in pairs(indexList) do
		if FormationData.isIndexOpen(index) then
			local formation = FormationData.getDataByIndex(type, index)
			if not formation then
				local helpIndex = 0
				if FormationData.helpFormation then
					helpIndex = gameData.findArrayIndex(FormationData.oppFormation, "formation_index", index)
				end
				if helpIndex == 0 then
					formation = FormationData.createFormation(type, guid, attr, index)
					table.insert(list, formation)
					result = true
					FormationData.lastUpIndex = index
					break
				end
			elseif formation.guid == 0 then
				formation.attr = attr
				formation.guid = guid
				result = true
				FormationData.lastUpIndex = index
				break
			end
		end
	end
	if result and isSave then
		FormationData.sendToServer(type)
	end
	return result
end
Command.bind("formation up", FormationData.upByGuid)

function FormationData.isIndexOpen(index)
	local level = FormationData.getIndexOpenLevel(index)
	return gameData.getSimpleDataByKey("team_level") >= level
end

function FormationData.getIndexOpenLevel(index)
	local formationIndex = findFormationIndex(index)
	local level = formationIndex and formationIndex.level or 0
	return level
end

--下一个开放的格子的FormationIndex数据
function FormationData.getNextOpenIndex(type)
	local result = nil
	local level = gameData.getSimpleDataByKey("team_level")
	for i = 0, const.kFormationPosMax - 1 do
		local fIndex = findFormationIndex(i)
		if fIndex.level > level then
			if result then
				if result.level > fIndex.level then
					result = fIndex
				end
			else
				result = fIndex
			end
		end
	end
	return result
end

function FormationData.downByGuid(type, guid, attr)
	local list = FormationData.getTypeData(type)
	for i,v in pairs(list) do
		if (v.attr == attr and v.guid == guid) then
			table.remove(list, i)
			return true
		end
	end
	return false
end

--推荐站位
local recommend = {
[0]={0, 3, 6}, [3]={3, 0, 6}, [6]={6, 3, 0},
[1]={1, 4, 7, 2, 5, 8}, [4]={4, 1, 7, 2, 5, 8}, [7]={7, 4, 1, 2, 5, 8},
[2]={2, 5, 8, 1, 4, 7}, [5]={5, 2, 8, 1, 4, 7}, [8]={8, 5, 2, 1, 4, 7}
}
--获取推荐站位
function FormationData.getRecommendIndexList(type, guid, attr)
	if (attr == const.kAttrTotem) then
		return recommend[3]
	elseif (attr == const.kAttrSoldier) then
        local soldier = FormationData.getJsonByGuid(type, guid, attr)
		if (soldier) then
			return recommend[soldier.formation]
		end
		return recommend[4]
	end
end

function FormationData.getMonsterFormation(monsterId, ftype)
	ftype = ftype or const.kFormationTypeCommon
	local monster = findMonster(monsterId)
	if monster and #monster.fight_monster > 0 then
		local conf = findMonsterFightConf(monster.fight_monster[1])
		if conf then
			local list = {}
			for _,v in ipairs(conf.add) do
				local f = FormationData.createFormation(ftype, v.first, const.kAttrMonster, v.second, true)
				table.insert(list, f)
			end
			for _,v in ipairs(conf.totemadd) do
				local f = FormationData.createFormation(ftype, v.first, const.kAttrTotem, v.second, true)
				table.insert(list, f)
			end
			return list
		end
	end
	return {}
end

local recommendData = {
	[const.kFormationTypeCommon]={
		[const.kAttrSoldier]={"点击头像进行上下阵操作", 0},
		[const.kAttrTotem]={"点击图腾进行上下阵操作", 0}
	},
	[const.kFormationTypeTrialSurvival]={
		[const.kAttrSoldier]={"本玩法推荐使用板甲英雄", const.kEquipPlate},
		[const.kAttrTotem]={"本玩法推荐使用土系图腾", const.kTotemTypeDaDi}
	},
	[const.kFormationTypeTrialStrength]={
		[const.kAttrSoldier]={"本玩法推荐使用锁甲英雄", const.kEquipMail},
		[const.kAttrTotem]={"本玩法推荐使用火系图腾", const.kTotemTypeHuoYan}
	},
	[const.kFormationTypeTrialAgile]={
		[const.kAttrSoldier]={"本玩法推荐使用皮甲英雄", const.kEquipLeather},
		[const.kAttrTotem]={"本玩法推荐使用风系图腾", const.kTotemTypeKongQi}
	},
	[const.kFormationTypeIntelligence]={
		[const.kAttrSoldier]={"本玩法推荐使用布甲英雄", const.kEquipCloth},
		[const.kAttrTotem]={"本玩法推荐使用水系图腾", const.kTotemTypeShuiLiu}
	}
}
--获取推荐文字
function FormationData.getRecommendText(type, attr)
	if recommendData[type] then
		return recommendData[type][attr][1]
	end
    return recommendData[const.kFormationTypeCommon][attr][1]
end

--是否推荐英雄或图腾
function FormationData.isRecommend(type, attr, tType)
	local data = recommendData[type]
	if data then
		local rType = data[attr][2]
		if rType ~= 0 then
			return rType == tType
		end
	end
	return false
end

function FormationData.sortFunc(a, b)
	if a and b then
		return a.formation_index < b.formation_index
	end
	return false
end

--检查2个阵型是否一样，一样返回true
function FormationData.compare(list1, list2)
	if #list1 ~= #list2 then
		return false
	end
	table.sort(list1, FormationData.sortFunc)
	table.sort(list2, FormationData.sortFunc)
	for i = 1, #list1 do
		local v1, v2 = list1[i], list2[i]
		if (v1.guid ~= v2.guid or v1.attr ~= v2.attr) then
			return false
		end
		if v1.formation_index ~= v2.formation_index or v1.formation_type ~= v2.formation_type then
			return false
		end
	end
	return true
end

--保存到服务器
function FormationData.sendToServer(type, callback)
	local list = FormationData.getTypeData(type)
	for i = #list, 1, -1 do
		local v = list[i]
		if (v.guid == 0) then
			table.remove(list, i)
		end
	end
	if const.kFormationTypeCommon == type then
		UserData.updateFightValue()
	end
	if callback then
		trans.sendReturnMsg("PQFormationSet", {formation_type=type, formation_list=list}, callback)
	else
		trans.send_msg("PQFormationSet", {formation_type=type, formation_list=list}, callback)
	end
    if type == const.kFormationTypeCommon and gameData.user.copy.copy_id ~= 0 then
		CopyMgr.isChange = true
	end
end

--获取所有武将，图腾，怪物的json数据
function FormationData.getCurrentList()
	local result = {}
	result[const.kAttrSoldier] = {}
	result[const.kAttrTotem] = {}
	result[const.kAttrMonster] = {}
	local list = FormationData.getTypeData(FormationData.type)
	local isMirror = false
	for _,v in pairs(list) do
		if v.guid then
			local json = FormationData.getJsonByGuid(FormationData.type, v.guid, v.attr, isMirror, FormationData.oppExData, v.isFake)
			if json then
				table.insert(result[v.attr], json)
			end
		end
	end
	isMirror = true
	list = FormationData.oppFormation
	if list then
		for _,v in pairs(list) do
			if v.guid then
				local json = FormationData.getJsonByGuid(FormationData.type, v.guid, v.attr, isMirror, FormationData.oppExData, v.isFake)
				if json then
					table.insert(result[v.attr], json)
				end
			end
		end
	end
	return result
end

--获取坐标
function FormationData.getRolePos(index, isMirror)
	if isMirror then
		index = const.kFormationPosMax + index
	end
	local station = FightData.stationList:get(index)
	return cc.p(station.vX, station.vY)
end

function FormationData.checkCanUpSoldier(type)
	local count = FormationData.getCount(type, const.kAttrSoldier)
    local max = FormationData.getMaxUpCount(const.kAttrSoldier)
    if count < max then
    	local num = 0
        if type == const.kFormationTypeTomb then --大墓地
        	num = FormationData.getTombLiveSoldierCount()
        else
        	num = SoldierData.getCount()
        end
        return count < num
    end
    return false
end

function FormationData.checkCanUpTotem(type)
	local count = FormationData.getCount(type, const.kAttrTotem)
    local max = FormationData.getMaxUpCount(const.kAttrTotem)
    if count < max then
        local num = TotemData.getCount()
        return count < num
    end
    return false
end

--大墓地可用武将数目
function FormationData.getTombLiveSoldierCount()
	local list = SoldierData.getTable(const.kSoldierTypeTombSelf)
	local deadCount = 0
	for _,v in pairs(list) do
		if v and v.hp == 0 then
			deadCount = deadCount + 1
		end
	end
	return SoldierData.getCount() - deadCount
end

--检查大墓地武将是否死亡
function FormationData.checkIsTombDead(guid)
	local extAble = TombData.getTargetFightSoldier(const.kSoldierTypeTombSelf, guid)
    return extAble and 0 == extAble.hp
end

--有人的情况，判断一个椭圆的区域
local a1, b1 = 55, 80
function FormationData.hitTestMethod1(location, index)
	local a, b = a1, b1
	local station = FightData.stationList:get(index)
	local x0 = location.x - station.vX
	local y0 = location.y - station.vY - a
	if x0 * x0 / (a * a) + y0 * y0 / (b * b) <= 1 then
		return true
	end
end

--无人的情况，判断脚下圈圈的范围
local a2 = (FightData.stationList:get(0).vX - FightData.stationList:get(2).vX) / 4
local b2 = (FightData.stationList:get(1).vY - FightData.stationList:get(7).vY) / 4
function FormationData.hitTestMethod2(location, index)
	local a, b = a2, b2
	local station = FightData.stationList:get(index)
	local x0 = location.x - station.vX
	local y0 = location.y - station.vY
	if -a < x0 and x0 < a and -b < y0 and y0 < b then
		return true
	end
end

--碰撞检测
--location touch:getLocation()
--hasRole 是否角色优先
--hasRight 右边是否有人
--roles 角色字典index=>FightRoleView
--返回index，左边0-8，右边9-17，没有则返回nil
function FormationData:hitTest(location, hasRole, hasRight, roles) --@return 
	location.x = toint(location.x)
	location.y = toint(location.y)
	local start, step = 0, 1
    local stop = hasRight and 2 * const.kFormationPosMax - 1 or const.kFormationPosMax - 1
	if hasRole then
		start, stop, step = stop, start, -step
		local a, b = 55, 80
		for i = start, stop, step do
			if roles[i] then
				if FormationData.hitTestMethod1(location, i) then
					return i
				end
			else
				if FormationData.hitTestMethod2(location, i) then
					return i
				end
			end
		end
	else
		for i = start, stop, step do
			if FormationData.hitTestMethod2(location, i) then
				return i
			end
		end
	end
	return nil
end

--下阵非法角色
function FormationData.downIllegalRole(type)
	local list = FormationData.getTypeData(type)
	for i = #list, 1, -1 do
		local v = list[i]
		if not FormationData.isIndexOpen(v.formation_index) then
			table.remove(list, i)
		end
	end
end