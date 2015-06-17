
SFightClientSkillObject = {}
function SFightClientSkillObject:new(time, totem_time, SFightSkillObject)
	local o = 
	{
		time = time,
		totem_time = totem_time,
		skill_object = SFightSkillObject,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

SFightClientRoundData = {}
function SFightClientRoundData:new(time, totem_time, log_list)
	local o = 
	{
		time = time,
		totem_time = totem_time,
		log_list = log_list,
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

SFightClientLog = {}
function SFightClientLog:new(fight_id, fight_type, fight_randomseed, fight_info_list)
	local o = 
	{
		fight_id = fight_id,
		fight_type = fight_type,
		fight_randomseed = FightFileMgr:copyTab(fight_randomseed),
		fight_info_list = FightFileMgr:copyTab(fight_info_list),
		round_soldier = {},
		round_data_list = {},
		totem_skill_list = {},
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

