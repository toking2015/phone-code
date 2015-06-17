local __this = {}
BuildingMgr = __this

__this.prePath = "image/ui/NHolyUI/"
__this.buildingType = nil
__this.MAXLEVEL = 10 --建筑最大等级
__this.CDTIME = 600

-- 是否开放加速界面
function __this.isOpenSpeedPanel(type)
	local tLevel = gameData.getSimpleDataByKey("team_level")
	if tLevel < 20 then
		return false, "战队20级开放"
	elseif BuildingData.checkBuildingExist(type) then
		return true, ""
	else
		return false, "该建筑尚未开启"
	end
end

function __this.getCDTime(type, tCD)
	local st = {[2] = "00:00:", [5] = "00:", [8] = ""}
	local t_str = DateTools.secondToStringTwo(tCD)
	if string.len(t_str) >= 11 then t_str = string.sub(t_str, 4) end

    return tCD ~= 0, st[string.len(t_str)] .. t_str
end

-- 根据类型获取建筑的一些图片
function __this.getInfoByType(type)
	if nil ~= type and type ~= const.kBuildingTypeWaterFactory and type ~= const.kBuildingTypeGoldField then
		LogMgr.debug("建筑类型错误")
		type = const.kBuildingTypeWaterFactory
	end
	if type == const.kBuildingTypeWaterFactory then
		return "holy_icon.png", "holy_name.png", "holy_container.png", "holy_txt_prod.png", "solution.png"
	else
		return "mine_icon.png", "mine_name.png", "mine_container.png", "mine_txt_prod.png", "coin.png"
	end
end

function __this.getBuildingDesc(type)
	local desc = ""
	if type == const.kBuildingTypeWaterFactory then
		desc = "       太阳井是获得圣水的主要来源，圣水可以用来升级英雄。升级太阳井可提高圣水的生产效率与储存上限。"
	elseif type == const.kBuildingTypeGoldField then
		desc = "       金矿是获得金币的主要来源，金币可以用来干许多事，有钱就是这么任性！升级金矿可提高金币的生产效率与储存上限。"
	end
	return desc
end

function __this.getUpgradeCondition(type)
	type = type or 2
	local cond = ""
	local bLevel = BuildingData.getBuildingLevel(type)
	local next_lev = (bLevel == BuildingMgr.MAXLEVEL) and BuildingMgr.MAXLEVEL or (bLevel + 1)
    local list = GetDataList('BuildingUpgrade')[type]
    local tLevel = tonumber(list[next_lev].u_level)
	if type == const.kBuildingTypeWaterFactory then
		cond = "       战队达到" .. tLevel .. "级，可提升太阳井至".. next_lev .."级"
	elseif type == const.kBuildingTypeGoldField then
		cond = "       战队达到" .. tLevel .. "级，可提升金矿至".. next_lev .."级"
	end
	return cond
end

-- 根据建筑类型显示圣水和金矿
local function showBuildingByType(type)
	__this.buildingType = type
	Command.run('ui show', 'BuildingUI', PopUpType.SPECIAL)
end
EventMgr.addListener(EventType.showBuildingInfoByType, showBuildingByType)