local __this = PaperSkillData or {}
PaperSkillData = __this

-- skill_id为1级技能id
local skill_desc = {
	{name = "plate", title = "板甲制作", ability = "采矿能力", title_short = "板甲", occ = "战士，圣骑士，死亡骑士", equip_type = const.kEquipPlate, skill_id = 301},
	{name = "mail", title = "锁甲制作", ability = "采晶能力", title_short = "锁甲", occ = "猎人、萨满", equip_type = const.kEquipMail, skill_id = 201},
	{name = "leather", title = "皮甲制作", ability = "制皮能力", title_short = "皮甲", occ = "德鲁伊、潜行者、武僧", equip_type = const.kEquipLeather, skill_id = 101},
	{name = "cloth", title = "布甲制作", ability = "织布能力", title_short = "布甲", occ = "法师、牧师、术士", equip_type = const.kEquipCloth, skill_id = 1},
}

function __this.clear()
	__this.skill_desc = skill_desc
	__this.select_to_learn = 0
	__this.level_up_star = 0
	__this.level_up_money = 0
	__this.openPopType = PopWayMgr.SMALLTOBIG
	__this.closePopType = PopWayMgr.SMALLTOBIG
	__this.wins = {}
end
__this.clear()
EventMgr.addListener(EventType.UserLogout, __this.clear)

function __this.setWinShow(winName, value)
	if value then 
		__this.wins[winName] = true
	else
		__this.wins[winName] = nil
	end
	__this.openPopType = table.empty(__this.wins) and PopWayMgr.SMALLTOBIG or PopWayMgr.NONE
	__this.closePopType = table.nums(__this.wins) == 1 and PopWayMgr.SMALLTOBIG or PopWayMgr.NONE
end

function __this.getLearnCost(index)
	local desc = skill_desc[index]
	if desc == nil then
		return 0xffffffff
	end

	if desc.cost ~= nil then
		return desc.cost
	end

	local jSkill = findPaperSkill(desc.skill_id)
	if jSkill == nil then
		return 0xffffffff
	end
	return jSkill.level_up_star
end

function __this.getSkillId()
	return gameData.user.other.paper_skill
end

function __this.getJSkill()
	return findPaperSkill(gameData.user.other.paper_skill)
end

function __this.getNextJSkill(curJSkill)
	local nextJSkill = findPaperSkill(curJSkill.id + 1)
	if not nextJSkill or nextJSkill.skill_type ~= curJSkill.skill_type then
		return nil
	end
	return nextJSkill
end

function __this.getPaperSkillType()
	local jSkill = __this.getJSkill()
	if not jSkill then
		return 0
	else
		return jSkill.skill_type
	end
end

function __this.getPaperList()
	local ret = {}
	local jSkill = __this.getJSkill()
	if not jSkill then
		return ret
	end

	local json = GetDataList("PaperCreate")
	for i, jData in pairs(json) do
		if not jData.skill_type or jData.skill_type == 0 or jData.skill_type == jSkill.skill_type
			and jData.level_limit <= jSkill.paper_level_limit + 1 then
			ret[#ret + 1] = jData
		end
	end
	return ret
end

function __this.getData(skill_type)
	for _, v in pairs(skill_desc) do
		if v.equip_type == skill_type then
			return v
		end
	end
end

function __this.getSkillName(skill_type)
	local v = __this.getData(skill_type)
	if v then
		return v.title, v.title_short
	end
end

function __this.getAbility(skill_type)
	local v = __this.getData(skill_type)
	if v then
		return v.ability
	end
end

function __this.getBaseActiveScoreLimit()
	local v = findGlobal("base_active_score_limit")
	if not v then
		return 0
	else
		return v.data
	end
end

function __this.getCollectCost(level)
	local jData = findCopyMaterial(level)
	if not jData then
		return 0
	else
		return jData.active_score
	end
end
