-- create by  印佳
-- time :2014-4-8

-- 战斗英雄
require("lua/server/LoadStaticData")
require("lua/trans/constant")
require("lua/trans/fight")
require("lua/trans/common")
require("lua/server/DebugDump")
require("lua/server/EffectToExt")
local YiLiDan = require("lua/server/YiLiDan")
--local profiler = require("profiler")

--普通攻击攻击序列 三个站位,所以有三个序列
-- 2 1 0  A站位 目标攻击序列1
-- 5 4 3  B站位 目标攻击序列2
-- 8 7 6  C站位 目标攻击序列3
local fightSkillCommonAttack = {{0,3,6,1,4,7,2,5,8},{3,0,6,4,1,7,5,2,8},{6,3,0,7,4,1,8,5,2}}
local const = trans.const
local err = trans.err
local findOdd = findOdd
local toMyNumber = toMyNumber

local function copyTab(st)
	local tab = {}
	for k, v in pairs(st or {}) do
		if type(v) ~= "table" then
			tab[k] = v
		end
	end
	return tab
end

--速度排序函数
local function sortFunC(a,b)
	if a.attr == const.kAttrTotem and b.attr == const.kAttrTotem then
		return a.last_ext_able.speed < b.last_ext_able.speed
	elseif a.attr == const.kAttrTotem then
		return true
	elseif b.attr == const.kAttrTotem then
		return false
	else
		return a.last_ext_able.speed > b.last_ext_able.speed
	end
end

local function setSoldierDel( soldier )
	--soldier.hp = 0
	soldier.delFlag = 1
end

--位置排序函数
local function sortFunIndex(a,b)
	return a.fight_index < b.fight_index
end

--位置排序函数2
local function sortFunIndexDesc(a,b)
	return a.fight_index > b.fight_index
end

local function getTenSoldier( liveSoldier, index )
	local list = { index, index-1,index+1,index-3,index+3}
	for _, v in pairs(list) do
		if v > 8 or v < 0 then
			v = nil
		end
	end
	
	local tarSoldier = {}
	for _, soldier in pairs(liveSoldier) do
		for _, index in pairs(list) do
			if index == soldier.fight_index then
				table.insert(tarSoldier, soldier)
				break
			end
		end
	end
	
	return tarSoldier
end

--战斗
if not theFightList then
	theFightList = {}
end

local CFight = {
}

local FightEndInfo = {
}

function FightEndInfo:new()
	local o = {
		camp = 0,
		round = 0,
		hurt = 0,
		attack_count = 0,
		dodge_count = 0,
		recover = 0,
		magic_hurt = 0,
		dead_count = 0
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function CFight:new(fight)
	local o = fight or {}
	setmetatable(o, self)
	self.__index = self
	return o
end

function CFight:initFight(seed)
	self.round = 0
	self.fightType = 0
	self.winCamp = 0
	self.isAutoFight = 0
	self.disillusionIndex = 0
	--参加的阵营

	self.userList = {}
	--参加英雄
	self.soldierList = {}
	--本回合攻击的英雄
	self.soldierAttackList = {}
	self.soldierAttackListIndex = 0
	self.orderList = {}
	self.checkOrderList = {}
	self.soldierEndList = {}
	self.fightEndInfo = {}
	LogMgr.log( 'fight', "initSeed" .. seed.value)
	self.fightSeed = seed
end

local FightOrderTarget = {

}

function FightOrderTarget:new(soldier)
	local o =
	{
	guid = soldier.guid, --角色ID被打的角色ID
	attr = soldier.attr, --人物标识 英雄/图腾
	rage = soldier.rage, --当前怒气
	hp = soldier.hp, --当前血量

	fight_might = 0, --第几次出手

	fight_result = 0, --战斗结果 扣血 加血等

	fight_type = const.kFightCommon, --战斗类型 暴击 格挡等

	fight_attr = 0, --特殊的表达形式

	fight_value = 0, --战斗值

	totem_value = soldier:getTotemValue(), --图腾值
	max_hp = soldier.last_ext_able.hp,
	odd_id = 0,		--ODDID造成的伤害

	odd_list = {},  --当前玩家ODD变更列表
	odd_list_triggered = {} --触发的guid和oddid
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

local FightLog = {

}

function FightLog:new( _r )
	local o =
	{
	round = _r,
	order = {},	--使用的技能

	orderTargetList = {} --造成的伤害列表

	}
	setmetatable(o, self)
	self.__index = self
	return o
end

local FightOddSet = {

}

function FightOddSet:new()
	local o =
	{
	guid = 0,
	set_type = 0,
	fightOdd = {}
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

local FightOddTriggered = {

}
function FightOddTriggered:new(_use_guid,_odd_id, target_list)
	local o =
	{
	use_guid = _use_guid or 0,
	odd_id = _odd_id or 0,
	targetList = target_list or {}
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

local FightOdd = {

}

function FightOdd:new( odd )
	local o =
	{
	id = odd.id,
	level = odd.level,
	start_round = 0,
	status_id = odd.status.cate,
	status_value = odd.status.objid,
	use_count = 0,
	delFlag = 0,
	ext_value = 0,
	begin_round = 0,
	now_count = 1,
    podd = odd
	}
	setmetatable(o, self)
	self.__index = self
	return o
end

function FightOdd:findOdd()
    if nil == self.podd then
        self.podd = findOdd(self.id, self.level)
    end
    return self.podd
end

function FightOdd:newtable( odd )
    local odd = odd or {}
    setmetatable(odd, self)
    self.__index = self
    return odd
end

local FightSoldier = {

}

function FightSoldier:new(soldier)
	local soldier = soldier or {}
	setmetatable(soldier, self)
	self.__index = self
	return soldier
end

function FightSoldier:addOddCount(fightOdd)
	if nil == fightOdd.use_count then
		fightOdd.use_count = 0
	end
	fightOdd.use_count = fightOdd.use_count + 1
	if nil == self.limitCountAll[fightOdd.id] then
		self.limitCountAll[fightOdd.id] = 0
	end
	self.limitCountAll[fightOdd.id] = self.limitCountAll[fightOdd.id] + 1
end

function FightSoldier:addRage(_r)
	if 0 == _r then
		return
	end
	
	local add_r = self.last_ext_able.recover_add_fix - self.last_ext_able.recover_del_fix
	local add_per = self.last_ext_able.recover_add_per - self.last_ext_able.recover_del_per
	
	--怒气获得速度提高
	local fightOdd = self:findFightOdd(const.kFightOddRageBuff)
	if nil ~= fightOdd then
		add_per = add_per + fightOdd.status_value
	end
	
	_r = _r + add_r
	
	--石化
	local fightOdd = self:findFightOdd(const.kFightOddStone)
	if nil ~= fightOdd then
		_r = 0
	end
	
	--容错
	if _r < 0 then
		_r = 0
	end
	if add_per < 1000 then
		add_per = 1000
	end
	
	_r =  math.modf(_r * (1 + add_per/10000))
	
	self.rage = self.rage + _r
	if self.rage > 100 then
		self.rage = 100
	end
end

function FightSoldier:delRage(_r)
	self.rage = self.rage - _r
	if self.rage < 0 then
		self.rage = 0
	end
	LogMgr.log( 'fight',  "soldier(" .. self.name .. "):" .. self.guid .. " delRage:" .. _r .. " nowrage:" .. self.rage )
end

function FightSoldier:addTotemValue(_r)
	if 0 == _r then
		return
	end
	local theFight = theFightList[self.selfFightId]
	local user = theFight:findUser(self.selfUserGuid)
	if nil == user then
		return
	end
	
	user:addTotemValue(_r)
end

function FightSoldier:delTotemValue(_r)
	if 0 == _r then
		return
	end
	local theFight = theFightList[self.selfFightId]
	local user = theFight:findUser(self.selfUserGuid)
	if nil == user then
		return
	end
	user.totem_value = user.totem_value - _r
	
	if user.totem_value < 0 then
		user.totem_value = 0
	end
	
	LogMgr.log( 'fight', "soldier guid(" .. self.name .. "):" .. self.guid .. " del totemvalue:" .. _r .. " now:" .. user.totem_value )
end

function FightSoldier:getTotemValue()
	local theFight = theFightList[self.selfFightId]
	local user = theFight:findUser(self.selfUserGuid)
	if nil == user then
		return 0
	end
	return user.totem_value
end

function FightSoldier:getCamp()
	local theFight = theFightList[self.selfFightId]
	local user = theFight:findUser(self.selfUserGuid)
	if nil == user then
		return 0
	end
	return user.camp
end

function FightSoldier:addPlayFlag()
	if self.attr ~= const.kAttrTotem then
		self.isPlay = 1
	end
end

function FightSoldier:delPlayFlag()
	self.isPlay = 0
end

function FightSoldier:checkEnd()
	return 0 == self.hp or 1 == self.delFlag
end

function FightSoldier:delFightOdd( fightOdd, orderTargetList, fightOrderTarget )
	for index, selfodd in pairs( self.odd_list ) do
		if selfodd.id == fightOdd.id and selfodd.level == fightOdd.level then
			local odd = fightOdd:findOdd()
			if nil == odd then
				table.remove(self.odd_list, index)
				return
			end
			
			if const.kFightOddAttrCantDel == toMyNumber(odd.attr) then
				return
			end
			
			self:delFightExt(fightOdd, orderTargetList)
			
			local fightOddSet = FightOddSet:new()
			fightOddSet.guid = self.guid
			fightOddSet.set_type = const.kObjectDel
			fightOddSet.fightOdd = copyTab(fightOdd)
			table.insert(fightOrderTarget.odd_list,fightOddSet)
			
			table.remove(self.odd_list, index)
			return
		end
	end
end

function FightSoldier:setFightOddSpe( fightOdd, fightOrderTarget )
	table.insert( self.odd_list, fightOdd )
	self:addFightExt(fightOdd)
	
	--添加BUFF
	local fightOddSet = FightOddSet:new()
	fightOddSet.guid = self.guid
	fightOddSet.set_type = const.kObjectAdd
	fightOddSet.fightOdd = copyTab(fightOdd)
	table.insert(fightOrderTarget.odd_list,fightOddSet)
end

function FightSoldier:setFightOdd( odd, start_round, use_guid, orderTargetList, fightOrderTarget )
	if nil == odd then
		return false
	end
	
	if self.attr == const.kAttrTotem and odd.attr == const.kFightOddAttrDebuff then
		return false
	end
	
	local fightOdd = FightOdd:new(odd)
	fightOdd.start_round = start_round
	fightOdd.begin_round = start_round
	fightOdd.use_guid = use_guid
	
	local theFight = theFightList[self.selfFightId]
	
	--定几率免疫昏迷(这个可以做出一定几率免疫某个statusid的buff)
	local fightOddImmune = self:findFightOdd(const.kFightOddImmune)
	if nil ~= fightOddImmune then
		local oddImmune = fightOddImmune:findOdd()
        if nil ~= oddImmune and odd.status.cate == oddImmune.status.objid and theFight:fightRand() < oddImmune.status.val then
			local oddTriggered = FightOddTriggered:new(self.guid, fightOddImmune.id)
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			return false
		end
	end
	
	--免疫所有控制类的buff
	local fightOddControl = self:findFightOdd(const.kFightOddControlInvincible)
	if nil ~= fightOddControl and odd.type == fightOddControl.status_value then
		local oddTriggered = FightOddTriggered:new(self.guid, fightOddControl.id)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		return false
	end
	
	--每层疾病效果使对面的防御与攻击都降低1
	local tarSoldier = theFight:findSoldier(use_guid)
	if nil ~= tarSoldier then
    	local fightOddDiseaseChange = tarSoldier:findFightOdd(const.kFightOddDiseaseChange)
    	if nil ~= fightOddDiseaseChange and fightOddDiseaseChange.status_value == fightOdd.status_id then
    		local odd = fightOddDiseaseChange:findOdd()
    		if nil ~= odd then
				local addOdd = findOdd(odd.addodd.first,odd.addodd.second)
				if nil ~= addOdd then
					fightOdd = FightOdd:new(addOdd)
					fightOdd.start_round = start_round
					fightOdd.begin_round = start_round
					fightOdd.use_guid = use_guid
				end
    		end
    	end
	end
	
	--向友方血量最低目标释放愈合祷言，该目标在受到伤害后，愈合祷言会为其回复大量血量，并且弹射到下一个血量最低的友方单位
	--特殊BUFF处理
	if odd.status.cate == const.kFightOddRecoverHPMin then
		local user = theFight:getTarUser( self, const.kFightTargetSelf )
		for _, soldier in pairs( user.soldier_list ) do
			local tar_fightOdd = soldier:findFightOdd(const.kFightOddRecoverHPMin)
			if nil ~= tar_fightOdd and tar_fightOdd.use_guid == use_guid then
				soldier:delFightOdd(tar_fightOdd, orderTargetList, fightOrderTarget)
			end
		end
	end
	
	--特殊BUFF处理
	
	--特殊BUFF的处理

	if const.kFightOddFire2 == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000))
			fightOdd.id = const.kOddFireID
			fightOdd.level = 1
			fightOdd.status_id = const.kFightOddFireFix
			fightOdd.status_value = value
			fightOdd.podd = findOdd(const.kOddFireID,1)
		end
	end
	
	--特殊BUFF处理
	if const.kFightOddLightningFix == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000))
			fightOdd.status_value = value
		end
	end
	
	--特殊BUFF处理
	if const.kFightOddAttackHpRecover == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000))
			fightOdd.status_value = value
		end
	end
	
	--特殊BUFF处理
	if const.kFightOddRecoverCount == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000))
			fightOdd.status_value = value
		end
	end
	
	if const.kFightOddRecoverByHP == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack))
			fightOdd.status_value = value
		end
	end
	
	--特殊BUFF的处理

	if const.kFightOddDef == fightOdd.status_id then
		local value = math.modf(self.last_ext_able.hp * (fightOdd.status_value/10000))
		fightOdd.id = const.kOddDefineID
		fightOdd.level = 1
		fightOdd.status_id = const.kFightOddDefFixed
		fightOdd.status_value = value
		fightOdd.ext_value = fightOdd.status_value
		fightOdd.podd = findOdd(const.kFightOddDefFixed,1)
	end
	
	--特殊BUFF的处理

	if const.kFightOddDefFixed == fightOdd.status_id then
		fightOdd.ext_value = fightOdd.status_value
	end
	
	--fightOddDefAll
	if const.kFightOddDefAll == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(tarSoldier.last_ext_able.hp * (fightOdd.status_value/10000))
			fightOdd.status_value = value
		end
	end
	
	--可以生成一个寒冰护盾，吸收大量伤害，持续2回合,每场战斗只触发一次，改护盾被打破时不会给打破的人造成伤害
	if const.kFightOddIceDef == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000))
			fightOdd.status_value = value
		end
	end
	
	--疾病
	if const.kFightOddDisease == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000) )
			fightOdd.status_value = value
		end
	end
	
	--燃烧可以叠加的.这个是根据玩家攻击的百分比的燃烧
	if const.kFightOddFireCount == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000) )
			fightOdd.status_value = value
		end
	end
	
	--新加一个可以叠加的燃烧效果，叫做毒药。

	if const.kFightOddPoison == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000) )
			fightOdd.status_value = value
		end
	end
	
	
	--新加一个可以叠加的燃烧效果，叫做流血效果
	if const.kFightOddBlood == fightOdd.status_id then
		local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
		if nil ~= tarSoldier then
			local value = math.modf(math.max(tarSoldier.last_ext_able.physical_ack,tarSoldier.last_ext_able.magic_ack) * (fightOdd.status_value/10000) )
			fightOdd.status_value = value
		end
	end
	
	--眩晕抵抗
	if const.kFightOddStun == fightOdd.status_id then
		if theFight:fightRand() < self.last_ext_able.stun_def then
			return false
		end
	end
	
	local exist_odd = self:findFightOddById( odd.id )
	if nil ~= exist_odd then
		if odd.max_count >= exist_odd.now_count then
			if exist_odd.level == fightOdd.level then
				self:delFightExt(exist_odd, orderTargetList)
                exist_odd.now_count = exist_odd.now_count + 1 > odd.max_count and odd.max_count or exist_odd.now_count + 1
				exist_odd.start_round = fightOdd.start_round
				fightOdd = exist_odd
				self:addFightExt(fightOdd, orderTargetList)
				local fightOddSet = FightOddSet:new()
				fightOddSet.guid = self.guid
				fightOddSet.set_type = const.kObjectUpdate
				fightOddSet.fightOdd = copyTab(exist_odd)
				table.insert(fightOrderTarget.odd_list,fightOddSet)
			elseif exist_odd.level < fightOdd.level then
				self:delFightOdd(exist_odd, orderTargetList, fightOrderTarget)
				fightOdd.now_count = exist_odd.now_count + 1 > odd.max_count and odd.max_count or exist_odd.now_count + 1
				table.insert( self.odd_list, fightOdd )
				self:addFightExt(fightOdd, orderTargetList)
				
				--添加BUFF
				local fightOddSet = FightOddSet:new()
				fightOddSet.guid = self.guid
				fightOddSet.set_type = const.kObjectAdd
				fightOddSet.fightOdd = copyTab(fightOdd)
				table.insert(fightOrderTarget.odd_list,fightOddSet)
			else
				--低等级不能覆盖高等级
				return false
			end
			if exist_odd.now_count == odd.max_count and nil ~= odd.changeodd.first then
				local changeoOdd = findOdd( odd.changeodd.first, odd.changeodd.second )
				if nil ~= changeoOdd then
					self:delFightOdd(exist_odd, orderTargetList, fightOrderTarget)
					self:setFightOdd(changeoOdd, theFight.round, self.guid, orderTargetList, fightOrderTarget)
					return true
				end
			end
		else
			if ((exist_odd.level < fightOdd.level) or (exist_odd.level == fightOdd.level and exist_odd.status_value < fightOdd.status_value) or (0 ~= odd.limit_count_all and toMyNumber(self.limitCountAll[fightOdd.id]) >= odd.limit_count_all)) then
				self:delFightOdd(exist_odd, orderTargetList, fightOrderTarget)
				
				table.insert( self.odd_list, fightOdd )
				self:addFightExt(fightOdd, orderTargetList)
				
				--添加BUFF
				local fightOddSet = FightOddSet:new()
				fightOddSet.guid = self.guid
				fightOddSet.set_type = const.kObjectAdd
				fightOddSet.fightOdd = copyTab(fightOdd)
				table.insert(fightOrderTarget.odd_list,fightOddSet)
			else
				return false
			end
		end
	else
		table.insert( self.odd_list, fightOdd )
		self:addFightExt(fightOdd, orderTargetList)
		
		--添加BUFF
		local fightOddSet = FightOddSet:new()
		fightOddSet.guid = self.guid
		fightOddSet.set_type = const.kObjectAdd
		fightOddSet.fightOdd = copyTab(fightOdd)
		table.insert(fightOrderTarget.odd_list,fightOddSet)
	end
	
	if 0 ~= toMyNumber(odd.immediately) then
		self:oddEffect(fightOdd, orderTargetList)
	end
	
	return true
end

function FightSoldier:checkOdd( round, fightOdd )
	local odd = fightOdd:findOdd()
	if nil == odd then
		return false
	end
	if (0 == toMyNumber(odd.delay_round) or round - fightOdd.start_round >= toMyNumber(odd.delay_round)) and (0 == toMyNumber(odd.limit_count) or fightOdd.use_count < toMyNumber(odd.limit_count)) and (0 == toMyNumber(odd.limit_count_all) or toMyNumber(self.limitCountAll[fightOdd.id]) < toMyNumber(odd.limit_count_all)) then
		return true
	end
	return false
end

function FightSoldier:checkDelOdd( round, fightOdd )
	local odd = fightOdd:findOdd()
	if nil == odd then
		return true
	end
	return (0 ~= toMyNumber(odd.keep_round) and round - fightOdd.start_round >= toMyNumber(odd.keep_round)) or (0~= toMyNumber(odd.limit_count) and fightOdd.use_count >= toMyNumber(odd.limit_count)) or (0 ~= toMyNumber(odd.limit_count_all) and toMyNumber(self.limitCountAll[fightOdd.id]) >= toMyNumber(odd.limit_count_all) )
end

function FightSoldier:findFightOdd( status_id )
	local theFight = theFightList[self.selfFightId]
	for _, fightOdd in pairs(self.odd_list) do
		local odd = fightOdd:findOdd()
		if nil == odd then
			return nil
		end
		if fightOdd.status_id == status_id and self:checkOdd( theFight.round, fightOdd ) then
			return fightOdd
		end
	end
	
	return nil
end

function FightSoldier:findFightOddList( status_id )
	local odd_list = {}
	local theFight = theFightList[self.selfFightId]
	for _, fightOdd in pairs(self.odd_list) do
		local odd = fightOdd:findOdd()
		if nil == odd then
			return odd_list
		end
		if fightOdd.status_id == status_id and self:checkOdd( theFight.round, fightOdd ) then
			table.insert(odd_list, fightOdd)
		end
	end
	
	return odd_list
end

function FightSoldier:findFightOddById( id )
	local theFight = theFightList[self.selfFightId]
	for _, fightOdd in pairs(self.odd_list) do
		local odd = fightOdd:findOdd()
		if nil == odd then
			return nil
		end
		if fightOdd.id == id and self:checkOdd( theFight.round, fightOdd ) then
			return fightOdd
		end
	end
	
	return nil
end

function FightSoldier:oddEffect(fightOdd, orderTargetList)
	local theFight = theFightList[self.selfFightId]
	local fightOrderTarget = FightOrderTarget:new(self)
	local odd = fightOdd:findOdd()
	
	if nil == fightOdd then
		return
	end
	LogMgr.log( 'fight', "oddeffect guid(" .. self.name .. "):" .. self.guid .. " oddid(" .. odd.name .. "):" ..fightOdd.id .. " status_id" .. fightOdd.status_id )
	
	if const.kFightOddFire == odd.status.cate then
		if 0 == self.hp then
			return
		end
		fightOrderTarget.fight_result = const.kFightDicHP;
		local hurt = math.modf(self.last_ext_able.hp * (odd.status.objid/10000))
		fightOrderTarget.fight_value = self:reduceHP( self, hurt, orderTargetList, fightOrderTarget, fightOdd.id )
		fightOrderTarget.hp = self.hp
		table.insert(orderTargetList, fightOrderTarget )
		if self:checkEnd() then
			self:oddDeadEffect(orderTargetList)
		end
	elseif const.kFightOddLightningFix == odd.status.cate then
		if 0 == self.hp then
			return
		end
		fightOrderTarget.fight_result = const.kFightDicHP;
		local hurt = fightOdd.status_value
		fightOrderTarget.fight_value = self:reduceHP(self, hurt, orderTargetList, fightOrderTarget, fightOdd.id )
		fightOrderTarget.hp = self.hp
		table.insert(orderTargetList, fightOrderTarget )
		if self:checkEnd() then
			self:oddDeadEffect(orderTargetList)
		end
	elseif const.kFightOddDeadNow == odd.status.cate then
		if 0 == self.hp then
			return
		end
		fightOrderTarget.fight_result = const.kFightDicHP;
		local hurt = self.hp
		fightOrderTarget.fight_value = self:reduceHP(self, hurt, orderTargetList, fightOrderTarget, fightOdd.id )
		fightOrderTarget.hp = self.hp
		local oddTriggered = FightOddTriggered:new(self.guid, fightOdd.id)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		table.insert(orderTargetList, fightOrderTarget )
		if self:checkEnd() then
			self:oddDeadEffect(orderTargetList)
		end
	elseif const.kFightOddRevive == odd.status.cate then
		if 0 == self.hp and 0 == (theFight.round - fightOdd.start_round)%odd.addodd.first and theFight:fightRand() < odd.status.val then
			local recover_hp = math.modf(self.last_ext_able.hp * (odd.status.objid/10000))
			fightOrderTarget.fight_result = const.kFightAddHP
			fightOrderTarget.odd_id = fightOdd.id
			fightOrderTarget.fight_value = recover_hp
			fightOrderTarget.fight_attr = const.kFightAttrRevive
			self:addHP( recover_hp )
			fightOrderTarget.hp = self.hp
			self:delFightOdd(fightOdd, orderTargetList, fightOrderTarget)
			table.insert(orderTargetList, fightOrderTarget )
			local oddTriggered = FightOddTriggered:new(self.guid, fightOdd.id)
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		end
	elseif const.kFightOddTotemSkillCoolDown == odd.status.cate then
		if self.attr == const.kAttrTotem then
			if theFight:fightRand() < fightOdd.status_value then
				self.lastOrderRound = {}
			end
		end
	elseif const.kFightOddHpPerRecover == odd.status.cate then
		--当自身血量低于40%时，为自身回复30%血量，冷却时间5回合
		if 0 == self.hp then
			return
		end
		
		if theFight.round < fightOdd.start_round then
			return
		end
		local hp_per = self.hp / self.last_ext_able.hp
		if hp_per < odd.status.objid/10000 then
			local add_hp = math.modf(self.last_ext_able.hp * (odd.status.val/10000))
			self:addHP( add_hp )
			fightOrderTarget.fight_result = const.kFightAddHP
			fightOrderTarget.odd_id = fightOdd.id
			fightOrderTarget.fight_value = add_hp
			fightOrderTarget.hp = self.hp
			table.insert(orderTargetList, fightOrderTarget )
			fightOdd.start_round = theFight.round + 5
		end
	elseif const.kFightOddRevive2 == odd.status.cate then
		if 0 == self.hp and 0 == theFight.round - fightOdd.start_round >= odd.addodd.first and theFight:fightRand() < odd.status.val then
			local recover_hp = math.modf(self.last_ext_able.hp * (odd.status.objid/10000))
			fightOrderTarget.fight_result = const.kFightAddHP
			fightOrderTarget.odd_id = fightOdd.id
			fightOrderTarget.fight_value = recover_hp
			fightOrderTarget.fight_attr = const.kFightAttrRevive
			self:addHP( recover_hp )
			fightOrderTarget.hp = self.hp
			self:delFightOdd(fightOdd, orderTargetList, fightOrderTarget)
			table.insert(orderTargetList, fightOrderTarget )
		end
	elseif const.kFightOddFireFix == odd.status.cate then
		if 0 == self.hp then
			return
		end
		table.insert(orderTargetList, fightOrderTarget )
		fightOrderTarget.fight_result = const.kFightDicHP
		fightOrderTarget.fight_value = self:reduceHP(self, fightOdd.status_value, orderTargetList, fightOrderTarget, fightOdd.id )
		fightOrderTarget.hp = self.hp
		if self:checkEnd() then
			self:oddDeadEffect(orderTargetList)
		end
	elseif const.kFightOddFireCount == odd.status.cate or const.kFightOddBlood == odd.status.cate or const.kFightOddPoison == odd.status.cate then
		if 0 == self.hp then
			return
		end
		table.insert(orderTargetList, fightOrderTarget )
		fightOrderTarget.fight_result = const.kFightDicHP
		fightOrderTarget.fight_value = self:reduceHP(self, fightOdd.status_value * fightOdd.now_count, orderTargetList, fightOrderTarget, fightOdd.id )
		fightOrderTarget.hp = self.hp
		if self:checkEnd() then
			self:oddDeadEffect(orderTargetList)
		end
	elseif const.kFightOddDisease == odd.status.cate then
		if 0 == self.hp then
			return
		end
		table.insert(orderTargetList, fightOrderTarget )
		fightOrderTarget.fight_result = const.kFightDicHP
		local hurt = fightOdd.status_value * fightOdd.now_count
		local tarSoldier = theFight:findSoldier(fightOdd.use_guid)
		if nil ~= tarSoldier then
			local fightOddTarget = tarSoldier:findFightOdd(const.kFightOddDiseaseHurt)
			if nil ~= fightOddTarget then
				hurt = math.modf( hurt * (1 + fightOddTarget.status_value/10000) )
			end
		end
		fightOrderTarget.fight_value = self:reduceHP(self, hurt, orderTargetList, fightOrderTarget, fightOdd.id )
		fightOrderTarget.hp = self.hp
		if self:checkEnd() then
			self:oddDeadEffect(orderTargetList)
		end
	elseif const.kFightOddRecoberRage == odd.status.cate then
		if 0 == self.hp then
			return
		end
		table.insert(orderTargetList, fightOrderTarget )
		if theFight:fightRand() < odd.status.val then
			self:addRage(odd.status.objid)
			fightOrderTarget.rage = self.rage
		end
	elseif const.kFightOddDeadFighting == odd.status.cate then
		table.insert(orderTargetList, fightOrderTarget )
		self:addRage(odd.status.objid)
		fightOrderTarget.rage = self.rage
	elseif const.kFightOddStayBuff == odd.status.cate then
		if self.attr ~= const.kAttrTotem and 0 == self.hp then
			return
		end
		
		if 0 ~= (theFight.round - fightOdd.start_round)%odd.status.objid then
			return
		end
		
		if theFight:fightRand() > odd.status.val then
			return
		end
		
		local tarSoldier = theFight:getTargetSoldier(self,odd)
		if nil == tarSoldier then
			return
		end
		
		local oddTriggered = FightOddTriggered:new(self.guid, fightOdd.id,tarSoldier)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		for _, soldier in pairs(tarSoldier) do
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
			if nil ~= addOdd then
				local fightOrderTarget = FightOrderTarget:new(soldier)
				if soldier:setFightOdd( addOdd, theFight.round, self.guid, orderTargetList, fightOrderTarget ) then
					table.insert(orderTargetList, fightOrderTarget)
				end
			end
		end
	elseif const.kFightOddFireFlow == odd.status.cate then
		if 0 == self.hp and self.attr ~= const.kAttrTotem then
			return
		end
		local tarSoldier = theFight:getTargetSoldier(self,odd)
		if nil == tarSoldier then
			return
		end
		
		local oddTriggered = FightOddTriggered:new(self.guid, fightOdd.id, tarSoldier)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		table.insert(orderTargetList, fightOrderTarget )
		
		for _, soldier in pairs(tarSoldier) do
			local fightOrderTarget = FightOrderTarget:new(soldier)
			table.insert(orderTargetList, fightOrderTarget)
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
			if nil ~= addOdd and theFight:fightRand() < odd.status.val then
				soldier:setFightOdd( addOdd, theFight.round, self.guid, orderTargetList, fightOrderTarget )
			end
			fightOrderTarget.fight_result = const.kFightDicHP
			fightOrderTarget.fight_value = soldier:reduceHP(self, fightOdd.status_value, orderTargetList, fightOrderTarget, fightOdd.id )
			fightOrderTarget.hp = soldier.hp
			if soldier:checkEnd() then
				soldier:oddDeadEffect(orderTargetList)
			end
		end
	elseif const.kFightOddCall == odd.status.cate then
		if theFight.round == odd.status.objid then
			local user = theFight:findUser(self.selfUserGuid)
			local call_soldier = theFight:addFightMonster( user, odd.status.val, self.fight_index - 4 )
			local call_soldier2 = theFight:addFightMonster( user, odd.status.val, self.fight_index + 2 )
			
			local fightOrderTarget = FightOrderTarget:new(self)
			fightOrderTarget.fight_attr = const.kFightAttrCall
			fightOrderTarget.fight_value = call_soldier.guid
			fightOrderTarget.fight_value2 = call_soldier2.guid
			table.insert(orderTargetList, fightOrderTarget)
		end
	elseif const.kFightOddEvilShadow == odd.status.cate then
		if 0 == self.hp then
			return
		end
		if theFight.round >= odd.status.objid then
			local tarSoldier = theFight:getTargetSoldier( self, odd )
			if nil ~= tarSoldier then
				for _, soldier in pairs(tarSoldier) do
					local fightOrderTarget = FightOrderTarget:new(soldier)
					fightOrderTarget.fight_result = const.kFightDicHP
					local hurt = math.modf(math.max(self.last_ext_able.physical_ack,self.last_ext_able.magic_ack) * (odd.status.val/10000))
					fightOrderTarget.fight_value = soldier:reduceHP( self, hurt, orderTargetList, fightOrderTarget, fightOdd.id)
					fightOrderTarget.hp = soldier.hp
					table.insert(orderTargetList, fightOrderTarget )
					if soldier:checkEnd() then
						soldier:oddDeadEffect(orderTargetList)
					end
				end
			end
		end
	elseif const.kFightOddTenFire == odd.status.cate then
		if 0 == self.hp then
			return
		end
		local user = theFight:findUser(self.selfUserGuid)
		local tarSoldier = theFight:getTargetSoldier( self, odd)
		for _, soldier in pairs(tarSoldier) do
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
			if nil ~= addOdd then
				local fightOrderTarget = FightOrderTarget:new(soldier)
				if soldier:setFightOdd( addOdd, theFight.round, self.guid, orderTargetList, fightOrderTarget ) then
					table.insert(orderTargetList, fightOrderTarget)
				end
			end
		end
	elseif const.kFightOddAttackToHP == odd.status.cate then
		if 0 == self.hp then
			return
		end
		
		local add_hp = math.modf(self.last_ext_able.hp * (odd.status.objid/10000)) + odd.status.val
		self:addHP( add_hp )
		fightOrderTarget.fight_result = const.kFightAddHP
		fightOrderTarget.odd_id = fightOdd.id
		fightOrderTarget.fight_value = add_hp
		fightOrderTarget.hp = self.hp
		table.insert(orderTargetList, fightOrderTarget )
		local oddTriggered = FightOddTriggered:new(self.guid, fightOdd.id)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
	elseif const.kFightOddRecoverCount == odd.status.cate then
		if 0 == self.hp then
			return
		end
		
		local add_hp = fightOdd.status_value * fightOdd.now_count
		self:addHP( add_hp )
		fightOrderTarget.fight_result = const.kFightAddHP
		fightOrderTarget.odd_id = fightOdd.id
		fightOrderTarget.fight_value = add_hp
		fightOrderTarget.hp = self.hp
		table.insert(orderTargetList, fightOrderTarget )
	elseif const.kFightOddAttackHpRecover == odd.status.cate then
		if 0 == self.hp then
			return
		end
		
		local add_hp = fightOdd.status_value
		self:addHP( add_hp )
		fightOrderTarget.fight_result = const.kFightAddHP
		fightOrderTarget.odd_id = fightOdd.id
		fightOrderTarget.fight_value = add_hp
		fightOrderTarget.hp = self.hp
		table.insert(orderTargetList, fightOrderTarget )
	elseif const.kFightOddRecoverByHP == odd.status.cate then
		if 0 == self.hp then
			return
		end
		
		local hp_per = 1 - self.hp/self.last_ext_able.hp
		local hp_add_per = (odd.status.objid + (odd.status.val - odd.status.objid)*hp_per)/10000
		local add_hp =  math.modf(fightOdd.status_value*hp_add_per)
		self:addHP( add_hp )
		fightOrderTarget.fight_result = const.kFightAddHP
		fightOrderTarget.odd_id = fightOdd.id
		fightOrderTarget.fight_value = add_hp
		fightOrderTarget.hp = self.hp
		table.insert(orderTargetList, fightOrderTarget )
	elseif const.kFightOddPositiveCharge == odd.status.cate then
		if 0 == self.hp then
			return
		end
		
		local soldier_use = theFight:findSoldier( fightOdd.use_guid )
		if nil == soldier_use then
			return
		end
		local max_attack = math.max(soldier_use.last_ext_able.physical_ack, soldier_use.last_ext_able.magic_ack)
		
		local fightOrderTarget = FightOrderTarget:new(self)
		fightOrderTarget.fight_result = const.kFightDicHP
		--获取没有这个BUFF的人数

		local count = theFight:getBuffCount(self:getCamp(), const.kFightOddPositiveCharge)
		
		local hurt = math.modf(max_attack*(odd.status.objid/10000)*count)
		fightOrderTarget.fight_value = self:reduceHP(self, hurt, orderTargetList, fightOrderTarget, fightOdd.id)
		fightOrderTarget.hp = self.hp
		table.insert(orderTargetList, fightOrderTarget )
		if self:checkEnd() then
			self:oddDeadEffect(orderTargetList)
		else
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
			if nil ~= addOdd and theFight:fightRand() < odd.status.val*count then
				local fightOrderTarget = FightOrderTarget:new(self)
				self:setFightOdd( addOdd, theFight.round, self.guid, orderTargetList, fightOrderTarget )
			end
			table.insert(orderTargetList, fightOrderTarget )
		end
	elseif const.kFightOddScourge == odd.status.cate then
		local tarSoldier = theFight:getTargetSoldier(self,odd)
		local addOdd = findOdd( odd.addodd.first, odd.addodd.second )
		if nil ~= tarSoldier and nil ~= addOdd then
			
			for _, soldier in pairs(tarSoldier) do
				local fightOrderTarget = FightOrderTarget:new(soldier)
				table.insert(orderTargetList, fightOrderTarget )
				--1~2名

				local count = theFight:fightRand(2) + 1
				for i = 1, count do
					if nil ~= addOdd and theFight:fightRand() < toMyNumber(odd.status.objid) then
						soldier:setFightOdd( addOdd, theFight.round, self.guid, orderTargetList, fightOrderTarget )
					end
				end
			end
		end
		
		--找到最大层数的人员
		local max_count = 0
		local maxSoldierList = {}
		local tarUser = theFight:getTarUser( self, const.kFightTargetOpposite )
		if nil ~= tarUser and nil~= addOdd then
			for _, soldier in pairs( tarUser.soldier_list ) do
				local fightOdd = soldier:findFightOdd(addOdd.status.cate)
				if not soldier:checkEnd() and nil ~= fightOdd and max_count < fightOdd.now_count then
					maxSoldierList = {}
					table.insert(maxSoldierList, soldier)
					max_count = fightOdd.now_count
				end
			end
		end
		
		if #maxSoldierList >= 1 then
			local index = theFight:fightRand(#maxSoldierList) + 1
			local soldier = maxSoldierList[index]
			local fightOrderTarget = FightOrderTarget:new(soldier)
			fightOrderTarget.fight_result = const.kFightDicHP
			local tarSoldier = theFight:findSoldier( self.guid )
			if nil ~= tarSoldier then
				local hurt = math.modf(math.max(tarSoldier.last_ext_able.physical_ack, tarSoldier.last_ext_able.magic_ack) * (odd.status.val/10000) * max_count )
				fightOrderTarget.fight_value = soldier:reduceHP(self, hurt, orderTargetList, fightOrderTarget, fightOdd.id)
				fightOrderTarget.hp = soldier.hp
				table.insert(orderTargetList, fightOrderTarget )
				if soldier:checkEnd() then
					soldier:oddDeadEffect(orderTargetList)
				end
			end
		end
	elseif const.kFightOddStarDown == odd.status.cate then
		--星辰陨落，持续2回合，每回合砸5次，全部随机目标（同一个目标有可能砸中多次)，造成释放者自身攻击30%的伤害

		--闪电云雾，向敌方投放一大团夹杂着闪电的云雾，每回合对敌方随机3个单体造成闪电伤害，并有50%的几率施加odd。云雾持续2回合。	
		local tarSoldier = theFight:getTargetSoldier(self,odd)
		if nil ~=  tarSoldier then
			local addodd = findOdd( odd.addodd.first, odd.addodd.second )
			
			for _, soldier in pairs(tarSoldier) do
				local fightOrderTarget = FightOrderTarget:new(soldier)
				table.insert(orderTargetList, fightOrderTarget )
				if nil ~= addodd and theFight:fightRand() < toMyNumber(odd.status.val) then
					soldier:setFightOdd( addodd, theFight.round, self.guid, orderTargetList, fightOrderTarget )
				end
			end
		end
	elseif const.kFightOddDevour == odd.status.cate then
		--吞噬对方身上的所有疾病效果，每吞噬一个疾病效果，就对该单位造成吞噬者自身攻击N%的伤害

		if 0 == self.hp then
			return
		end
		local tar_fightOdd = self:findFightOdd(fightOdd.status_value)
		if nil ~= tar_fightOdd then
			local tar_odd = tar_fightOdd:findOdd()
			if nil ~= tar_odd then
				--每层造成伤害
				local fightOrderTarget = FightOrderTarget:new(self)
				fightOrderTarget.fight_result = const.kFightDicHP
				local tarSoldier = theFight:findSoldier( fightOdd.use_guid )
				if nil ~= tarSoldier then
					local hurt = math.modf(math.max(tarSoldier.last_ext_able.physical_ack, tarSoldier.last_ext_able.magic_ack) * (odd.status.val/10000) * tar_fightOdd.now_count)
					fightOrderTarget.fight_value = self:reduceHP(self, hurt, orderTargetList, fightOrderTarget, fightOdd.id)
					fightOrderTarget.hp = self.hp
					table.insert(orderTargetList, fightOrderTarget )
					
					--如果是最大层数

					if tar_fightOdd.now_count == tar_odd.max_count then
						local addOdd = findOdd( odd.addodd.first, odd.addodd.second )
						if nil ~= addOdd then
							self:setFightOdd( addOdd, theFight.round, tarSoldier.guid, orderTargetList, fightOrderTarget )
						end
					end
					if self:checkEnd() then
						self:oddDeadEffect(orderTargetList)
						return
					end
				end
                --删除自己的疾病

                self:delFightOdd(tar_fightOdd, orderTargetList, fightOrderTarget)
				
                local fightOddDevourAdd = tarSoldier:findFightOdd(const.kFightOddDevourAdd)
                if nil ~= fightOddDevourAdd and tar_fightOdd.now_count > 0 then
                    for i = 1, tar_fightOdd.now_count do
                        if theFight:fightRand() < fightOddDevourAdd.status_value then
                            self:setFightOdd( tar_odd, theFight.round, tarSoldier.guid,  orderTargetList, fightOrderTarget )
                        end
                    end
                end
			end
		end
	elseif const.kFightOddDeadRevive == odd.status.cate then
		if 0 == self.hp then
			return
		end
		
		--有单位死开始如果2回合后自己还没死，救活该死亡单位。该死亡单位具有自身生前血量的50%，并且满怒气
		local user = theFight:findUser(self.selfUserGuid)
		local count = user:getDeadSoldierCount()
		if 0 ~= count then
			fightOdd.ext_value = fightOdd.ext_value + 1
		else
			fightOdd.ext_value = 0
		end
		
		if fightOdd.ext_value == fightOdd.status_value then
			--复活所有死亡的人
			local revive_count = 0
			local revive_list = {}
			for _, soldier in pairs(user.soldier_list) do
				if soldier.attr ~= const.kAttrTotem and soldier:checkEnd() then
					table.insert( revive_list, soldier )
				end
			end
					
			local tar_list = {}
			while revive_count < 2 and #revive_list > 0 do
				local index = theFight:fightRand(#revive_list) + 1
				if nil ~= revive_list[index] then
					local soldier = revive_list[index]
					local recover_hp = math.modf(soldier.last_ext_able.hp * (odd.status.val/10000))
					local fightOrderTarget = FightOrderTarget:new(soldier)
					fightOrderTarget.fight_result = const.kFightAddHP
					fightOrderTarget.odd_id = fightOdd.id
					fightOrderTarget.fight_value = recover_hp
					fightOrderTarget.fight_attr = const.kFightAttrRevive
					soldier:addHP( recover_hp )
					fightOrderTarget.hp = soldier.hp
					table.insert(orderTargetList, fightOrderTarget )
					table.insert(tar_list,soldier)
					table.remove(revive_list,index)
					revive_count = revive_count + 1
				end
			end
						
			--把自己弄成1点血
			local fightOrderTarget = FightOrderTarget:new(self)
			fightOrderTarget.fight_result = const.kFightDicHP
			local hurt = self.hp - 1
			fightOrderTarget.fight_value = self:reduceHP(self, hurt, orderTargetList, fightOrderTarget, fightOdd.id)
			fightOrderTarget.hp = self.hp
			local oddTriggered = FightOddTriggered:new(self.guid, fightOdd.id,tar_list)
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			self:delFightOdd(fightOdd, orderTargetList, fightOrderTarget)
			table.insert(orderTargetList, fightOrderTarget )
		end
	end
end

function FightSoldier:oddDeadEffect(orderTargetList)
    if 1 == self.deadFlag then
        return
    end
	local theFight = theFightList[self.selfFightId]
	local fightOrderTarget = FightOrderTarget:new(self)
    table.insert(orderTargetList, fightOrderTarget )
	
	for _, fightOdd in pairs( self.odd_list ) do
		if fightOdd.status_id == const.kFightOddGodBless then
			LogMgr.log( 'fight', "===")
		end
	end
	
	--死亡之后立马复活
	local fightOddDeadCall = self:findFightOdd(const.kFightOddDealCall)
	if nil ~= fightOddDeadCall and theFight:fightRand() < fightOddDeadCall.status_value then
		local odd = fightOddDeadCall:findOdd()
		if nil ~= odd then
			self:addOddCount(fightOddDeadCall)
			local fightOrderTarget = FightOrderTarget:new(self)
			local recover_hp = math.modf(self.last_ext_able.hp * (odd.status.val/10000))
			if 0 == recover_hp then
				recover_hp = 1
			end
			fightOrderTarget.fight_result = const.kFightAddHP
			fightOrderTarget.odd_id = fightOddDeadCall.id
			fightOrderTarget.fight_value = recover_hp
			fightOrderTarget.fight_attr = const.kFightAttrDeadCall
			self:addHP( recover_hp )
			fightOrderTarget.hp = self.hp
			table.insert(orderTargetList, fightOrderTarget )
			local oddTriggered = FightOddTriggered:new(self.guid, fightOddDeadCall.id)
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			return
		end
	end
	
	--死亡2回合复活
	local fightOddRevive = self:findFightOdd(const.kFightOddRevive)
	if nil ~= fightOddRevive then
		fightOddRevive.start_round = theFight.round
	end
	
	--每当一个盟友死亡时，贝恩就会昏迷对方随机一个单位2回合
	for _, soldier in pairs( theFight.soldierList ) do
		if soldier.guid ~= self.guid and soldier:getCamp() == self:getCamp() and not soldier:checkEnd() then
			local fightOddDeadStun = soldier:findFightOdd(const.kFightOddDeadToStun)
			if nil ~= fightOddDeadStun then
				local odd = fightOddDeadStun:findOdd()
				local tarSoldier = theFight:getTargetSoldier(self,odd)
				if nil == tarSoldier then
					return
				end
				
				local tar_list = {}
				for _, tarS in pairs(tarSoldier) do
					local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
					if nil ~= addOdd then
						table.insert(tar_list, tarS)
						tarS:setFightOdd(addOdd, theFight.round, soldier.guid, orderTargetList, fightOrderTarget )
					end
				end
				local oddTriggered = FightOddTriggered:new(soldier.guid, fightOddDeadStun.id,tar_list)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			end
		end
	end
	
	--己方队友死亡时，召唤出一个兽人灵魂施放到队友身上，持续2回合。2回合后，目标有50%几率复活，若复活失败，则继续向其释放此技能。一场战斗只能复活一名队友。

	for _, soldier in pairs( theFight.soldierList ) do
		if soldier.guid ~= self.guid and soldier:getCamp() == self:getCamp() and not soldier:checkEnd() then
			local fightOddGiveRevive = soldier:findFightOdd(const.kFightOddGiveRevive)
			if nil ~= fightOddGiveRevive then
				local odd = fightOddGiveRevive:findOdd()
				if nil ~= odd then
					local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
					if nil ~= addOdd then
						
						self:setFightOdd(addOdd, theFight.round, soldier.guid, orderTargetList, fightOrderTarget )
						local oddTriggered = FightOddTriggered:new(soldier.guid, fightOddGiveRevive.id,{self})
						table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
						--删除自己
						soldier:delFightOdd(fightOddGiveRevive, orderTargetList, fightOrderTarget)
					end
				end
			end
		end
	end
	
	--死亡是添加BUFf
	local fightOddDeadAddBuff = self:findFightOdd(const.kFightOddDeadAddBuff)
	if nil ~= fightOddDeadAddBuff and theFight:fightRand() < fightOddDeadAddBuff.status_value then
		local odd = fightOddDeadAddBuff:findOdd()
		local oddTriggered = FightOddTriggered:new(self.guid, fightOddDeadAddBuff.id)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		if nil ~= odd then
			local addodd = findOdd( odd.addodd.first, odd.addodd.second )
			if nil ~= addodd then
				self:setFightOdd( addodd, theFight.round, self.guid, orderTargetList, fightOrderTarget )
			end
		end
	end
	
	--添加死亡次数
	self:AddEndInfoDeadCount()
	self.deadFlag = 1
	
	--给对面的人加
	local tarUser = theFight:getTarUser( self, const.kFightTargetOpposite )
	if nil ~= tarUser then
		tarUser:addTotemValue(100)
		local fightOrderTarget = FightOrderTarget:new(self)
		fightOrderTarget.fight_attr = const.kFightAttrTotemValueShow
		fightOrderTarget.fight_value = 100
		table.insert(orderTargetList, fightOrderTarget )
	end
end

function FightSoldier:addFightExt( fightOdd, orderTargetList )
	local odd = fightOdd:findOdd()
	if nil == odd then
		return
	end
	
	if 0 == odd.effect.cate then
		return
	end
	
	local able = ToFightExtAble( odd.effect.cate, self.fight_ext_able, odd.effect.objid )
	if 1 == odd.effect_count then
		able = ToFightExtAble( odd.effect.cate, self.fight_ext_able, odd.effect.objid, fightOdd.now_count )
	end
	if toMyNumber(odd.effect.val) == const.kFightEffectTypeBuff then
		self.last_ext_able = self.last_ext_able + able;
		if 0 ~= able.hp then
			local fightOrderTarget = FightOrderTarget:new(self)
			fightOrderTarget.fight_result = const.kFightAddHP
			fightOrderTarget.odd_id = fightOdd.id
			fightOrderTarget.fight_value = able.hp
			if nil ~= orderTargetList then
				table.insert(orderTargetList, fightOrderTarget)
			end
			self:addHP( able.hp )
		end
	else
		self.last_ext_able = self.last_ext_able - able;
		if 0 ~= able.hp then
			local fightOrderTarget = FightOrderTarget:new(self)
			fightOrderTarget.fight_result = const.kFightDicHP
			fightOrderTarget.fight_value = able.hp
			if nil ~= orderTargetList then
				table.insert(orderTargetList, fightOrderTarget)
			end
			self:reduceHP(self, able.hp, orderTargetList, fightOrderTarget, fightOdd.id )
		end
	end
end

function FightSoldier:delFightExt( fightOdd, orderTargetList )
	local odd = fightOdd:findOdd()
	if nil == odd then
		return
	end
	
	local able = ToFightExtAble( odd.effect.cate, self.fight_ext_able, odd.effect.objid )
	if 1 == odd.effect_count then
		able = ToFightExtAble( odd.effect.cate, self.fight_ext_able, odd.effect.objid, fightOdd.now_count )
	end
	if toMyNumber(odd.effect.val) == const.kFightEffectTypeDebuff then
		self.last_ext_able = self.last_ext_able + able;
		if 0 ~= able.hp then
			local fightOrderTarget = FightOrderTarget:new(self)
			fightOrderTarget.fight_result = const.kFightAddHP
			fightOrderTarget.odd_id = fightOdd.id
			fightOrderTarget.fight_value = able.hp
			if nil ~= orderTargetList then
				table.insert(orderTargetList, fightOrderTarget)
			end
		end
	else
		self.last_ext_able = self.last_ext_able - able;
		if 0 ~= able.hp then
			local fightOrderTarget = FightOrderTarget:new(self)
			fightOrderTarget.fight_result = const.kFightDicHP
			fightOrderTarget.fight_value = able.hp
			if nil ~= orderTargetList then
				table.insert(orderTargetList, fightOrderTarget)
			end
			self:reduceHP(self, able.hp, orderTargetList, fightOrderTarget, fightOdd.id )
		end
	end
end


function FightSoldier:reduceHP(ackSoldier, hurt, orderTargetList, fightOrderTarget, odd_id )
	local theFight = theFightList[self.selfFightId]
	if 0 == hurt then
		return 0
	end
	
	if nil ~= odd_id then
		fightOrderTarget.odd_id = odd_id
		
		--法术免疫，被法术攻击时，有一定几率免疫法术伤害

		local fightOddMag = self:findFightOdd( const.kFightOddMagInvincible )
		if 0 ~= odd_id and nil ~= fightOddMag and theFight:fightRand() < fightOddMag.status_value then
			local oddTriggered = FightOddTriggered:new(self.guid, fightOddMag.id)
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			return 0
		end
	end
	
	local fightOdd = self:findFightOdd(const.kFightOddInvincible)
	if nil ~= fightOdd and nil ~= fightOrderTarget then
		self:addOddCount(fightOdd)
		local oddTriggered = FightOddTriggered:new(self.guid, fightOdd.id)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		return 0
	end
	
	--受到一次致命攻击时，会将该伤害变为1点血，并且将受到的所有伤害降低N%，持续N回合。

	local fightOddDeadHit = self:findFightOdd(const.kFightOddDeadHit)
	if nil ~= fightOddDeadHit and hurt > self.hp then
		local oddTriggered = FightOddTriggered:new(self.guid, fightOddDeadHit.id)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		hurt = 1
		
		self:addOddCount(fightOddDeadHit)
		local odd = fightOddDeadHit:findOdd()
		if nil ~= odd then
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second )
			if nil ~= addOdd then
				self:setFightOdd(addOdd, theFight.round, self.guid, orderTargetList, fightOrderTarget )
			end
		end
	end
	
	
	--受到了致死的攻击，那么本回合他会贿赂对方英雄，使攻击目标转向其他英雄，同时使意图攻击自己的对方英雄伤害降低50%
	local fightOddDeadHitChange = self:findFightOdd(const.kFightOddDeadHitChange)
	if nil ~= fightOddDeadHitChange and hurt > self.hp then
		--伤害转移给其他人
		local odd = fightOddDeadHitChange:findOdd()
		if nil ~= odd then
			local tarSoldier = theFight:getTargetSoldier(self,odd)
			local oddTriggered = FightOddTriggered:new(self.guid, fightOddDeadHitChange.id, tarSoldier)
			table.insert(fightOrderTarget.odd_list_triggered,fightOddDeadHitChange)
			local change_hurt = math.modf(hurt * (fightOddDeadHitChange.status_value/10000))
			for _, soldier in pairs(tarSoldier) do
				local fightOrderTarget = FightOrderTarget:new(soldier)
				table.insert(orderTargetList, fightOrderTarget )
				fightOrderTarget.guid = soldier.guid
				fightOrderTarget.fight_result = const.kFightDicHP
				fightOrderTarget.fight_value = soldier:reduceHP(self, change_hurt, orderTargetList, fightOrderTarget,fightOddDeadHitChange.id)
				if soldier:checkEnd() then
					soldier:oddDeadEffect(orderTargetList)
				end
			end
			
			self:delFightOdd(fightOddDeadHitChange, orderTargetList,  fightOrderTarget)
			return 0
		end
	end
	
	--受到致命伤害时，会将该伤害的N%反弹给造成伤害的人
	local fightOddDeadHurtRebound = self:findFightOdd(const.kFightOddDeadHurtRebound)
	if nil ~= fightOddDeadHurtRebound and hurt > self.hp and ackSoldier.guid ~= self.guid then
		self:addOddCount(fightOddDeadHurtRebound)
		--打破之后 打的人造成伤害
		local bomb_hurt = math.modf(hurt * (fightOddDeadHurtRebound.status_value/10000))
		local fightOrderTarget = FightOrderTarget:new(ackSoldier)
		table.insert(orderTargetList, fightOrderTarget )
		fightOrderTarget.fight_result = const.kFightDicHP
		fightOrderTarget.fight_value = ackSoldier:reduceHP(self, bomb_hurt, orderTargetList, fightOrderTarget,fightOddDeadHurtRebound.id)
		if ackSoldier:checkEnd() then
			ackSoldier:oddDeadEffect(orderTargetList)
		end
	end
	
	--盾

	local fightOddDefFix = self:findFightOdd(const.kFightOddDefFixed)
	if nil ~= fightOddDefFix and nil ~= fightOrderTarget then	
		if 0 ~= fightOddDefFix.status_value then
			if hurt < fightOddDefFix.status_value then
				fightOddDefFix.status_value = fightOddDefFix.status_value - hurt
				hurt = 0
			else
				hurt = hurt - fightOddDefFix.status_value
				fightOddDefFix.status_value = 0
				
				--打破之后 打的人造成伤害
				if self.guid ~= ackSoldier.guid then
					local bomb_hurt = fightOddDefFix.ext_value
					local fightOrderTarget = FightOrderTarget:new(ackSoldier)
					table.insert(orderTargetList, fightOrderTarget )
					fightOrderTarget.fight_result = const.kFightDicHP
					fightOrderTarget.fight_value = ackSoldier:reduceHP(self, bomb_hurt, orderTargetList, fightOrderTarget, fightOddDefFix.id)
					if ackSoldier:checkEnd() then
						ackSoldier:oddDeadEffect(orderTargetList)
					end
				end
				
				self:delFightOdd(fightOddDefFix, orderTargetList, fightOrderTarget)
			end
			local oddTriggered = FightOddTriggered:new(self.guid, fightOddDefFix.id)
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		end
	end
	
	--可以生成一个寒冰护盾，吸收大量伤害，持续2回合,每场战斗只触发一次，改护盾被打破时不会给打破的人造成伤害
	local fightOddIceDef = self:findFightOdd(const.kFightOddIceDef)
	if nil ~= fightOddIceDef and nil ~= fightOrderTarget then
		if 0 ~= fightOddIceDef.status_value then
			if hurt < fightOddIceDef.status_value then
				fightOddIceDef.status_value = fightOddIceDef.status_value - hurt
				hurt = 0
			else
				hurt = hurt - fightOddIceDef.status_value
				fightOddIceDef.status_value = 0
				self:delFightOdd(fightOddIceDef, orderTargetList, fightOrderTarget)
			end
			local oddTriggered = FightOddTriggered:new(self.guid, fightOddIceDef.id)
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		end
	end
	
	--为己方所有人添加一个护盾，该护盾会吸收所有人的伤害并进行己方全体所吸收伤害进行统计，如果伤害超过了释放人生命上限的N%时就会打破。
	local fightOddDefAll = self:findFightOdd(const.kFightOddDefAll)
	if nil ~= fightOddDefAll and nil ~= fightOrderTarget then
		if 0 ~= fightOddDefAll.status_value then
			if hurt < fightOddDefAll.status_value then
				fightOddDefAll.status_value = fightOddDefAll.status_value - hurt
				hurt = 0
				--设置自己方所有有这个BUFF的人的status_value
				local theUser = theFight:findUser(self.selfUserGuid)
				for _, soldier in pairs( theUser.soldier_list ) do
					for _, fightOdd in pairs(soldier.odd_list) do
						if fightOdd.id == fightOddDefAll.id and fightOdd.level == fightOddDefAll.level then
							fightOdd.status_value = fightOddDefAll.status_value
						end
					end
				end
			else
				hurt = hurt - fightOddDefAll.status_value
				fightOddDefAll.status_value = 0
				local theUser = theFight:findUser(self.selfUserGuid)
				for _, soldier in pairs( theUser.soldier_list ) do
					for _, fightOdd in pairs(soldier.odd_list) do
						if fightOdd.id == fightOddDefAll.id and fightOdd.level == fightOddDefAll.level then
							soldier:delFightOdd(fightOdd, orderTargetList, fightOrderTarget)
						end
					end
				end
			end
			local oddTriggered = FightOddTriggered:new(self.guid, fightOddDefAll.id)
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		end
	end
	
	local old_hp = self.hp
	if hurt > self.hp then
		self.hp = 0;
	else
		self.hp = self.hp - hurt;
	end

	if nil ~= ackSoldier then
		ackSoldier:addEndInfoHurt( hurt )
	end
	
	--恐惧，不能行动，但是当从被恐惧的那刻起算如果累计受到的伤害超过自身生命的N%时，则解除这个状态
	local fightOddFear = self:findFightOdd(const.kFightOddFear)
	if nil ~= fightOddFear and hurt > 0 and 0 ~= self.hp then
		fightOddFear.ext_value = fightOddFear.ext_value + hurt
		if fightOddFear.ext_value > self.last_ext_able.hp*(fightOddFear.status_value/10000) then
			self:delFightOdd(fightOddFear,orderTargetList, fightOrderTarget)
		end
	end
	
	--向友方血量最低目标释放愈合祷言，该目标在受到伤害后，愈合祷言会为其回复大量血量，并且弹射到下一个血量最低的友方单位
	local fightOddRecoverHPMin = self:findFightOdd(const.kFightOddRecoverHPMin)
	if nil ~= fightOddRecoverHPMin and hurt > 0 and 0 ~= self.hp then
		local fightOrderTarget = FightOrderTarget:new(self)
		fightOrderTarget.fight_result = const.kFightAddHP
		fightOrderTarget.odd_id = fightOddRecoverHPMin.id 
		local tarSoldier =  theFight:findSoldier( fightOddRecoverHPMin.use_guid)
		local odd = fightOddRecoverHPMin:findOdd()
		if nil ~= tarSoldier and nil ~= odd and fightOddRecoverHPMin.ext_value < odd.status.val then
			local hp = math.modf( math.max( tarSoldier.last_ext_able.magic_ack, tarSoldier.last_ext_able.physical_ack) * (fightOddRecoverHPMin.status_value/10000))
			self:addHP( hp )
			fightOrderTarget.fight_value = hp
			fightOrderTarget.hp = self.hp
			table.insert(orderTargetList, fightOrderTarget )
			fightOddRecoverHPMin.ext_value = fightOddRecoverHPMin.ext_value + 1
			
			--找到己方血量第二少的单位

			local user = theFight:getTarUser( self, const.kFightTargetSelf )
			local temp_list = {}
			local soldier_hpmin = nil
			for _, soldier in pairs(user.soldier_list) do
				if soldier.guid ~= self.guid and soldier.attr ~= const.kAttrTotem and 0 ~= soldier.hp then
					if nil == soldier_hpmin then
						table.insert(temp_list,soldier)
						soldier_hpmin = soldier
					else
						if soldier_hpmin.hp/soldier_hpmin.last_ext_able.hp > soldier.hp/soldier.last_ext_able.hp then
							temp_list = {}
							table.insert(temp_list,soldier)
							soldier_hpmin = soldier
						elseif soldier_hpmin.hp/soldier_hpmin.last_ext_able.hp == soldier.hp/soldier.last_ext_able.hp then
							table.insert(temp_list,soldier)
						end
					end
				end
			end
			if #temp_list >= 2 then
				local index = theFight:fightRand(#temp_list) + 1
				soldier_hpmin = temp_list[index]
			end
            if nil ~= soldier_hpmin and fightOddRecoverHPMin.ext_value < odd.status.val then
				local tempodd = copyTab(fightOddRecoverHPMin)
				FightOdd:newtable(tempodd)
				tempodd.podd = fightOddRecoverHPMin.podd
				soldier_hpmin:setFightOddSpe(tempodd,fightOrderTarget)
			end
            self:delFightOdd(fightOddRecoverHPMin,orderTargetList,fightOrderTarget)
		end
	end
	
	if nil == orderTargetList then
		return hurt
	end
	
	local old_per = old_hp / self.last_ext_able.hp
	local now_per = self.hp / self.last_ext_able.hp
	
	local fightOdd = self:findFightOdd(const.kFightOddHpReduceBuff)
	if nil ~= fightOdd then
		local odd = fightOdd:findOdd()
		if 0 ~= self.hp and nil ~= odd then
			local per_need = odd.status.objid / 10000
			
			if old_per > per_need and now_per <= per_need then
				local tarSoldier = theFight:getTargetSoldier(self,odd)
				self:addOddCount(fightOdd)
				if nil ~= tarSoldier then
					for _, soldier in pairs(tarSoldier) do
						local addOdd = findOdd( odd.addodd.first, odd.addodd.second )
						if nil ~= addOdd then
							soldier:setFightOdd(addOdd, theFight.round, self.guid, orderTargetList, fightOrderTarget )
						end
					end
				end
			end
		end
	end
	
	local fightOdd = self:findFightOdd(const.kFightOddChange)
	if nil ~= fightOdd then
		local odd = fightOdd:findOdd()
		if 0 ~= self.hp and nil ~= odd then
			local per_need = odd.status.objid / 10000
			self:addOddCount(fightOdd)
			if old_per > per_need and now_per <= per_need then
				local user = theFight:findUser(self.selfUserGuid)
				local change_soldier = theFight:addFightMonster(user, odd.status.val, self.fight_index)
				table.insert(theFight.soldierList, change_soldier)
				local fightOrderTarget = FightOrderTarget:new(self)
				fightOrderTarget.fight_attr = const.kFightAttrChange
				fightOrderTarget.fight_value = change_soldier.guid
				table.insert(orderTargetList, fightOrderTarget)
				LogMgr.log( 'fight', "=================kFightOddChange")
				--设置自己的血量为0
				setSoldierDel(self)
				return hurt
			end
		end
	end
	
	LogMgr.log( 'fight',  "soldier(" .. self.name .. "):" .. self.guid .. " redecuHP:" .. hurt .. " nowhp:" .. self.hp )
	return hurt
end

function FightSoldier:addHP( _hp )
	if self.hp + _hp > self.last_ext_able.hp then
		self.hp = self.last_ext_able.hp
	else
		self.hp = self.hp + _hp
	end
	self:addEndInfoRecover( _hp )
	LogMgr.log( 'fight',  "soldier(" .. self.name .. "):" .. self.guid .. " addHP:" .. _hp .. " nowhp:" .. self.hp )
end

function FightSoldier:checkTotemSkill()
	local theFight = theFightList[self.selfFightId]
	
	local start_round = self:getTotemSkillRound()
	
	if 0 == start_round or theFight.round < start_round then
		return false
	end
	
	local skill = findSkill(self.skill_list[1].skill_id, self.skill_list[1].skill_level)
	if nil == skill then
		return false
	end
	
	if self:getTotemValue() < skill.self_costtotem then
		return false
	end
	
	return true
end

function FightSoldier:getTotemSkillRound()
	local theFight = theFightList[self.selfFightId]
	
	if self.attr ~= const.kAttrTotem then
		return 0
	end
	
	local skill = findSkill(self.skill_list[1].skill_id, self.skill_list[1].skill_level)
	
	if nil == skill then
		return 0
	end
	
	
	if nil == self.lastOrderRound[self.skill_list[1].skill_id] then
		if 0 == toMyNumber(skill.start_round ) then
			return 1
		end
		return toMyNumber(skill.start_round )
	else
		return self.lastOrderRound[self.skill_list[1].skill_id] + toMyNumber(skill.cooldown)
	end
end

function FightSoldier:setTotemOrder( fo )
	local theFight = theFightList[self.selfFightId]
	local theUser = theFight:findUser(self.selfUserGuid)
	local fightOrder = {}
	fightOrder.order_id = 0
	fightOrder.order_level = 0
	if 0 ~= theUser.isAutoFight then
		if self:checkTotemSkill() then
			fightOrder.order_id = self.skill_list[1].skill_id
			fightOrder.order_level = self.skill_list[1].skill_level
		end
	else
		if nil == self.order then
			self.order.order_id = 0
			self.order.order_level = 0
		end
		
		if nil ~= fo and fo.order_id == self.skill_list[1].skill_id and fo.order_level == self.skill_list[1].skill_level and self:checkTotemSkill() then
			fightOrder.order_id = self.skill_list[1].skill_id
			fightOrder.order_level = self.skill_list[1].skill_level
		end
	end
	return fightOrder
end

function FightSoldier:setSoldierOrder( fo )
	local fightOrder = {}
	local fightOdd = self:findFightOdd(const.kFightOddDisillusion)
	if nil ~= fightOdd then
		self.state_list[const.kFightOddDisillusion] = const.kFightOddDisillusion
		fightOrder.order_id = self.skill_list[3].skill_id
		fightOrder.order_level = self.skill_list[3].skill_level
	elseif self.rage < 100 then
		fightOrder.order_id = self.skill_list[1].skill_id
		fightOrder.order_level = self.skill_list[1].skill_level
	else
		fightOrder.order_id = self.skill_list[2].skill_id
		fightOrder.order_level = self.skill_list[2].skill_level
	end
	if nil ~= fo then
		fightOrder.order_id = fo.order_id
		fightOrder.order_level = fo.order_level
	end
	return fightOrder
end

function FightSoldier:setMonserOrder( fo )
	local fightOrder = {}
	if self.soldier_id == 100 then
		YiLiDan:setOrder(self,fightOrder)
	elseif self.soldier_id == 101 then
		YiLiDan:setOrder(self,fightOrder)
	else
		local fightOdd = self:findFightOdd(const.kFightOddDisillusion)
		if nil ~= fightOdd then
			self.state_list[const.kFightOddDisillusion] = const.kFightOddDisillusion
			fightOrder.order_id = self.skill_list[3].skill_id
			fightOrder.order_level = self.skill_list[3].skill_level
		elseif self.rage < 100 then
			fightOrder.order_id = self.skill_list[1].skill_id
			fightOrder.order_level = self.skill_list[1].skill_level
		else
			fightOrder.order_id = self.skill_list[2].skill_id
			fightOrder.order_level = self.skill_list[2].skill_level
		end
	end
	if nil ~= fo then
		fightOrder.order_id = fo.order_id
		fightOrder.order_level = fo.order_level
	end
	return fightOrder
end

--设置Order
function FightSoldier:setOrder( fightOrder )
	local theFight = theFightList[self.selfFightId]
	if self.attr == const.kAttrTotem then
		fightOrder = self:setTotemOrder( fightOrder )
	elseif self.attr == const.kAttrSoldier then
		fightOrder = self:setSoldierOrder( fightOrder )
	elseif self.attr == const.kAttrMonster then
		fightOrder = self:setMonserOrder( fightOrder )
	end
	
	local fightOddSilent  = self:findFightOdd( const.kFightOddSilent )
	local fightOddConfusion = self:findFightOdd( const.kFightOddConfusion )
	if nil ~= fightOddSilent or nil ~= fightOddConfusion then
		if self.attr == const.kAttrTotem then
            fightOrder.order_id = 0
            fightOrder.order_level = 0
		elseif self.attr == const.kAttrSoldier or self.attr == const.kAttrMonster then
			fightOrder.order_id = self.skill_list[1].skill_id
            fightOrder.order_level = self.skill_list[1].skill_level
		end
	end
	
	--使用某个id的主动技能时，有一定几率改为使用另个一个id的主动技能例如技能4
	local fightOddSkillChange = self:findFightOdd( const.kFightOddSkillChange )
	if nil ~= fightOddSkillChange then
		local odd = fightOddSkillChange:findOdd()
		if nil ~= odd then
			if odd.status.objid == fightOrder.order_id and theFight:fightRand() < odd.status.val then
				if nil ~= self.skill_list[4] then
                    fightOrder.order_id = self.skill_list[4].skill_id
                    fightOrder.order_level = self.skill_list[4].skill_level
				end
			end
		end
	end
	
	self.order.guid = self.guid
	self.order.order_id = fightOrder.order_id
	self.order.order_level = fightOrder.order_level
	LogMgr.log( 'fight',  "guid(" .. self.name .. "):" .. self.guid .. "setOrder" .. self.order.order_id .. "," .. self.order.order_level )
	--设置上次使用技能的回合
	
	return self.order
end

function FightSoldier:canAttack()
	if self.attr == const.kAttrTotem then
		local order = { guid = self.guid, order_id = self.skill_list[1].skill_id, order_level = self.skill_list[1].skill_level }
		local skill = findSkill( order.order_id, order.order_level )
		if nil ~= skill and self:getTotemValue() >= skill.self_costtotem then
			return true
		end
		return false
	end
	
	--当你死后，你会继续以无敌形态（不可被选中，不可受伤）站在战场上持续2回合，2回合后就消失
	local fightOddDeadFighting = self:findFightOdd(const.kFightOddDeadFighting)
	if 0 == self.hp and nil ~= fightOddDeadFighting then
		return true
	end
	
	--眩晕
	local fightOdd = self:findFightOdd(const.kFightOddStun)
	if nil ~= fightOdd then
		return false
	end
	
	--恐惧
	local fightOdd = self:findFightOdd(const.kFightOddFear)
	if nil ~= fightOdd then
		return false
	end
	
	--石化
	local fightOdd = self:findFightOdd(const.kFightOddStone)
	if nil ~= fightOdd then
		return false
	end
	
	--飓风
	local fightOdd = self:findFightOdd(const.kFightOddStorm)
	if nil ~= fightOdd then
		return false
	end
	
	--缠绕状态，所有的近战技能不能攻击，远程技能可以攻击

	local fightOdd = self:findFightOdd(const.kFightOddCoil)
	if nil ~= fightOdd then
		self:setOrder()
		local order = self.order
		
		if nil == order then
			return false
		end
		local skill = findSkill( order.order_id, order.order_level )
		if nil == skill then
			return false
		end
		
		if const.kFightMelee == skill.distance then
			return false
		end
	end
	
	local fightOdd = self:findFightOdd(const.kFightOddSleep)
	if nil ~= fightOdd then
		return false
	end
	
	local fightOdd = self:findFightOdd(const.kFightOddChangeSheep)
	if nil ~= fightOdd then
		return false
	end
	
	local fightOdd = self:findFightOdd(const.kFightOddChangeFrog)
	if nil ~= fightOdd then
		return false
	end
	
	return 0 ~= self.hp
end

--获取位置
function FightSoldier:getPostion()
	if self.fight_index % 3 == 0 then
		return const.kFightIndexFront
	elseif self.fight_index % 3 == 1 then
		return const.kFightIndexMid
	elseif self.fight_index % 3 == 2 then
		return const.kFightIndexBack
	end
	return 0;
end

--获取行

function FightSoldier:getRow()
	local i = math.modf(self.fight_index/3)
	if i == 0 then
		return const.kFightIndexFirst
	elseif i == 1 then
		return const.kFightIndexSecond
	elseif i == 2 then
		return const.kFightIndexThird
	end
	return 0
end

function FightSoldier:addEndInfoHurt( hurt )
	if 0 == hurt then
		return
	end
	local theFight = theFightList[self.selfFightId]
	local camp = self:getCamp()
	if nil == theFight.fightEndInfo[camp] then
		theFight.fightEndInfo[camp] = FightEndInfo:new()
		theFight.fightEndInfo[camp].camp = camp
	end
	theFight.fightEndInfo[camp].hurt = theFight.fightEndInfo[camp].hurt + hurt
end

function FightSoldier:addEndInfoMagicHurt( magic_hurt )
	if 0 == magic_hurt then
		return
	end
	local theFight = theFightList[self.selfFightId]
	local camp = self:getCamp()
	if nil == theFight.fightEndInfo[camp] then
		theFight.fightEndInfo[camp] = FightEndInfo:new()
		theFight.fightEndInfo[camp].camp = camp
	end
	theFight.fightEndInfo[camp].magic_hurt = theFight.fightEndInfo[camp].magic_hurt + magic_hurt
end

function FightSoldier:addEndInfoRecover( recover )
	if 0 == recover then
		return
	end
	local theFight = theFightList[self.selfFightId]
	local camp = self:getCamp()
	if nil == theFight.fightEndInfo[camp] then
		theFight.fightEndInfo[camp] = FightEndInfo:new()
		theFight.fightEndInfo[camp].camp = camp
	end
	theFight.fightEndInfo[camp].recover = theFight.fightEndInfo[camp].recover + recover
end

function FightSoldier:AddEndInfoDeadCount()
	local theFight = theFightList[self.selfFightId]
	local camp = self:getCamp()
	if nil == theFight.fightEndInfo[camp] then
		theFight.fightEndInfo[camp] = FightEndInfo:new()
		theFight.fightEndInfo[camp].camp = camp
	end
	theFight.fightEndInfo[camp].dead_count = theFight.fightEndInfo[camp].dead_count + 1
end

function FightSoldier:addEndInfoAttack()
	local theFight = theFightList[self.selfFightId]
	local camp = self:getCamp()
	if nil == theFight.fightEndInfo[camp] then
		theFight.fightEndInfo[camp] = FightEndInfo:new()
		theFight.fightEndInfo[camp].camp = camp
	end
	theFight.fightEndInfo[camp].attack_count = theFight.fightEndInfo[camp].attack_count + 1
end

function FightSoldier:addEndInfoDodge()
	local theFight = theFightList[self.selfFightId]
	local camp = self:getCamp()
	if nil == theFight.fightEndInfo[camp] then
		theFight.fightEndInfo[camp] = FightEndInfo:new()
		theFight.fightEndInfo[camp].camp = camp
	end
	theFight.fightEndInfo[camp].dodge_count = theFight.fightEndInfo[camp].dodge_count + 1
end

function CFight:updateEndInfoRound()
	if nil == self.fightEndInfo[const.kFightLeft] then
		self.fightEndInfo[const.kFightLeft] = FightEndInfo:new()
		self.fightEndInfo[const.kFightLeft].camp = const.kFightLeft
		self.fightEndInfo[const.kFightLeft].round = self.round
	else
	    self.fightEndInfo[const.kFightLeft].round = self.round
	end
	if nil == self.fightEndInfo[const.kFightRight] then
		self.fightEndInfo[const.kFightRight] = FightEndInfo:new()
		self.fightEndInfo[const.kFightRight].camp = const.kFightRight
		self.fightEndInfo[const.kFightRight].round = self.round
	else
        self.fightEndInfo[const.kFightLeft].round = self.round
	end
end

function CFight:getFightEndInfo()
	return self.fightEndInfo
end

-- 战斗小队
local FightUser = {

}

function FightUser:new( user )
	local user = user or {}
	setmetatable(user, self)
	self.__index = self
	return user
end

function FightUser:checkEnd()
	for _, soldier in pairs(self.soldier_list) do
		if not soldier:checkEnd() and soldier.attr ~= const.kAttrTotem then
			return false
		end
	end
	return true
end

function FightUser:getLiveSoldier()
	local liveSoldier = {}
	for _, soldier in pairs(self.soldier_list) do
		if not soldier:checkEnd() and soldier.attr ~= const.kAttrTotem then
			table.insert(liveSoldier, soldier)
		end
	end
	
	return liveSoldier
end

function FightUser:getDeadSoldierCount()
	local count = 0
	for _, soldier in pairs(self.soldier_list) do
		if soldier.attr ~= const.kAttrTotem and soldier:checkEnd() then
			count = count + 1
		end
	end
	return count
end

function FightUser:addTotemValue(_r)
	local count = self:getDeadSoldierCount()
	
	self.totem_value = math.modf(self.totem_value + _r*(1+0.2*count))
	if self.totem_value > 1000 then
		self.totem_value = 1000
	end
	
	LogMgr.log( 'fight', "user guid:(" .. self.guid .. ") add totemvalue:" .. math.modf(_r*(1+0.2*count)) .. " now:" .. self.totem_value )
end

function FightUser:getTargetSoldier( liveSoldier, ackSoldier, targetRangeCond, rangeCount, target_type, skill_type)
	--检查嘲讽
	--只吸引单体攻击
	if const.kFightPhysical == skill_type or const.kFightMagic == skill_type then
		if 1 == rangeCount then
			for _,soldier in pairs(liveSoldier) do
				local fightOdd = soldier:findFightOdd(const.kFightOddXYHL)
				if nil ~= fightOdd then
					liveSoldier = {}
					table.insert(liveSoldier,soldier)
					break
				end
			end
		end
	end
	
	--检查隐身状态

	if 1 == rangeCount and target_type == const.kFightTargetOpposite then
		local fightOddPerception = ackSoldier:findFightOdd(const.kFightOddPerception)
		if nil == fightOddPerception then
			for i = #liveSoldier, 1, -1 do
				local soldier = liveSoldier[i]
				local fightOdd = soldier:findFightOdd(const.kFightOddHide)
				if nil ~= fightOdd then
					table.remove(liveSoldier,i)
				end
			end
		end
	end
	
	--检查飓风

	for i = #liveSoldier, 1, -1 do
		local soldier = liveSoldier[i]
		local fightOdd = soldier:findFightOdd(const.kFightOddStorm)
		if nil ~= fightOdd then
			table.remove(liveSoldier,i)
		end
	end
	
	--检查混乱 删除自己
	local fightOddConfusion = ackSoldier:findFightOdd(const.kFightOddConfusion)
	if nil ~= fightOddConfusion then
		for i = #liveSoldier, 1, -1 do
			local soldier = liveSoldier[i]
			if soldier.guid == ackSoldier.guid then
				table.remove(liveSoldier,i)
			end
		end
	end
	
	--排列的队员信息

	local listFront = {}
	local listMid = {}
	local listBack = {}
	local listFrontMid = {}
	local listMidBack = {}
	local listFirstRow = {}
	local listSecondRow = {}
	local listThirdRow = {}
	
	--返回的攻击目标

	local listTargetSoldier = {}
	
	--攻击者站位

	local index = ackSoldier.fight_index
	
	--添加排列队员信息
	for _, soldier in pairs( liveSoldier ) do
		if const.kFightIndexFront == soldier:getPostion() then
			table.insert(listFront, soldier)
			table.insert(listFrontMid, soldier)
		elseif const.kFightIndexMid == soldier:getPostion() then
			table.insert(listMid, soldier)
			table.insert(listFrontMid, soldier)
			table.insert(listMidBack, soldier)
		elseif const.kFightIndexBack == soldier:getPostion() then
			table.insert(listBack, soldier)
			table.insert(listMidBack, soldier)
		end
		if const.kFightIndexFirst == soldier:getRow() then
			table.insert(listFirstRow, soldier)
		elseif const.kFightIndexSecond == soldier:getRow() then
			table.insert(listSecondRow, soldier)
		elseif const.kFightIndexThird == soldier:getRow() then
			table.insert(listThirdRow, soldier)
		end
	end
	
	table.sort(listFirstRow, sortFunIndex)
	table.sort(listSecondRow, sortFunIndex)
	table.sort(listThirdRow, sortFunIndex)
	
    local theFight = theFightList[ackSoldier.selfFightId]
	
	local tempRangeCount = 0
	if targetRangeCond == const.kFightSkillCommon then
		local attackList = fightSkillCommonAttack[ackSoldier:getRow()]
		for _, index in ipairs( attackList ) do
			for _, soldier in pairs(liveSoldier) do
				if soldier.fight_index == index then
					table.insert(listTargetSoldier,soldier)
					tempRangeCount = tempRangeCount + 1;
					break;
				end
			end
			if tempRangeCount == rangeCount then
				break;
			end
		end
	elseif targetRangeCond == const.kFightSkillCommonTen then
		local attackList = fightSkillCommonAttack[ackSoldier:getRow()]
		for _, index in ipairs( attackList ) do
			local isFind = false
			for _, soldier in pairs(liveSoldier) do
				if soldier.fight_index == index then
					listTargetSoldier = getTenSoldier(liveSoldier, soldier.fight_index)
					isFind = true
					break;
				end
			end
			if isFind then
				break
			end
		end
	elseif targetRangeCond == const.kFightSkillStunFirst then
		local attackList = fightSkillCommonAttack[ackSoldier:getRow()]
		for _, index in ipairs( attackList ) do
			for _, soldier in pairs(liveSoldier) do
				local fightOdd = soldier:findFightOdd(const.kFightOddStun)
				if soldier.fight_index == index and nil ~= fightOdd then
					table.insert(listTargetSoldier,soldier)
					tempRangeCount = tempRangeCount + 1;
					break;
				end
			end
			if tempRangeCount == rangeCount then
				break;
			end
		end	
		if tempRangeCount <  rangeCount then
			for _, index in ipairs( attackList ) do
				for _, soldier in pairs(liveSoldier) do
					local fightOdd = soldier:findFightOdd(const.kFightOddStun)
					if soldier.fight_index == index and nil == fightOdd then
						table.insert(listTargetSoldier,soldier)
						tempRangeCount = tempRangeCount + 1;
						break;
					end
				end
				if tempRangeCount == rangeCount then
					break;
				end
			end		
		end	
	elseif targetRangeCond == const.kFightSkillSilentFirst then
		local attackList = fightSkillCommonAttack[ackSoldier:getRow()]
		for _, index in ipairs( attackList ) do
			for _, soldier in pairs(liveSoldier) do
				local fightOdd = soldier:findFightOdd(const.kFightOddSilent)
				if soldier.fight_index == index and nil ~= fightOdd then
					table.insert(listTargetSoldier,soldier)
					tempRangeCount = tempRangeCount + 1;
					break;
				end
			end
			if tempRangeCount == rangeCount then
				break;
			end
		end	
		if tempRangeCount <  rangeCount then
			for _, index in ipairs( attackList ) do
				for _, soldier in pairs(liveSoldier) do
					local fightOdd = soldier:findFightOdd(const.kFightOddSilent)
					if soldier.fight_index == index and nil == fightOdd then
						table.insert(listTargetSoldier,soldier)
						tempRangeCount = tempRangeCount + 1;
						break;
					end
				end
				if tempRangeCount == rangeCount then
					break;
				end
			end		
		end	
	elseif targetRangeCond == const.kFightSkillStatusId then
		for _, soldier in pairs(liveSoldier) do
			local fightOdd = soldier:findFightOdd(rangeCount)
			if nil ~= fightOdd then
				table.insert(listTargetSoldier,soldier)
			end
		end
	elseif targetRangeCond == const.kFightSkillConfusionFirst then
		local attackList = fightSkillCommonAttack[ackSoldier:getRow()]
		for _, index in ipairs( attackList ) do
			for _, soldier in pairs(liveSoldier) do
				local fightOdd = soldier:findFightOdd(const.kFightOddConfusion)
				if soldier.fight_index == index and nil ~= fightOdd then
					table.insert(listTargetSoldier,soldier)
					tempRangeCount = tempRangeCount + 1;
					break;
				end
			end
			if tempRangeCount == rangeCount then
				break;
			end
		end	
		if tempRangeCount <  rangeCount then
			for _, index in ipairs( attackList ) do
				for _, soldier in pairs(liveSoldier) do
					local fightOdd = soldier:findFightOdd(const.kFightOddConfusion)
					if soldier.fight_index == index and nil == fightOdd then
						table.insert(listTargetSoldier,soldier)
						tempRangeCount = tempRangeCount + 1;
						break;
					end
				end
				if tempRangeCount == rangeCount then
					break;
				end
			end		
		end	
	elseif targetRangeCond == const.kFightSkillRandom then
		if rangeCount >= #liveSoldier then
			return liveSoldier
		end
		while rangeCount > 0 do
			if 0 == #liveSoldier then
				break
			end
			local index = theFight:fightRand(#liveSoldier) + 1
			if nil ~= liveSoldier[index] then
				table.insert(listTargetSoldier,liveSoldier[index])
				table.remove(liveSoldier,index)
				rangeCount = rangeCount - 1
			end
		end
	elseif targetRangeCond == const.kFightSkillRandomNotSelf then
		while rangeCount > 0 do
			if 0 == #liveSoldier then
				break
			end
			local index = theFight:fightRand(#liveSoldier) + 1
			if nil ~= liveSoldier[index] then
				if ackSoldier.guid ~= liveSoldier[index].guid then
					table.insert(listTargetSoldier,liveSoldier[index])
					rangeCount = rangeCount - 1
				end
				table.remove(liveSoldier,index)
			end
		end
	elseif targetRangeCond == const.kFightSkillRandomN then
		while rangeCount > 0 do
			if 0 == #liveSoldier then
				break
			end
			local index = theFight:fightRand(#liveSoldier) + 1
			table.insert(listTargetSoldier,liveSoldier[index])
			rangeCount = rangeCount - 1
		end
	elseif targetRangeCond == const.kFightSkillRandom2N then
		if rangeCount >= 3 then
			local add_count = theFight:fightRand(rangeCount-1)
			rangeCount = 2 + add_count
		end
		if rangeCount >= #liveSoldier then
			return liveSoldier
		end
		while rangeCount > 0 do
			if 0 == #liveSoldier then
				break
			end
			local index = theFight:fightRand(#liveSoldier) + 1
			if nil ~= liveSoldier[index] then
				table.insert(listTargetSoldier,liveSoldier[index])
				table.remove(liveSoldier,index)
				rangeCount = rangeCount - 1
			end
		end
	elseif targetRangeCond == const.kFightSkillRandom1N then
		if rangeCount >= 2 then
			local add_count = theFight:fightRand(rangeCount)
			rangeCount = 1 + add_count
		end
		if rangeCount >= #liveSoldier then
			return liveSoldier
		end
		while rangeCount > 0 do
			if 0 == #liveSoldier then
				break
			end
			local index = theFight:fightRand(#liveSoldier) + 1
			if nil ~= liveSoldier[index] then
				table.insert(listTargetSoldier,liveSoldier[index])
				table.remove(liveSoldier,index)
				rangeCount = rangeCount - 1
			end
		end
	elseif targetRangeCond == const.kFightSkillHPMin then
		local soldier_sort_list = {}
		for _, soldier in pairs(liveSoldier) do
			local is_insert = false
			for i, soldier_sort in pairs( soldier_sort_list ) do
				local temp_soldier = soldier_sort[1]
				if soldier.hp/soldier.last_ext_able.hp < temp_soldier.hp/temp_soldier.last_ext_able.hp then
					local list = {}
					table.insert( list, soldier )
					table.insert( soldier_sort_list, i, list )
					is_insert = true
					break
				elseif soldier.hp/soldier.last_ext_able.hp == temp_soldier.hp/temp_soldier.last_ext_able.hp then
					table.insert( soldier_sort, soldier )
					is_insert = true
					break
				end
			end
			
			if not is_insert then
				local list = {}
				table.insert( list, soldier )
				table.insert( soldier_sort_list,  list )
			end
		end
			
		for _, soldier_sort in pairs(soldier_sort_list) do
			if rangeCount >= #soldier_sort then
				for _, soldier in pairs(soldier_sort) do
					table.insert( listTargetSoldier, soldier )
				end
				rangeCount = rangeCount - #soldier_sort
			else
				while rangeCount > 0 do
					if 0 == #soldier_sort then
						break
					end
					local index = theFight:fightRand(#soldier_sort) + 1
					if nil ~= soldier_sort[index] then
						table.insert(listTargetSoldier,soldier_sort[index])
						table.remove(soldier_sort,index)
						rangeCount = rangeCount - 1
					end
				end
			end
		end
	elseif targetRangeCond == const.kFightSkillHPMinNotSelf then
		local soldier_sort_list = {}
		for _, soldier in pairs(liveSoldier) do
			if soldier.guid ~= ackSoldier.guid then
				local is_insert = false
				for i, soldier_sort in pairs( soldier_sort_list ) do
					local temp_soldier = soldier_sort[1]
					if soldier.hp/soldier.last_ext_able.hp < temp_soldier.hp/temp_soldier.last_ext_able.hp then
						local list = {}
						table.insert( list, soldier )
						table.insert( soldier_sort_list, i, list )
						is_insert = true
						break
					elseif soldier.hp/soldier.last_ext_able.hp == temp_soldier.hp/temp_soldier.last_ext_able.hp then
						table.insert( soldier_sort, soldier )
						is_insert = true
						break
					end
				end
				
				if not is_insert then
					local list = {}
					table.insert( list, soldier )
					table.insert( soldier_sort_list,  list )
				end
			end
		end
			
		for _, soldier_sort in pairs(soldier_sort_list) do
			if rangeCount >= #soldier_sort then
				for _, soldier in pairs(soldier_sort) do
					table.insert( listTargetSoldier, soldier )
				end
				rangeCount = rangeCount - #soldier_sort
			else
				while rangeCount > 0 do
					if 0 == #soldier_sort then
						break
					end
					local index = theFight:fightRand(#soldier_sort) + 1
					if nil ~= soldier_sort[index] then
						table.insert(listTargetSoldier,soldier_sort[index])
						table.remove(soldier_sort,index)
						rangeCount = rangeCount - 1
					end
				end
			end
		end
	elseif targetRangeCond == const.kFightSkillHPMinFix then
		local soldier_sort_list = {}
		for _, soldier in pairs(liveSoldier) do
			local is_insert = false
			for i, soldier_sort in pairs( soldier_sort_list ) do
				local temp_soldier = soldier_sort[1]
				if soldier.hp < temp_soldier.hp then
					local list = {}
					table.insert( list, soldier )
					table.insert( soldier_sort_list, i, list  )
					is_insert = true
					break
				elseif soldier.hp == temp_soldier.hp then
					table.insert( soldier_sort, soldier )
					is_insert = true
					break
				end
			end
			
			if not is_insert then
				local list = {}
				table.insert( list, soldier )
				table.insert( soldier_sort_list,  list )
			end
		end
			
		for _, soldier_sort in pairs(soldier_sort_list) do
			if rangeCount >= #soldier_sort then
				for _, soldier in pairs(soldier_sort) do
					table.insert( listTargetSoldier, soldier )
				end
				rangeCount = rangeCount - #soldier_sort
			else
				while rangeCount > 0 do
					if 0 == #soldier_sort then
						break
					end
					local index = theFight:fightRand(#soldier_sort) + 1
					if nil ~= soldier_sort[index] then
						table.insert(listTargetSoldier,soldier_sort[index])
						table.remove(soldier_sort,index)
						rangeCount = rangeCount - 1
					end
				end
			end
		end
	elseif targetRangeCond == const.kFightSkillRage then
		local soldier_sort_list = {}
		for _, soldier in pairs(liveSoldier) do
			local is_insert = false
			for i, soldier_sort in pairs( soldier_sort_list ) do
				local temp_soldier = soldier_sort[1]
				if soldier.rage > temp_soldier.rage then
					local list = {}
					table.insert( list, soldier )
					table.insert( soldier_sort_list, i, list  )
					is_insert = true
					break
				elseif soldier.rage == temp_soldier.rage and soldier.last_ext_able.speed > temp_soldier.last_ext_able.speed then
					local list = {}
					table.insert( list, soldier )
					table.insert( soldier_sort_list, i, list  )
					is_insert = true
					break
				elseif soldier.rage == temp_soldier.rage and soldier.last_ext_able.speed == temp_soldier.last_ext_able.speed then
					table.insert( soldier_sort, soldier )
					is_insert = true
					break
				end
			end
			
			if not is_insert then
				local list = {}
				table.insert( list, soldier )
				table.insert( soldier_sort_list,  list )
			end
		end
			
		for _, soldier_sort in pairs(soldier_sort_list) do
			if rangeCount >= #soldier_sort then
				for _, soldier in pairs(soldier_sort) do
					table.insert( listTargetSoldier, soldier )
				end
				rangeCount = rangeCount - #soldier_sort
			else
				while rangeCount > 0 do
					if 0 == #soldier_sort then
						break
					end
					local index = theFight:fightRand(#soldier_sort) + 1
					if nil ~= soldier_sort[index] then
						table.insert(listTargetSoldier,soldier_sort[index])
						table.remove(soldier_sort,index)
						rangeCount = rangeCount - 1
					end
				end
			end
		end
	elseif targetRangeCond == const.kFightSkillRage1N then
		local soldier_sort_list = {}
		for _, soldier in pairs(liveSoldier) do
			local is_insert = false
			for i, soldier_sort in pairs( soldier_sort_list ) do
				local temp_soldier = soldier_sort[1]
				if soldier.rage > temp_soldier.rage then
					local list = {}
					table.insert( list, soldier )
					table.insert( soldier_sort_list, i, list  )
					is_insert = true
					break
				elseif soldier.rage == temp_soldier.rage and soldier.last_ext_able.speed > temp_soldier.last_ext_able.speed then
					local list = {}
					table.insert( list, soldier )
					table.insert( soldier_sort_list, i, list  )
					is_insert = true
					break
				elseif soldier.rage == temp_soldier.rage and soldier.last_ext_able.speed == temp_soldier.last_ext_able.speed then
					table.insert( soldier_sort, soldier )
					is_insert = true
					break
				end
			end
			
			if not is_insert then
				local list = {}
				table.insert( list, soldier )
				table.insert( soldier_sort_list,  list )
			end
		end
		if rangeCount >= 2 then
			local add_count = theFight:fightRand(rangeCount)
			rangeCount = 1 + add_count
		end
		for _, soldier_sort in pairs(soldier_sort_list) do
			if rangeCount >= #soldier_sort then
				for _, soldier in pairs(soldier_sort) do
					table.insert( listTargetSoldier, soldier )
				end
				rangeCount = rangeCount - #soldier_sort
			else
				while rangeCount > 0 do
					if 0 == #soldier_sort then
						break
					end
					local index = theFight:fightRand(#soldier_sort) + 1
					if nil ~= soldier_sort[index] then
						table.insert(listTargetSoldier,soldier_sort[index])
						table.remove(soldier_sort,index)
						rangeCount = rangeCount - 1
					end
				end
			end
		end
	elseif targetRangeCond == const.kFightSkillAttackMax then
		local soldier_sort_list = {}
		for _, soldier in pairs(liveSoldier) do
			local is_insert = false
			for i, soldier_sort in pairs( soldier_sort_list ) do
				local temp_soldier = soldier_sort[1]
				if math.max(soldier.last_ext_able.physical_ack,soldier.last_ext_able.magic_ack) > math.max(temp_soldier.last_ext_able.physical_ack, temp_soldier.last_ext_able.magic_ack) then
					local list = {}
					table.insert( list, soldier )
					table.insert( soldier_sort_list, i, list )
					is_insert = true
					break
				elseif math.max(soldier.last_ext_able.physical_ack,soldier.last_ext_able.magic_ack) == math.max(temp_soldier.last_ext_able.physical_ack, temp_soldier.last_ext_able.magic_ack) then
					table.insert( soldier_sort, soldier )
					is_insert = true
					break
				end
			end
			
			if not is_insert then
				local list = {}
				table.insert( list, soldier )
				table.insert( soldier_sort_list,  list )
			end
		end
			
		for _, soldier_sort in pairs(soldier_sort_list) do
			if rangeCount >= #soldier_sort then
				for _, soldier in pairs(soldier_sort) do
					table.insert( listTargetSoldier, soldier )
				end
				rangeCount = rangeCount - #soldier_sort
			else
				while rangeCount > 0 do
					if 0 == #soldier_sort then
						break
					end
					local index = theFight:fightRand(#soldier_sort) + 1
					if nil ~= soldier_sort[index] then
						table.insert(listTargetSoldier,soldier_sort[index])
						table.remove(soldier_sort,index)
						rangeCount = rangeCount - 1
					end
				end
			end
		end
	elseif targetRangeCond == const.kFightSkillMid then
		if 0 ~= #listMid then
			return listMid
		elseif 0 ~= #listBack then
			return listBack
		else
			return listFront
		end
	elseif targetRangeCond == const.kFightSkillFront then
		if 0 ~= #listFront then
			return listFront
		elseif 0 ~= #listMid then
			return listMid
		else
			return listBack
		end
	elseif targetRangeCond == const.kFightSkillBack then
		if 0 ~= #listBack then
			return listBack
		elseif 0 ~= #listMid then
			return listMid
		else
			return listFront
		end
	elseif targetRangeCond == const.kFightSkillCurrentRow then
		if const.kFightIndexFirst == ackSoldier:getRow() then
			if 0 ~= #listFirstRow then
				return listFirstRow
			elseif 0 ~= #listSecondRow then
				return listSecondRow
			else
				return listThirdRow
			end
		elseif const.kFightIndexSecond == ackSoldier:getRow() then
			if 0 ~= #listSecondRow then
				return listSecondRow
			elseif 0 ~= #listFirstRow then
				return listFirstRow
			else
				return listThirdRow
			end
		else
			if 0 ~= #listThirdRow then
				return listThirdRow
			elseif 0 ~= #listSecondRow then
				return listSecondRow
			else
				return listFirstRow
			end
		end
	elseif targetRangeCond == const.kFightSkillCurrentRowLast then
		local sortSoldier = {}
		
		table.sort(listFirstRow, sortFunIndexDesc)
		table.sort(listSecondRow, sortFunIndexDesc)
		table.sort(listThirdRow, sortFunIndexDesc)
		
		if const.kFightIndexFirst == ackSoldier:getRow() then
			table.insert(sortSoldier,listFirstRow)
			table.insert(sortSoldier,listSecondRow)
			table.insert(sortSoldier,listThirdRow)
		elseif const.kFightIndexSecond == ackSoldier:getRow() then
			table.insert(sortSoldier,listSecondRow)
			table.insert(sortSoldier,listFirstRow)
			table.insert(sortSoldier,listThirdRow)
		else
			table.insert(sortSoldier,listThirdRow)
			table.insert(sortSoldier,listSecondRow)
			table.insert(sortSoldier,listFirstRow)
		end
		
		for _, list in ipairs(sortSoldier) do
			for _, v in pairs(list) do
				table.insert(listTargetSoldier,v)
				rangeCount = rangeCount - 1
				if rangeCount <= 0 then
					break
				end
			end
			if rangeCount <= 0 then
				break
			end
		end
	elseif targetRangeCond == const.kFightSkillCurrentRowLastTen then
		local sortSoldier = {}
		
		table.sort(listFirstRow, sortFunIndexDesc)
		table.sort(listSecondRow, sortFunIndexDesc)
		table.sort(listThirdRow, sortFunIndexDesc)
		
		if const.kFightIndexFirst == ackSoldier:getRow() then
			table.insert(sortSoldier,listFirstRow)
			table.insert(sortSoldier,listSecondRow)
			table.insert(sortSoldier,listThirdRow)
		elseif const.kFightIndexSecond == ackSoldier:getRow() then
			table.insert(sortSoldier,listSecondRow)
			table.insert(sortSoldier,listFirstRow)
			table.insert(sortSoldier,listThirdRow)
		else
			table.insert(sortSoldier,listThirdRow)
			table.insert(sortSoldier,listSecondRow)
			table.insert(sortSoldier,listFirstRow)
		end
		local tarSoldier = nil
		local isFind = false
		for _, list in ipairs(sortSoldier) do
			for _, v in pairs(list) do
				tarSoldier = v
				isFind = true	
				break		
			end
			if isFind then
				break
			end
		end
		if nil ~= tarSoldier then
			listTargetSoldier = getTenSoldier(liveSoldier, tarSoldier.fight_index)
		end
	elseif targetRangeCond == const.kFightSkillCurrentRowFirst then
		local sortSoldier = {}
		table.sort(listFirstRow, sortFunIndex)
		table.sort(listSecondRow, sortFunIndex)
		table.sort(listThirdRow, sortFunIndex)
		if const.kFightIndexFirst == ackSoldier:getRow() then
			sortSoldier = listFirstRow
		elseif const.kFightIndexSecond == ackSoldier:getRow() then
			sortSoldier = listSecondRow
		else
			sortSoldier = listThirdRow
		end
		
		for _, v in ipairs(sortSoldier) do
			table.insert(listTargetSoldier,v)
			rangeCount = rangeCount - 1
			if rangeCount <= 0 then
				break
			end
		end
	elseif targetRangeCond == const.kFightSkillCurrentRowRandom then
		local sortSoldier = {}
		if const.kFightIndexFirst == ackSoldier:getRow() then
			sortSoldier = listFirstRow
		elseif const.kFightIndexSecond == ackSoldier:getRow() then
			sortSoldier = listSecondRow
		else
			sortSoldier = listThirdRow
		end
		
		while rangeCount > 0 do
			if 0 == #sortSoldier then
				break
			end
			local index = theFight:fightRand(#sortSoldier) + 1
			table.insert(listTargetSoldier,sortSoldier[index])
			table.remove(sortSoldier,index)
			rangeCount = rangeCount - 1
		end
	elseif targetRangeCond == const.kFightSkillSelf then
		table.insert(listTargetSoldier,ackSoldier)
	elseif targetRangeCond == const.kFightSkillAll then
		return liveSoldier
	elseif targetRangeCond == const.kFightSkillOccu then
		for _, soldier in pairs(liveSoldier) do
			if rangeCount == soldier.occupation then
				table.insert(listTargetSoldier, soldier)
			end
		end
	elseif targetRangeCond == const.kFightSkillEquip then
		for _, soldier in pairs(liveSoldier) do
			if rangeCount == soldier.equip_type then
				table.insert(listTargetSoldier, soldier)
			end
		end
	elseif targetRangeCond == const.kFightSkillTenRandom then
		if 0 ~= #liveSoldier then
			local index = theFight:fightRand(#liveSoldier) + 1
			local target_soldier = liveSoldier[index]
			listTargetSoldier = getTenSoldier(liveSoldier, target_soldier.fight_index)
		end
	elseif targetRangeCond == const.kFightSkillTenSelf then
		listTargetSoldier = getTenSoldier(liveSoldier, ackSoldier.fight_index)
	end
	
	return listTargetSoldier
end

local function getHurtValue(ackSoldier,tarSoldier,might,fightOrderTarget)
	local theFight = theFightList[ackSoldier.selfFightId]
	
	local ackAble = ackSoldier.last_ext_able
	local defAble = tarSoldier.last_ext_able
	
	local hurt = 0
	
	local order = ackSoldier.order
	local skill = findSkill( order.order_id, order.order_level )
	if nil == skill then
		return 0
	end
	
	local def = 0
	if toMyNumber(skill.type) == const.kFightPhysical then
		def = toMyNumber(defAble.physical_def)
	else
		def = toMyNumber(defAble.magic_def)
	end
	
	--拥有该状态时，每次攻击时忽略对方X点护甲，如果最终忽略后的护甲小于0，则把护甲值变成0
	local fightOddDefenseDelPhy = ackSoldier:findFightOdd(const.kFightOddDefenseDelPhy)
	if toMyNumber(skill.type) == const.kFightPhysical and nil ~= fightOddDefenseDelPhy then
		def = def - fightOddDefenseDelPhy.status_value
	end
	
	--拥有该状态时，每次攻击时忽略对方X点魔法抗性，如果最终忽略后的魔法抗性小于0，则把魔法抗性变成0
	local fightOddDefenseDelMag = ackSoldier:findFightOdd(const.kFightOddDefenseDelMag)
	if toMyNumber(skill.type) == const.kFightMagic and nil ~= fightOddDefenseDelMag then
		def = def - fightOddDefenseDelMag.status_value
	end
	
	--拥有该状态时，每次攻击时忽略对方X点魔法抗性和护甲，如果最终忽略后的魔法抗性和护甲小于0，则把魔法抗性和护甲变成0
	local fightOddDefenseDelAll = ackSoldier:findFightOdd(const.kFightOddDefenseDelAll)
	if nil ~= fightOddDefenseDelAll then
		def = def - fightOddDefenseDelAll.status_value
	end
	
	--容错
	if def < 0 then
		def = 0
	end
	
	--破防,一定几率无视对方防御值直接造成伤害
	local fightOddDefenseZero = ackSoldier:findFightOdd(const.kFightOddDefenseZero)
	if nil ~= fightOddDefenseZero and theFight:fightRand() < fightOddDefenseZero.status_value then
		def = 0
		local oddTriggered = FightOddTriggered:new(ackSoldier.guid, fightOddDefenseZero.id, {tarSoldier})
		table.insert(fightOrderTarget.odd_list_triggered, oddTriggered)
	end
	
	if toMyNumber(skill.type) == const.kFightPhysical then
		hurt = hurt + math.max(getSubExt(ackAble.physical_ack, def) * (might/100), ackAble.physical_ack * (might/1000)) + skill.hurt_add + tarSoldier.last_ext_able.hp*(skill.buckle_blood/10000)
	else
		hurt = hurt + math.max(getSubExt(ackAble.magic_ack, def) * (might/100), ackAble.magic_ack * (might/1000)) + skill.hurt_add + tarSoldier.last_ext_able.hp*(skill.buckle_blood/10000)
	end
		
	--拥有该buff时，敌方血量越少对敌人造成的伤害更多，血量越少伤害越多的buff计算
	local fightOddHpLessMoreHurt = ackSoldier:findFightOdd(const.kFightOddHpLessMoreHurt)
	if nil ~= fightOddHpLessMoreHurt then
		hurt = hurt * (2-tarSoldier.hp/tarSoldier.last_ext_able.hp)
		local oddTriggered = FightOddTriggered:new(ackSoldier.guid, fightOddHpLessMoreHurt.id, {tarSoldier})
		table.insert(fightOrderTarget.odd_list_triggered, oddTriggered)
	end
	
	hurt = math.modf(hurt)
	
	--hurt = 1000
	
	return hurt
end

local function getRecoverValue(ackSoldier,tarSoldier,might)
	local ackAble = ackSoldier.last_ext_able
	local defAble = tarSoldier.last_ext_able
	
	local recover = 0
	
	local order = ackSoldier.order
	local skill = findSkill( order.order_id, order.order_level )
	if nil == skill then
		return 0
	end
	
	recover = recover + tarSoldier.last_ext_able.recover_add_fix - tarSoldier.last_ext_able.recover_del_fix
	recover = recover + skill.hurt_add
	
	if toMyNumber(skill.type) == const.kFightHPRecoverTotem then
		recover = recover + tarSoldier.last_ext_able.hp * (might/100)
	elseif toMyNumber(skill.type) == const.kFightAttackHp then
		recover = recover + math.max(ackAble.physical_ack, ackAble.magic_ack) * (might/100)
	end
	
	recover = math.modf(recover)
	return recover
end

local function getMultiHurt(ackSoldier,tarSoldier, fightOrderTarget)
	local theFight = theFightList[ackSoldier.selfFightId]
	
	local multi = 10000
	
	local order = ackSoldier.order
	local skill = findSkill( order.order_id, order.order_level )
	if nil == skill then
		return multi
	end
	
	local tar_fightOdd = tarSoldier:findFightOdd(const.kFightOddArmorAdd)
	if nil ~= tar_fightOdd then
		local odd = tar_fightOdd:findOdd()
		if nil ~= odd then
			multi = multi - odd.status.objid
		end
	end
	
	--对处在昏迷效果的敌人造成更多伤害
	local ack_fightOdd = ackSoldier:findFightOdd(const.kFightOddInStunMoreHurt)
	local tar_fightOdd = tarSoldier:findFightOdd(const.kFightOddStun)
	if nil ~= ack_fightOdd and nil ~= tar_fightOdd then
		local odd = ack_fightOdd:findOdd()
		if nil ~= odd then
			local oddTriggered = FightOddTriggered:new(ackSoldier.guid, ack_fightOdd.id, {tarSoldier})
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			multi = multi + odd.status.objid
		end
	end
	
	--贝恩的目标每损伤10%血量，承受贝恩攻击时就会多受到2%伤害
	local ack_fightOdd = ackSoldier:findFightOdd(const.kFightOddHpToHurt)
	if nil ~= ack_fightOdd then
		local hp_per = (tarSoldier.last_ext_able.hp - tarSoldier.hp)/tarSoldier.last_ext_able.hp
		if hp_per < 100 and hp_per > 0 then
			multi = multi + math.modf(ack_fightOdd.status_value * hp_per)
		end
	end
	
	--易伤状态，使得被攻击时伤害增加N%（相当于原来的破甲效果，不过这个要求可以叠加），最多可以叠加3次

	local fightOddArmorDecCount = tarSoldier:findFightOdd(const.kFightOddArmorDecCount)
	if nil ~= fightOddArmorDecCount then
		local odd = fightOddArmorDecCount:findOdd()
		if nil ~= odd then
			multi = multi + odd.status.objid * fightOddArmorDecCount.now_count
		end
	end
	
	--令目标输出的伤害增加N%
	local fightOddHurtAddPer = ackSoldier:findFightOdd(const.kFightOddHurtAddPer)
	if nil ~= fightOddHurtAddPer then
		multi = multi + fightOddHurtAddPer.status_value
	end
	
	--拥有该buff时，伤害增加N%，可以叠加N次
	local fightOddHurtBuffAdd = ackSoldier:findFightOdd(const.kFightOddHurtBuffAdd)
	if nil ~= fightOddHurtBuffAdd then
		multi = multi + fightOddHurtBuffAdd.status_value * fightOddHurtBuffAdd.now_count
	end
	
	--每过一回合，英雄的伤害提高N%,最多提高M次

	local fightOddRoundBuff = ackSoldier:findFightOdd(const.kFightOddRoundBuff)
	if nil ~= fightOddRoundBuff then
		local odd = fightOddRoundBuff:findOdd()
		if nil ~= odd then
			local round = theFight.round
			if 0 ~= odd.status.val and round > odd.status.val then
				round = odd.status.val
			end
			multi = multi + odd.status.objid * round
		end
	end
	
	--若自身处于潜行状态，则自身对敌人的攻击提高n%
	local fightOddHideBuff = ackSoldier:findFightOdd(const.kFightOddHideBuff)
	if nil ~= ackSoldier.state_list[const.kFightOddHide] and nil ~= fightOddHideBuff then
		multi = multi + fightOddHideBuff.status_value
	end
	
	--若敌方处于沉默状态，则自身对其伤害提高N%
	local fightOddSilent = tarSoldier:findFightOdd( const.kFightOddSilent )
	local fightOddSilentBuff = ackSoldier:findFightOdd( const.kFightOddSilentBuff )
	if nil ~= fightOddSilent and nil ~= fightOddSilentBuff then
		multi = multi + fightOddSilentBuff.status_value
	end
	
	--识破 对装备“假死”天赋的英雄造成的伤害提高x%，并在将其杀死时直接清除出场，不能复活

	local fightOddDeadFalse = tarSoldier:findFightOdd( const.kFightOddDeadFalse )
	local fightOddPenetrate = ackSoldier:findFightOdd( const.kFightOddPenetrate )
	if nil ~= fightOddDeadFalse and nil ~= fightOddPenetrate then
		multi = multi + fightOddPenetrate.status_value
	end
	
	--天敌,克制拥有神佑技能的英雄，对其伤害结果增加x%
	local fightOddDealCall = tarSoldier:findFightOdd( const.kFightOddDealCall )
	local fightOddNaturalEnemy = ackSoldier:findFightOdd( const.kFightOddNaturalEnemy )
	if nil ~= fightOddDealCall and nil ~= fightOddNaturalEnemy then
		multi = multi + fightOddNaturalEnemy.status_value
	end
	
	--战神之力 不产生暴击，但是伤害提高x%
	local fightOddWarPower = ackSoldier:findFightOdd( const.kFightOddWarPower )
	if nil ~= fightOddWarPower then
		multi = multi + fightOddWarPower.status_value
	end
	
	--连击降低伤害
	local fightOddPhysicalDoubleHit = ackSoldier:findFightOdd( const.kFightOddPhysicalDoubleHit )
	if nil ~= fightOddPhysicalDoubleHit and ackSoldier.state_list[const.kFightOddPhysicalDoubleHit] == const.kFightOddPhysicalDoubleHit then
		local odd = fightOddPhysicalDoubleHit:findOdd()
		if nil ~= odd then
			multi = multi - odd.status.val
		end
	end
	
	--连击降低伤害
	local fightOddMagicDoubleHit = ackSoldier:findFightOdd( const.kFightOddMagicDoubleHit )
	if nil ~= fightOddMagicDoubleHit and ackSoldier.state_list[const.kFightOddMagicDoubleHit] == const.kFightOddMagicDoubleHit then
		local odd = fightOddMagicDoubleHit:findOdd()
		if nil ~= odd then
			multi = multi - odd.status.val
		end
	end
	
	--追击降低伤害
	local fightOddPursuit = ackSoldier:findFightOdd( const.kFightOddPursuit )
	if nil ~= fightOddPursuit and ackSoldier.state_list[const.kFightOddPursuit] == const.kFightOddPursuit then
		multi = multi - fightOddPursuit.status_value
	end
	
	--追击降低伤害
	local fightOddSuperPursuit = ackSoldier:findFightOdd( const.kFightOddSuperPursuit )
	if nil ~= fightOddSuperPursuit and ackSoldier.state_list[const.kFightOddSuperPursuit] == const.kFightOddSuperPursuit then
		multi = multi - fightOddSuperPursuit.status_value
	end
	
	--风怒伤害降低

	local fightOddDoubleHit = ackSoldier:findFightOdd(const.kFightOddDoubleHit)
	if nil ~= fightOddDoubleHit and ackSoldier.state_list[const.kFightOddDoubleHit] == const.kFightOddDoubleHit and nil == ackSoldier.state_list[const.kFightOddDisillusion] then
		local odd = fightOddDoubleHit:findOdd()
		if nil ~= odd then
			multi = multi - odd.status.val
		end
	end
	
	--受到的物理伤害降低N%
	local fightOddPhysicalAttackDel = tarSoldier:findFightOdd( const.kFightOddPhysicalAttackDel )
	if nil ~= fightOddPhysicalAttackDel and toMyNumber(skill.type) == const.kFightPhysical then
		multi = multi - fightOddPhysicalAttackDel.status_value
	end
	
	--受到的魔法伤害降低N%
	local fightOddMagicAttackDel = tarSoldier:findFightOdd( const.kFightOddMagicAttackDel )
	if nil ~= fightOddMagicAttackDel and toMyNumber(skill.type) == const.kFightMagic then
		multi = multi - fightOddMagicAttackDel.status_value
	end
	
	--可以减少物理或者法术攻击N%
	local fightOddDefMagicOrPhy = tarSoldier:findFightOdd(const.kFightOddDefMagicOrPhy)
	if nil ~= fightOddDefMagicOrPhy then
		local odd = fightOddDefMagicOrPhy:findOdd()
		if nil ~= odd then
			if toMyNumber(skill.type) == const.kFightPhysical and 0 == odd.status.val then
				multi = multi - fightOddDefMagicOrPhy.status_value
			elseif toMyNumber(skill.type) == const.kFightMagic and 1 == odd.status.val then
				multi = multi - fightOddDefMagicOrPhy.status_value
			end
		end
	end
	
	--受到的近战伤害降低N%
	local fightOddDefMelee = tarSoldier:findFightOdd( const.kFightOddDefMelee )
	if nil ~= fightOddDefMelee and toMyNumber(skill.type) == const.kFightPhysical and const.kFightMelee == skill.distance then
		multi = multi - fightOddDefMelee.status_value
	end
	
	--受到的远程伤害降低N%
	local fightOddDefRanged = tarSoldier:findFightOdd( const.kFightOddDefRanged )
	if nil ~= fightOddDefRanged and toMyNumber(skill.type) == const.kFightMagic and const.kFightRanged == skill.distance then
		multi = multi - fightOddDefRanged.status_value
	end
	
	--在敌方身上的流血效果每持续多一回合，伤害提高

	local fightOddBlood = tarSoldier:findFightOdd( const.kFightOddBlood )
	local fightOddBloodBuff = ackSoldier:findFightOdd( const.kFightOddBloodBuff )
	if nil ~= fightOddBlood and nil ~= fightOddBloodBuff and theFight.round > fightOddBlood.begin_round then
		multi = multi + fightOddBloodBuff.status_value*(theFight.round-fightOddBlood.begin_round)
	end
	
	--拥有该Buff时，打某种甲的伤害增加N%.
	local fightOddEquipTypeHurt = ackSoldier:findFightOdd( const.kFightOddEquipTypeHurt )
	if nil ~= fightOddEquipTypeHurt and fightOddEquipTypeHurt.status_value == tarSoldier.equip_type then
		local odd = fightOddEquipTypeHurt:findOdd()
		if nil ~= odd then
			multi = multi + odd.status.val
		end
	end
	
	--被某种甲的英雄打时受到的伤害减少N%
	local fightOddEquipTypeDef = tarSoldier:findFightOdd( const.kFightOddEquipTypeDef )
	if nil ~= fightOddEquipTypeDef and fightOddEquipTypeDef.status_value == ackSoldier.equip_type then
		local odd = fightOddEquipTypeDef:findOdd()
		if nil ~= odd then
			multi = multi - odd.status.val
		end
	end
	
	--对单体敌人释放焚烧，造成大量伤害,如果目标身上有燃烧效果，那么受到的伤害提升30%
	local fightOddBuffHurt = ackSoldier:findFightOdd(const.kFightOddBuffHurt)
	if nil ~= fightOddBuffHurt then
		local fightOddTarget = tarSoldier:findFightOdd(fightOddBuffHurt.status_value)
		if nil ~= fightOddTarget then
			local odd = fightOddBuffHurt:findOdd()
			if nil ~= odd then
				multi = multi + odd.status.val
			end
		end
	end
	
	if multi < 1000 then
		multi = 1000
	end
	
	return multi
end

local function getMultiRecoverHurt(ackSoldier,tarSoldier)
	local theFight = theFightList[ackSoldier.selfFightId]
	
	local multi = 10000
	multi = multi + tarSoldier.last_ext_able.recover_add_per - tarSoldier.last_ext_able.recover_del_per
	
	--自身治疗别人增加的治疗效果

	local fightOddRecoverSelfAdd = ackSoldier:findFightOdd(const.kFightOddRecoverSelfAdd)
	if nil ~= fightOddRecoverSelfAdd then
		multi = multi + fightOddRecoverSelfAdd.status_value
	end
	
	--自身治疗别人减少的治疗效果

	local fightOddRecoverSelfDel = ackSoldier:findFightOdd(const.kFightOddRecoverSelfDel)
	if nil ~= fightOddRecoverSelfDel then
		multi = multi - fightOddRecoverSelfDel.status_value
	end
	
	--被治疗效果增加

	local fightOddRecoverTarAdd = tarSoldier:findFightOdd(const.kFightOddRecoverTarAdd)
	if nil ~= fightOddRecoverTarAdd then
		multi = multi + fightOddRecoverTarAdd.status_value
	end
	
	--被治疗效果减少

	local fightOddRecoverTarDel = tarSoldier:findFightOdd(const.kFightOddRecoverTarDel)
	if nil ~= fightOddRecoverTarDel then
		multi = multi - fightOddRecoverTarDel.status_value
	end
	
	--风怒伤害降低

	local fightOddDoubleHit = ackSoldier:findFightOdd(const.kFightOddDoubleHit)
	if nil ~= fightOddDoubleHit and ackSoldier.state_list[const.kFightOddDoubleHit] == const.kFightOddDoubleHit then
		local odd = fightOddDoubleHit:findOdd()
		if nil ~= odd then
			multi = multi - odd.status.val
		end
	end
	
	if multi < 1000 then
		multi = 1000
	end
	
	return multi
end

function CFight:getFightRand( ackSoldier )
	local level = ackSoldier.level
	local wave = 1
	if level > 20 then
		wave = (9500 + self:fightRand(1001))/10000
	end
	return wave
end

function CFight:startAttack( ackSoldier, tarSoldier, fightLog )
	LogMgr.log( 'fight', "startAttack")
	local theFight = theFightList[ackSoldier.selfFightId]
	local fightOrderTarget = FightOrderTarget:new(tarSoldier)
	table.insert(fightLog.orderTargetList, fightOrderTarget)
	
	local ackAble = ackSoldier.last_ext_able
	local defAble = tarSoldier.last_ext_able
	
	local order = ackSoldier.order
	
	if nil == order then
		return
	end
	local skill = findSkill( order.order_id, order.order_level )
	if nil == skill then
		return
	end
	
	--如果已经是0血了

	if 0 == tarSoldier.hp then
		return
	end
	
	--是否能打断别人技能

	if self:fightRand() < skill.break_per and 0 ~= tarSoldier.isPlay then
		local tar_skill = findSkill( tarSoldier.order.order_id, order.order_level)
		if nil ~= tar_skill and 0 ~= tar_skill.can_break then
			local odd = findOdd(const.kOddBreakID,1)
			if nil ~= odd then
				tarSoldier:setFightOdd(odd, theFight.round, ackSoldier.guid, fightLog.orderTargetList,fightOrderTarget)
			end
		end
	end
		
	local hitPer = ackAble.hitper - defAble.dodgeper
	local isParry = false
	local isDodge = false
	local isCrit = false
	local isHit = self:fightRand() < hitPer
	local hurt = 0
	
	local fightOddStone = tarSoldier:findFightOdd(const.kFightOddStone)
	if nil ~= fightOddStone then
		isHit = true
	end
	if ackSoldier.selfUserGuid == tarSoldier.selfUserGuid then
		isHit = true
	end
	
	--命中的情况下 添加BUFF
	if isHit then
		--被打醒

		local fightOddSleep = tarSoldier:findFightOdd( const.kFightOddSleep )
		if nil ~= fightOddSleep then
			tarSoldier:delFightOdd(fightOddSleep,orderTargetList,fightOrderTarget)
		end
		--被打醒

		local fightOddSheep = tarSoldier:findFightOdd( const.kFightOddChangeSheep )
		if nil ~= fightOddSheep then
			tarSoldier:delFightOdd(fightOddSheep,orderTargetList,fightOrderTarget)
		end
		
		--拥有buffA攻击带buffB的人，buffA的人额外增加N点怒气，并给buffB添加一个状态add一个odd
		local fightOddbuffA = ackSoldier:findFightOdd(const.kFightOddbuffA)
		local fightOddbuffB = tarSoldier:findFightOdd(const.kFightOddbuffB)
		if nil ~= fightOddbuffA and nil ~= fightOddbuffB then
			ackSoldier:addRage(fightOddbuffA.status_value)
			local fightOrderTarget = FightOrderTarget:new(ackSoldier)
			table.insert(fightLog.orderTargetList, fightOrderTarget)		
			local odd = fightOddbuffA:findOdd()
			if nil ~= odd then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				if nil ~= addOdd then
					tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
	
		if nil ~= fightOddRageAddSave and self:fightRand() < fightOddRageAddSave.status_value then
			local rage = self:fightRand(16) + 5
			soldier:addRage(rage)
		end
		
		--侵蚀 攻击时可减少对方一定量的怒气
		local fightOddErode = ackSoldier:findFightOdd( const.kFightOddErode )
		if nil ~= fightOddErode and self:fightRand() < fightOddErode.status_value then
			local odd = fightOddErode:findOdd()
			if nil ~= odd then
				tarSoldier:delRage(odd.status.val)
				fightOrderTarget.rage = tarSoldier.rage
				local oddTriggered = FightOddTriggered:new(ackSoldier.guid, fightOddErode.id,{tarSoldier})
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			end
		end
		
		--拥有该状态时，每次使用普通攻击时额外获得XX点图腾活力值

		local fightOddAttackAddTotemValue = ackSoldier:findFightOdd(const.kFightOddAttackAddTotemValue)
		if 0 == skill.self_costrage and nil ~= fightOddAttackAddTotemValue then
			ackSoldier:addTotemValue(fightOddAttackAddTotemValue.status_value)
			local fightOrderTarget = FightOrderTarget:new(ackSoldier)
			table.insert(fightLog.orderTargetList, fightOrderTarget )
		end
		
		tarSoldier:delRage(toMyNumber(skill.def_delrage))
		tarSoldier:addRage(toMyNumber(skill.def_addrage))
		fightOrderTarget.rage = tarSoldier.rage
		
		tarSoldier:addTotemValue(skill.def_addtotem)
		fightOrderTarget.totem_value = tarSoldier:getTotemValue()
		
		--普通攻击对敌方目标上毒的几率提升10%
		local fightOddBuffPercent = ackSoldier:findFightOdd(const.kFightOddBuffPercent)
		--攻击时，对所有敌人造成冰冻的几率提升10%（普通技能与大大招也有10%几率造成冰冻）

		local fightOddBuffPercent2 = ackSoldier:findFightOdd(const.kFightOddBuffPercent2)
		for _, fightOdd in pairs( skill.odds ) do
			local odd = findOdd( fightOdd.first, fightOdd.second )
			
			if nil ~= odd and const.kFightTargetOpposite == toMyNumber(odd.target_type_skill) then
				local percent = toMyNumber(odd.percent)
				if 0 == skill.self_costrage and nil ~= fightOddBuffPercent and odd.status.cate == fightOddBuffPercent.status_value then
					local oddBuffPercent = fightOddBuffPercent:findOdd()
					if nil ~= oddBuffPercent then
                        percent = percent + oddBuffPercent.status.val
					end
				end
				if nil ~= fightOddBuffPercent2 and odd.status.cate == fightOddBuffPercent2.status_value then
					local oddBuffPercent = fightOddBuffPercent2:findOdd()
					if nil ~= oddBuffPercent then
						percent = percent + oddBuffPercent.status.val
					end
				end
				if self:fightRand() < percent then
					tarSoldier:setFightOdd( odd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
		
		--使用某个id的主动技能时额外触发多一个buff(这个buff可以加个自己也可以加给敌方)
		local fightOddSkill = ackSoldier:findFightOdd(const.kFightOddSkillBuff)
		if nil ~= fightOddSkill and fightOddSkill.status_value == skill.id then
			local odd = fightOddSkill:findOdd()
			if nil ~= odd then
				if self:fightRand() < toMyNumber(odd.percent) then
					local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
					if nil ~= addOdd then
						tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
					end
				end
			end
		end
		
		--使用某个id的主动技能时额外触发多一个buff(这个buff可以加个自己也可以加给敌方)
		local fightOddSkillList = ackSoldier:findFightOddList(const.kFightOddSkillBuffSelf)
		for _, fightOddSkill in pairs( fightOddSkillList ) do
			if nil ~= fightOddSkill and fightOddSkill.status_value == skill.id then
				local odd = fightOddSkill:findOdd()
				if nil ~= odd and self:fightRand() < toMyNumber(odd.status.val) then
					local addodd = findOdd( odd.addodd.first, odd.addodd.second )
					if nil ~= addodd then
						local tarList = {}
						if odd.target_type_special == const.kFightTargetOpposite then
							tarList = {tarSoldier}
							tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
						elseif odd.target_type_special == const.kFightTargetSelf then
							tarList = {ackSoldier}
							ackSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
						else
							local tarSoldier = theFight:getTargetSoldier(ackSoldier,odd)
							tarList = tarSoldier
							if nil ~= tarSoldier then
								for _, soldier in pairs(tarSoldier) do
                                    soldier:setFightOdd(addodd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
								end
							end
						end
						local oddTriggered = FightOddTriggered:new(ackSoldier.guid, fightOddSkill.id,tarList)
						table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
					end
				end
			end
		end
		
		--攻击时都会有几率额外触发另外一个被动技能

		local fightOddAttackOdd = ackSoldier:findFightOdd(const.kFightOddAttackToOdd)
		if nil ~= fightOddAttackOdd and  self:fightRand() < fightOddAttackOdd.status_value then
			local odd = fightOddAttackOdd:findOdd()
			if nil ~= odd then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				if nil ~= addOdd then
					if const.kFightTargetOpposite == odd.status.val then
						tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
					else
						ackSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
					end
				end
			end
		end
		
		--单体攻击时，有一定几率偷去敌方的攻击N%（自己物攻和法攻增加N%,敌方的物攻和法攻减少N%），最多可以叠加N次，持续3回合.
		local fightOddSuckExt = ackSoldier:findFightOdd(const.kFightOddSuckExt)
		if skill.target_range_count == 1 and nil ~= fightOddSuckExt and  self:fightRand() < fightOddSuckExt.status_value then
			local odd = fightOddSuckExt:findOdd()
			if nil ~= odd then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				local addOddTar = findOdd( odd.addodd.first+1, odd.addodd.second)
				if nil ~= addOdd and nil ~= addOddTar then
					tarSoldier:setFightOdd(addOddTar, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
					ackSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
		
		--普通攻击有20%几率使敌人昏迷1回

		local fightOddStun = tarSoldier:findFightOdd( const.kFightOddAttachToStun )
		if nil ~= fightOddStun and 0 == skill.self_costrage and 0 == skill.disillusion then
			local odd = fightOddStun:findOdd()
			if nil ~= odd then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				if nil ~= addOdd then
					tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
		
		--被法术攻击击中时，有一定几率给被攻击着增加一个buff
		local fightOddMagicHit = tarSoldier:findFightOdd( const.kFightOddMagicHitBuff )
		if skill.type == const.kFightMagic and nil ~= fightOddMagicHit and self:fightRand() < fightOddMagicHit.status_value then
			local odd = fightOddMagicHit:findOdd()
			if nil ~= odd then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				if nil ~= addOdd then
					tarSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
		
		--被攻击击中时，有一定几率给攻击着增加一个buff
		local fightOddHit = tarSoldier:findFightOdd( const.kFightOddHitBuff )
		if nil ~= fightOddHit and self:fightRand() < fightOddHit.status_value then
			local odd = fightOddHit:findOdd()
			if nil ~= odd then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				if nil ~= addOdd then
					ackSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
		
		--被攻击击中时，有一定几率给被攻击增加一个buff
		local fightOddHit = tarSoldier:findFightOdd( const.kFightOddHitBuffDef )
		if nil ~= fightOddHit and self:fightRand() < fightOddHit.status_value then
			local odd = fightOddHit:findOdd()
			if nil ~= odd then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				if nil ~= addOdd then
					tarSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
		
		--暗影之舞,此状态下会一直保持潜行状态，并在攻击时偷袭目标，对目标造成昏迷效果，持续2回合
		local fightOddNightDance = ackSoldier:findFightOdd(const.kFightOddNightDance)
		if nil ~= fightOddNightDance and self:fightRand() < fightOddNightDance.status_value then
			local odd = fightOddNightDance:findOdd()
			if nil ~= odd then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				if nil ~= addOdd then
					tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
		
		--会延长其昏迷1回合
		local fightOddStun = tarSoldier:findFightOdd( const.kFightOddStun )
		local fightOddMoreStun = ackSoldier:findFightOdd( const.kFightOddInStunMoreTime )
		if nil ~= fightOddStun and nil ~= fightOddMoreStun then
			fightOddStun.start_round = fightOddStun.start_round + fightOddMoreStun.status_value
			local fightOddSet = FightOddSet:new()
			fightOddSet.guid = self.guid
			fightOddSet.set_type = const.kObjectUpdate
			fightOddSet.fightOdd = copyTab(fightOddStun)
			table.insert(fightOrderTarget.odd_list,fightOddSet)
			local oddTriggered = FightOddTriggered:new(ackSoldier.guid, fightOddMoreStun.id,{tarSoldier})
			table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		end
	else
		tarSoldier:addEndInfoDodge()
		fightOrderTarget.fight_type = const.kFightDodge
		local fightOddCounter = tarSoldier:findFightOdd( const.kFightOddCounter )
		if nil ~= fightOddCounter then
			tarSoldier:addOddCount( fightOddCounter )
			local fightOrder = { order_id = tarSoldier.skill_list[1].skill_id, order_level = tarSoldier.skill_list[1].skill_level }
			tarSoldier:setOrder( fightOrder )
			tarSoldier.state_list[const.kFightOddCounter] = const.kFightOddCounter
			self:startAttack( tarSoldier, ackSoldier, fightLog )
			tarSoldier.state_list[const.kFightOddCounter] = nil
		end
		return
	end
	
	--拥有该状态时，伤害结果增加X点。如果是多次伤害的技能则，每次的伤害为 X/伤害的次数 
	local hurt_add = 0
	local fightOddHurtAddFix = ackSoldier:findFightOdd( const.kFightOddHurtAddFix )
	if nil ~= fightOddHurtAddFix then
		local count = #skill.mights
		hurt_add = hurt_add + fightOddHurtAddFix.status_value/count
	end
	
	--拥有该状态时，受到的伤害结果减少X点，如果是被多次伤害的技能攻击时，每次减少的伤害为 X/伤害的次数

	local fightOddHurtDelFix = tarSoldier:findFightOdd( const.kFightOddHurtDelFix )
	if nil ~= fightOddHurtDelFix then
		local count = #skill.mights
		hurt_add = hurt_add - fightOddHurtDelFix.status_value/count
	end
	
	hurt_add = math.modf(hurt_add)
	
	--是否反击
	local isAntiAttack = false
	local isCritBuff = false
	local isParryBuff = false
	local antiAttackOdd = nil
	local hurt_all = 0
	--是否献祭
	local isInFire = false
	for fight_might, mightRange in pairs(skill.mights) do
		if nil ~= mightRange then
			local might_add = 0
			local fightOddMight = ackSoldier:findFightOdd( const.kFightOddCommonAttackMight )
			if nil ~= fightOddMight then
				might_add = fightOddMight.status_value
			end
			
			local might_wave = self:getFightRand(ackSoldier)
			--图腾的血量是0
			local might = 0
			if 0 ~= ackSoldier.last_ext_able.hp then
				might = might_wave * (mightRange.first + (1-(ackSoldier.hp/ackSoldier.last_ext_able.hp))*(mightRange.second-mightRange.first)) + might_add
			end
			
			--闪电链BUFF
			local fightOddLight = ackSoldier:findFightOdd( const.kFightOddLightning )
			if nil ~= fightOddLight then
				might = might - fightOddLight.status_value*fightOddLight.now_count
				if might < 0 then
					might = 0
				end
			end
			
			local fightOrderTarget = FightOrderTarget:new(tarSoldier)
			fightOrderTarget.fight_might = fight_might
			table.insert(fightLog.orderTargetList, fightOrderTarget )
			hurt = getHurtValue(ackSoldier,tarSoldier,might,fightOrderTarget)
			ackSoldier:addEndInfoAttack()
			
			--波动 造成的伤害波动范围扩大x%
			local fightOddWave = ackSoldier:findFightOdd(const.kFightOddWave)
			if nil ~= fightOddWave then
				local odd = fightOddWave:findOdd()
				if nil ~= odd then
					local fight_wave = odd.status.objid + (odd.status.val-odd.status.objid)*(self:fightRand()/10000)
					hurt = math.modf(hurt * (fight_wave/10000))
					local oddTriggered = FightOddTriggered:new(ackSoldier.guid, fightOddWave.id)
					table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
				end
			end
			
			--拥有该buff时，对于50%生命(写死)以下敌人的攻击，会额外造成对方生命值10%（填v1)的伤害，最多不超过自身攻击的N%(填v2)
			local fightHpToExtraHurt = ackSoldier:findFightOdd(const.kFightHpToExtraHurt)
			if nil ~= fightHpToExtraHurt and (tarSoldier.hp < tarSoldier.last_ext_able.hp/2) and (fightHpToExtraHurt.ext_value == 0 or ((self.round-fightHpToExtraHurt.ext_value)%3 == 0)) then
				local odd = fightHpToExtraHurt:findOdd()
				if nil ~= odd then
					local hurt_add = math.modf(tarSoldier.last_ext_able.hp * (odd.status.objid/10000))
					if hurt_add > odd.status.val then
						hurt_add = odd.status.val
					end
					hurt = hurt + hurt_add
					local oddTriggered = FightOddTriggered:new(ackSoldier.guid, fightHpToExtraHurt.id)
					table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
					fightHpToExtraHurt.ext_value = self.round
				end
			end
			
			local add_crit_per = 0
			local fightOddBeCrit = tarSoldier:findFightOdd(const.kFightOddBeCrit)
			if nil ~= fightOddBeCrit then
				add_crit_per = fightOddBeCrit.status_value
			end
			
			local critper = ackSoldier.last_ext_able.critper - tarSoldier.last_ext_able.critper_def + add_crit_per
			local crithurt = ackSoldier.last_ext_able.crithurt - tarSoldier.last_ext_able.crithurt_def
			local parryper = tarSoldier.last_ext_able.parryper - ackSoldier.last_ext_able.parryper_dec
			
			--攻击中了某个odd的人时，自身对其暴击几率提高N%
			local fightOddHaveOddCirt = ackSoldier:findFightOdd(const.kFightOddHaveOddCirt)
			if nil ~= fightOddHaveOddCirt then
				local fightOddTarget = tarSoldier:findFightOddById(fightOddHaveOddCirt.status_value)
				if nil ~= fightOddTarget then
					local odd = fightOddHaveOddCirt:findOdd()
					critper = critper + odd.status.val
				end
			end
			
			--幸运,不会被暴击，但双防降低x%
			local fightOddLucky = tarSoldier:findFightOdd(const.kFightOddLucky)
			--战神之力,不产生暴击，但是伤害提高x%
			local fightOddWarPower = ackSoldier:findFightOdd(const.kFightOddWarPower)
			if nil == fightOddLucky and nil == fightOddWarPower and self:fightRand() < critper then
				hurt = math.modf(hurt * ((15000 + crithurt)/10000))
				fightOrderTarget.fight_type = const.kFightCrit
				isCrit = true
				
				--暴击时增加BUFF
				local fightOdd = ackSoldier:findFightOdd(const.kFightOddCirtBuff)
				if nil ~= fightOdd and self:fightRand() < fightOdd.status_value and not isCritBuff then
					isCritBuff = true
					local odd = fightOdd:findOdd()
					if nil ~= odd then
						ackSoldier:addOddCount(fightOdd)
						local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
						if nil ~= addOdd then
							if odd.target_type_special == const.kFightTargetOpposite then
								tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
							elseif odd.target_type_special == const.kFightTargetSelf then
								ackSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
							else
								local tarSoldier = theFight:getTargetSoldier(ackSoldier,odd)
								if nil ~= tarSoldier then
									for _, soldier in pairs(tarSoldier) do
										soldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
									end
								end
							end
						end
					end
				end
			end
			
			if self:fightRand() < parryper then
				hurt = math.modf(hurt * 0.6)
				isParry = true
				fightOrderTarget.fight_type = const.kFightParry
				
				--格挡时增加BUFF
				local fightOdd = tarSoldier:findFightOdd(const.kFightOddCirtParry)
				if nil ~= fightOdd and not isParryBuff then
					isParryBuff = true
					local odd = fightOdd:findOdd()
					if nil ~= odd then
						tarSoldier:addOddCount(fightOdd)
						local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
						if nil ~= addOdd then
							if odd.target_type_special == const.kFightTargetOpposite then
								tarSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
							elseif odd.target_type_special == const.kFightTargetSelf then
								ackSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
							else
								local tarS = theFight:getTargetSoldier(ackSoldier,odd)
								if nil ~= tarS then
									for _, soldier in pairs(tarS) do
										soldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
									end
								end
							end
						end
					end
				end
				
				--BOSS格挡率大幅提升，并且每次格挡后都反击
				local fightOddParry = tarSoldier:findFightOdd(const.kFightOddParryAntiAttack)
				local fightOddStun = tarSoldier:findFightOdd(const.kFightOddStun)
				if nil == fightOddStun and nil ~= fightOddParry and 1 == skill.target_range_count and const.kFightMelee == skill.distance and not isAntiAttack then
					local odd = fightOddParry:findOdd()
					if nil ~= odd then
						if self:fightRand() < odd.status.objid then
							tarSoldier:addOddCount(fightOddParry)
							isAntiAttack = true
							antiAttackOdd = fightOddParry
						end
					end
				end
			end
			
			--计算伤害倍数
			local multi = getMultiHurt(ackSoldier, tarSoldier, fightOrderTarget )
			
			if multi < 0 then
				hurt = 0
			else
				hurt = math.modf(hurt*(multi/10000))
			end
			
			--添加额外的伤害

			hurt = hurt + hurt_add
			
			if hurt < 0 then
				hurt = 0
			end
			
			--神迹 有x%几率将受到的伤害变成1
			local fightOddSign = tarSoldier:findFightOdd( const.kFightOddSign )
			if nil ~= fightOddSign and self:fightRand() < fightOddSign.status_value then
				local oddTriggered = FightOddTriggered:new(tarSoldier.guid, fightOddSign.id)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
				hurt = 1
			end
			
			--物理免疫，被物理攻击时，有一定几率免疫物理伤害

			local fightOddPhy = tarSoldier:findFightOdd( const.kFightOddPhyInvincible )
			if nil ~= fightOddPhy and skill.type == const.kFightPhysical and self:fightRand() < fightOddPhy.status_value then
				hurt = 0
				local oddTriggered = FightOddTriggered:new(tarSoldier.guid, fightOddPhy.id)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			end
			--法术免疫，被法术攻击时，有一定几率免疫法术伤害

			local fightOddMag = tarSoldier:findFightOdd( const.kFightOddMagInvincible )
			if nil ~= fightOddMag and skill.type == const.kFightMagic and self:fightRand() < fightOddMag.status_value then
				hurt = 0
				local oddTriggered = FightOddTriggered:new(tarSoldier.guid, fightOddMag.id)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			end
			
			LogMgr.log( 'fight',  "round:" ..  theFight.round .. ",ack_guid(" .. ackSoldier.name .. "):" .. ackSoldier.guid .. ",def_guid(" .. tarSoldier.name .. "):" .. tarSoldier.guid .. ",useskill(" .. skill.name .. "):" .. skill.id )
			fightOrderTarget.fight_result = const.kFightDicHP
			fightOrderTarget.fight_value = tarSoldier:reduceHP(ackSoldier, hurt, fightLog.orderTargetList, fightOrderTarget, 0)
			fightOrderTarget.hp = tarSoldier.hp
			--计算总伤害
			hurt_all = hurt_all + fightOrderTarget.fight_value
						
			if skill.type == const.kFightMagic then
				ackSoldier:addEndInfoMagicHurt(fightOrderTarget.fight_value)
			end
			
			--反击
			if ackSoldier.state_list[const.kFightOddAntiAttack] == const.kFightOddAntiAttack then
				fightOrderTarget.fight_attr = const.kFightAttrAntiAttack
				fightOrderTarget.guid = ackSoldier.guid
				fightOrderTarget.attr = ackSoldier.attr
			end
			--反制
			if ackSoldier.state_list[const.kFightOddCounter] == const.kFightOddCounter then
				fightOrderTarget.fight_attr = const.kFightAttrCounter
				fightOrderTarget.guid = ackSoldier.guid
				fightOrderTarget.attr = ackSoldier.attr
			end
			if tarSoldier:checkEnd() then
				--把剩下的攻击加进去 但是不触发特效

				if fight_might < #skill.mights then
					for i = fight_might+1, #skill.mights do
						local temp_mightRange = skill.mights[i]
						local temp_might = temp_mightRange.first + (1-(ackSoldier.hp/ackSoldier.last_ext_able.hp))*(temp_mightRange.second-temp_mightRange.first)
						local temp_fightOrderTarget = FightOrderTarget:new(tarSoldier)
						temp_fightOrderTarget.fight_might = i
						table.insert(fightLog.orderTargetList, temp_fightOrderTarget )
						temp_fightOrderTarget.fight_result = const.kFightDicHP
						temp_fightOrderTarget.fight_value = math.modf(fightOrderTarget.fight_value * (temp_might/might))
						temp_fightOrderTarget.hp = tarSoldier.hp
						temp_fightOrderTarget.fight_attr = fightOrderTarget.fight_attr
					end
				end
				
				tarSoldier:oddDeadEffect(fightLog.orderTargetList)
				break
			end
			
			--攻击回血
			local fightOdd = ackSoldier:findFightOdd(const.kFightOddAttackToHPPer)
			if nil ~= fightOdd then
				local odd = fightOdd:findOdd()
				if nil ~= odd then
					ackSoldier:addOddCount(fightOdd)
					local fightOrderTarget = FightOrderTarget:new(ackSoldier)
					table.insert(fightLog.orderTargetList, fightOrderTarget )
					fightOrderTarget.fight_result = const.kFightAddHP
					fightOrderTarget.odd_id = fightOdd.id
					fightOrderTarget.fight_value = math.modf(hurt * (odd.status.objid/10000))
					fightOrderTarget.rage = ackSoldier.rage
					ackSoldier:addHP(fightOrderTarget.fight_value)
					fightOrderTarget.hp = ackSoldier.hp
				end
			end
			
			--攻击回血
            if 0 ~= skill.suck_hp then
                local fightOrderTarget = FightOrderTarget:new(ackSoldier)
                table.insert(fightLog.orderTargetList, fightOrderTarget )
                fightOrderTarget.fight_result = const.kFightAddHP
                fightOrderTarget.fight_value = math.modf(hurt * (skill.suck_hp/10000))
                ackSoldier:addHP(fightOrderTarget.fight_value)
                fightOrderTarget.hp = ackSoldier.hp
            end
			
			--攻击被施加“吸血鬼之触”状态的敌方目标时，可将所造成伤害的15%回复成自身血量

			local fightOdd = tarSoldier:findFightOdd(const.kFightOddAttackToHp)
			if nil ~= fightOdd then
				local odd = fightOdd:findOdd()
				if nil ~= odd then
					local fightOrderTarget = FightOrderTarget:new(ackSoldier)
					table.insert(fightLog.orderTargetList, fightOrderTarget )
					fightOrderTarget.fight_result = const.kFightAddHP
					fightOrderTarget.odd_id = fightOdd.id
					fightOrderTarget.fight_value = math.modf(hurt * (odd.status.objid/10000))
					fightOrderTarget.rage = ackSoldier.rage
					ackSoldier:addHP(fightOrderTarget.fight_value)
					fightOrderTarget.hp = ackSoldier.hp
				end
			end
			
			--反击
			local fightOdd = tarSoldier:findFightOdd(const.kFightOddAntiAttack)
			local fightOddStun = tarSoldier:findFightOdd(const.kFightOddStun)
			if isHit and nil == fightOddStun and nil ~= fightOdd and 1 == skill.target_range_count and const.kFightMelee == skill.distance and not isAntiAttack and tarSoldier:canAttack() then
				local odd = fightOdd:findOdd()
				if nil ~= odd then
					if self:fightRand() < odd.status.objid then
						tarSoldier:addOddCount(fightOdd)
						isAntiAttack = true
						antiAttackOdd = fightOdd
					end
				end
			end
				
			--献祭
			local fightOdd = tarSoldier:findFightOdd(const.kFightOddInFire)
			if isHit and nil ~= fightOdd and const.kFightPhysical == toMyNumber(skill.type) and const.kFightMelee == skill.distance and not isInFire then
				local odd = fightOdd:findOdd()
				if nil ~= odd then
					if self:fightRand() < odd.status.objid then
						isInFire = true
						tarSoldier:addOddCount(fightOdd)
						local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
						if nil ~= addOdd then
							ackSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
						end
						if ackSoldier:checkEnd() then
							break
						end
					end
				end
			end
		end
	end
	
	--可以减少物理或者法术攻击
	if isHit and not tarSoldier:checkEnd() then
		local fightOddDefMagicOrPhy = tarSoldier:findFightOdd(const.kFightOddDefMagicOrPhy)
		if nil ~= fightOddDefMagicOrPhy then
			local odd = fightOddDefMagicOrPhy:findOdd()
			if nil ~= odd then
				if (0 ==  odd.status.val and skill.type == const.kFightMagic) or (1 == odd.status.val and skill.type == const.kFightPhysical) then
					local addodd = findOdd( odd.addodd.first, odd.addodd.second)
					if nil ~= addodd then
						local fightOrderTarget = FightOrderTarget:new(tarSoldier)
						table.insert(fightLog.orderTargetList, fightOrderTarget )
						tarSoldier:delFightOdd(fightOddDefMagicOrPhy,fightLog.orderTargetList,fightOrderTarget)
						tarSoldier:setFightOdd(addodd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
					end
				end
			end
		end
	end
	
	--每次受到50%以上血量的攻击，都有50%几率产生一个吸收5%最大血量的护盾
	local fightOddRedeceBuff = tarSoldier:findFightOdd(const.kFightOddReduceHpBuff)
	if nil ~= fightOddRedeceBuff and hurt_all > tarSoldier.last_ext_able.hp * (fightOddRedeceBuff.status_value/10000) then
		local odd = fightOddRedeceBuff:findOdd()
		if nil ~= odd then
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second )
			if nil ~= addOdd then
				if odd.target_type_special == const.kFightTargetOpposite then
						ackSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				elseif odd.target_type_special == const.kFightTargetSelf then
						tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				else
					local tarS = theFight:getTargetSoldier(tarSoldier,odd)
					if nil ~= tarS then
						for _, soldier in pairs(tarS) do
							soldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
						end
					end
				end
			end
		end
	end
	
	--反震
	local fightOddSneak = ackSoldier:findFightOdd( const.kFightOddSneak )
	local fightOdd = tarSoldier:findFightOdd(const.kFightOddAttactReboundPer)
	if nil ~= fightOdd and nil == fightOddSneak and ackSoldier.attr ~= const.kAttrTotem and not tarSoldier:checkEnd() then
		local odd = fightOdd:findOdd()
		if nil ~= odd then
			if self:fightRand() < odd.status.val then
				tarSoldier:addOddCount(fightOdd)
				local bomb_hurt = math.modf(hurt_all * (odd.status.objid/10000))
				local fightOrderTarget = FightOrderTarget:new(ackSoldier)
				table.insert(fightLog.orderTargetList, fightOrderTarget )
				fightOrderTarget.guid = ackSoldier.guid
				fightOrderTarget.fight_result = const.kFightDicHP
				local oddTriggered = FightOddTriggered:new(ackSoldier.guid, fightOdd.id)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
				fightOrderTarget.fight_value = ackSoldier:reduceHP(tarSoldier, bomb_hurt,fightLog.orderTargetList, fightOrderTarget, fightOdd.id)
				if ackSoldier:checkEnd() then
					ackSoldier:oddDeadEffect(fightLog.orderTargetList)
					return
				end	
			end
		end
	end	
	
	--偷袭 不会造成爆炸和反震效果

	--爆炸 受攻击时，对敌方全体造成N%的气血上限伤害
	local fightOddBomb = tarSoldier:findFightOdd( const.kFightOddBomb )
	local fightOddSneak = ackSoldier:findFightOdd( const.kFightOddSneak )
	if nil ~= fightOddBomb and nil == fightOddSneak then
		local odd = fightOddBomb:findOdd()
		if nil ~= odd then
			local tarS = theFight:getTargetSoldier(tarSoldier,odd)
			if nil ~=  tarS then
				local fightOrderTarget = FightOrderTarget:new(tarSoldier)
				local oddTriggered = FightOddTriggered:new(tarSoldier.guid, fightOddBomb.id,tarS)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
				table.insert(fightLog.orderTargetList, fightOrderTarget )
				for _, soldier in pairs(tarS) do
					local fightOrderTarget = FightOrderTarget:new(soldier)
					fightOrderTarget.fight_result = const.kFightDicHP
					local hurt = math.modf(math.max(tarSoldier.last_ext_able.physical_ack, tarSoldier.last_ext_able.magic_ack) * (odd.status.objid/10000))
					fightOrderTarget.fight_value = soldier:reduceHP(tarSoldier, hurt, fightLog.orderTargetList, fightOrderTarget, fightOddBomb.id)
					fightOrderTarget.hp = soldier.hp
					table.insert(fightLog.orderTargetList, fightOrderTarget )
					if soldier:checkEnd() then
						soldier:oddDeadEffect(fightLog.orderTargetList)
					end
				end
			end
		end
	end
	
	--拥有该状态时，杀死敌人额外获得固定怒气
	local fightOddKillRageAdd = ackSoldier:findFightOdd( const.kFightOddKillRageAdd )
	if nil ~= fightOddKillRageAdd and tarSoldier:checkEnd() then
		local fightOrderTarget = FightOrderTarget:new(ackSoldier)
		ackSoldier:addRage(fightOddKillRageAdd.status_value)
		fightOrderTarget.rage = ackSoldier.rage
		table.insert(fightLog.orderTargetList, fightOrderTarget )
	end
	
	--自爆 死亡时自爆，对敌方造成一定伤害

	local fightOddBombSelf = tarSoldier:findFightOdd( const.kFightOddBombSelf )
	if nil ~= fightOddBombSelf and tarSoldier:checkEnd() then
		local fightOrderTarget = FightOrderTarget:new(ackSoldier)
		fightOrderTarget.fight_result = const.kFightDicHP
		local hurt = math.modf(math.max(tarSoldier.last_ext_able.physical_ack, tarSoldier.last_ext_able.magic_ack) * (fightOddBombSelf.status_value/10000))
		fightOrderTarget.fight_value = ackSoldier:reduceHP(tarSoldier, hurt, fightLog.orderTargetList, fightOrderTarget, fightOddBombSelf.id)
		fightOrderTarget.hp = ackSoldier.hp
		local oddTriggered = FightOddTriggered:new(tarSoldier.guid, fightOddBombSelf.id,{ackSoldier})
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
		table.insert(fightLog.orderTargetList, fightOrderTarget )
	end
	
	--触发了偷袭

	if nil ~= fightOddBomb and nil ~= fightOddSneak then
		local oddTriggered = FightOddTriggered:new(tarSoldier.guid, fightOddSneak.id)
		table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
	end
	
	--闪电链BUFF特殊处理
	local fightOddLight = ackSoldier:findFightOdd( const.kFightOddLightning )
	if nil ~= fightOddLight then
		fightOddLight.now_count = fightOddLight.now_count + 1
	end
	
	--追击 杀死敌人时，随机普通攻击下一个敌人，但伤害降低

	local fightOddPursuit = ackSoldier:findFightOdd(const.kFightOddPursuit)
	if nil ~= fightOddPursuit and tarSoldier:checkEnd() and 1 == skill.target_range_count then
		ackSoldier.state_list[const.kFightOddPursuit] = const.kFightOddPursuit
	end
	
	--超级追击，拥有该buff时，杀死敌人时，怒气+100使用大招攻击另外一人，但是伤害降低N%
	local fightOddSuperPursuit = ackSoldier:findFightOdd(const.kFightOddSuperPursuit)
	if nil ~= fightOddSuperPursuit and tarSoldier:checkEnd() then
		ackSoldier.state_list[const.kFightOddSuperPursuit] = const.kFightOddSuperPursuit
		local odd = fightOddSuperPursuit:findOdd()
		if nil ~= odd then
			ackSoldier:addRage(odd.status.val)
			local fightOrderTarget = FightOrderTarget:new(ackSoldier)
			table.insert(fightLog.orderTargetList, fightOrderTarget )
		end
	end
	
	--超拥有该buff时，当攻击者攻击这个buff拥有者时，会给攻击的人填加N-M点怒气
	local fightOddDefAddRage = tarSoldier:findFightOdd(const.kFightOddDefAddRage)
	if nil ~= fightOddDefAddRage then
		local odd = fightOddDefAddRage:findOdd()
		if nil ~= odd and nil ~= odd.status.val then
			local add_rage = odd.status.objid + self:fightRand(odd.status.val)
			ackSoldier:addRage(add_rage)
			local fightOrderTarget = FightOrderTarget:new(ackSoldier)
			table.insert(fightLog.orderTargetList, fightOrderTarget )
		end
	end
	
	--假死 死亡后不消失，死亡后第4回合一定几率复活并回复x%气血
	--识破 对装备“假死”天赋的英雄造成的伤害提高x%，并在将其杀死时直接清除出场，不能复活

	local fightOddDeadFalse = tarSoldier:findFightOdd( const.kFightOddDeadFalse )
	local fightOddPenetrate = ackSoldier:findFightOdd( const.kFightOddPenetrate )
	if nil ~= fightOddDeadFalse and nil == fightOddPenetrate and tarSoldier:checkEnd() then
		local odd = fightOddDeadFalse:findOdd()
		if nil ~= odd then
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
			if nil ~= addOdd then
				tarSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
			end
		end
	end
	
	--如果杀了一个人那就加100点图腾值

	--[[
	if tarSoldier:checkEnd() then
		ackSoldier:addTotemValue(100)
		local fightOrderTarget = FightOrderTarget:new(ackSoldier)
		fightOrderTarget.fight_attr = const.kFightAttrTotemValueShow
		fightOrderTarget.fight_value = 100
		table.insert(fightLog.orderTargetList, fightOrderTarget )
	end
	]]--
	
	local fightOddKillBuffAdd = ackSoldier:findFightOdd( const.kFightOddKillBuffAdd )
	if nil ~= fightOddKillBuffAdd and  tarSoldier:checkEnd() then
		local odd = fightOddKillBuffAdd:findOdd()
		if nil ~= odd then
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
			if nil ~= addOdd then
				if odd.target_type_special == const.kFightTargetOpposite then
					tarSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				elseif odd.target_type_special == const.kFightTargetSelf then
					ackSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				else
					local tarS = theFight:getTargetSoldier(ackSoldier,odd)
					if nil ~= tarS then
						for _, soldier in pairs(tarS) do
							soldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
						end
					end
				end
			end
		end
	end
	
	--如果需要反击 就反击

	if isAntiAttack and tarSoldier:canAttack() and not tarSoldier:checkEnd() and nil == ackSoldier.state_list[const.kFightOddAntiAttack] then
		local odd = antiAttackOdd:findOdd()
		if nil ~= odd then
			local addOdd = findOdd(odd.addodd.first,odd.addodd.second)
			if nil ~= addOdd then
				ackSoldier:setFightOdd(addOdd, theFight.round, tarSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
			end
			local fightOrder = { order_id = tarSoldier.skill_list[1].skill_id, order_level = tarSoldier.skill_list[1].skill_level }
			tarSoldier:setOrder( fightOrder )
			tarSoldier.state_list[const.kFightOddAntiAttack] = const.kFightOddAntiAttack
			self:startAttack( tarSoldier, ackSoldier, fightLog )
			tarSoldier.state_list[const.kFightOddAntiAttack] = nil
		end
	end
end

function CFight:startRecover(ackSoldier, tarSoldier, fightLog )
	LogMgr.log( 'fight', "startRecover")
	local theFight = theFightList[ackSoldier.selfFightId]
	local fightOrderTarget = FightOrderTarget:new(tarSoldier)
	
	local ackAble = ackSoldier.last_ext_able
	local defAble = tarSoldier.last_ext_able
	
	local order = ackSoldier.order
	
	if nil == order then
		return
	end
	local skill = findSkill( order.order_id, order.order_level )
	if nil == skill then
		return
	end
	
	--如果已经是0血了
	if 0 == tarSoldier.hp then
		return
	end
	
	local recover = 0
	tarSoldier:delRage(toMyNumber(skill.def_delrage))
	fightOrderTarget.rage = tarSoldier.rage
	
	--普通攻击对敌方目标上毒的几率提升10%
	local fightOddBuffPercent = ackSoldier:findFightOdd(const.kFightOddBuffPercent)
	--攻击时，对所有敌人造成冰冻的几率提升10%（普通技能与大大招也有10%几率造成冰冻）

	local fightOddBuffPercent2 = ackSoldier:findFightOdd(const.kFightOddBuffPercent2)
	
	for _, fightOdd in pairs( skill.odds ) do
		local odd = findOdd( fightOdd.first, fightOdd.second )
		
		if nil ~= odd and const.kFightTargetOpposite == toMyNumber(odd.target_type_skill) then
			local percent = toMyNumber(odd.percent)
			if 0 == skill.self_costrage and nil ~= fightOddBuffPercent and odd.status.cate == fightOddBuffPercent.status_value then
				local oddBuffPercent = fightOddBuffPercent:findOdd()
				if nil ~= oddBuffPercent then
					percent = percent + oddBuffPercent.status.val
				end
			end
			if nil ~= fightOddBuffPercent2 and odd.status.cate == fightOddBuffPercent2.status_value then
				local oddBuffPercent = fightOddBuffPercent2:findOdd()
				if nil ~= oddBuffPercent then
					percent = percent + oddBuffPercent.status.val
				end
			end
			
			if self:fightRand() < toMyNumber(odd.percent) then
				tarSoldier:setFightOdd( odd, self.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
			end
		end
	end
	
	if 0 ~= #fightOrderTarget.odd_list then
		table.insert(fightLog.orderTargetList, fightOrderTarget)
	end
	
	--使用某个id的主动技能时额外触发多一个buff(这个buff可以加个自己也可以加给敌方)
	local fightOddSkill = ackSoldier:findFightOdd(const.kFightOddSkillBuff)
	if nil ~= fightOddSkill and fightOddSkill.status_value == skill.id then
		local odd = fightOddSkill:findOdd()
		if nil ~= odd then
			if self:fightRand() < toMyNumber(odd.percent) then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
				if nil ~= addOdd then
					tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
	end
	
	--使用某个id的主动技能时额外触发多一个buff(这个buff可以加个自己也可以加给敌方)
	local fightOddSkillList = ackSoldier:findFightOddList(const.kFightOddSkillBuffSelf)
	for _, fightOddSkill in pairs( fightOddSkillList ) do
		if nil ~= fightOddSkill and fightOddSkill.status_value == skill.id then
			local odd = fightOddSkill:findOdd()
			if nil ~= odd and self:fightRand() < toMyNumber(odd.percent) then
				local addOdd = findOdd( odd.addodd.first, odd.addodd.second )
				if nil ~= addOdd then
					if odd.target_type_special == const.kFightTargetOpposite then
						tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
					elseif odd.target_type_special == const.kFightTargetSelf then
						ackSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
					else
						local tarSoldier = theFight:getTargetSoldier(ackSoldier,odd)
						if nil ~= tarSoldier then
							for _, soldier in pairs(tarSoldier) do
								soldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
							end
						end
					end
				end
			end
		end
	end
	
	--当友方单位受到你的治疗时，有5%几率被施加一个恢复术，每回合恢复少量血量
	local fightOddRecoverBuff = ackSoldier:findFightOdd(const.kFightOddRecoverBuff)
	if nil ~= fightOddRecoverBuff and  self:fightRand() < fightOddRecoverBuff.status_value then
		local odd = fightOddRecoverBuff:findOdd()
		if nil ~= odd then
			local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
			if nil ~= addOdd then
				if const.kFightTargetOpposite == odd.status.val then
					tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				else
					ackSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
				end
			end
		end
	end
	
	for fight_might, mightRange in pairs(skill.mights) do
		if nil ~= mightRange then
			local might = mightRange.first
			local fightOrderTarget = FightOrderTarget:new(tarSoldier)
			fightOrderTarget.fight_might = fight_might
			table.insert(fightLog.orderTargetList, fightOrderTarget )
			recover = getRecoverValue(ackSoldier,tarSoldier,might)
			
			local critper = ackSoldier.last_ext_able.recover_critper - tarSoldier.last_ext_able.recover_critper_def
			
			if  self:fightRand() < critper then
				recover = math.modf(recover * 1.5)
				fightOrderTarget.fight_type = const.kFightCrit
				
				--暴击时增加BUFF
				local fightOdd = ackSoldier:findFightOdd(const.kFightOddRecoverCirtBuff)
				if nil ~= fightOdd then
					local odd = fightOdd:findOdd()
					if nil ~= odd then
						ackSoldier:addOddCount(fightOdd)
						local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
						if nil ~= addOdd then
							if odd.target_type_special == const.kFightTargetOpposite then
								tarSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
							elseif odd.target_type_special == const.kFightTargetSelf then
								ackSoldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
							else
								local tarSoldier = theFight:getTargetSoldier(ackSoldier,odd)
								if nil ~= tarSoldier then
									for _, soldier in pairs(tarSoldier) do
										soldier:setFightOdd(addOdd, theFight.round, ackSoldier.guid, fightLog.orderTargetList, fightOrderTarget )
									end
								end
							end
						end
					end
				end
			end
			
			--计算伤害倍数
			local multi = getMultiRecoverHurt(ackSoldier, tarSoldier)
			
			if recover < 0 then
				recover = 0
			else
				recover = math.modf(recover*(multi/10000))
			end
			
			--假死就不能回血
			local fightOddDeadFalse = tarSoldier:findFightOdd(const.kFightOddDeadFalse)
			if nil ~= fightOddDeadFalse then
				recover = 0
			end
			
			LogMgr.log( 'fight',  "round:" ..  self.round .. ",ack_guid(" .. ackSoldier.name .. "):" .. ackSoldier.guid .. ",def_guid(" .. tarSoldier.name .. "):" .. tarSoldier.guid .. ",useskill(" .. skill.name .. "):" .. skill.id )
			tarSoldier:addHP(recover,fightLog.orderTargetList)
			fightOrderTarget.fight_result = const.kFightAddHP
			fightOrderTarget.fight_value = recover
			fightOrderTarget.hp = tarSoldier.hp
		end
	end
	
	--扣血
	if 0 ~= skill.buckle_blood then
		local fightOrderTarget = FightOrderTarget:new(ackSoldier)
		fightOrderTarget.fight_result = const.kFightDicHP
		local hurt = math.modf(math.max(ackSoldier.last_ext_able.physical_ack,ackSoldier.last_ext_able.magic_ack) * (skill.buckle_blood/10000))
		if 0 ~= ackSoldier.hp and hurt > ackSoldier.hp then
			hurt = ackSoldier.hp - 1
		end
		if 0 ~= hurt then
			fightOrderTarget.fight_value = ackSoldier:reduceHP(ackSoldier, hurt, fightLog.orderTargetList, fightOrderTarget, 0)
			fightOrderTarget.hp = ackSoldier.hp
			table.insert(fightLog.orderTargetList, fightOrderTarget )
		end
	end
end

function CFight:checkLeftEnd()
	for _, user in pairs(self.userList) do
		if const.kFightLeft == user.camp then
			if not user:checkEnd() then
				return false
			end
		end
	end
	return true
end

function CFight:checkRightEnd()
	for _, user in pairs(self.userList) do
		if const.kFightRight == user.camp then
			if not user:checkEnd() then
				return false
			end
		end
	end
	return true
end

function CFight:findSoldier( guid )
	for _, user in pairs(self.userList) do
		for _, soldier in pairs( user.soldier_list ) do
			if soldier.guid == guid then
				return soldier
			end
		end
	end
	return
end

--战斗结束判断
function CFight:checkEnd()
	if self:checkLeftEnd() or self:checkRightEnd() then
		return true
	end
	
	return false
end


function CFight:getWinCamp()
	if self:checkLeftEnd() then
		return const.kFightRight
	elseif self:checkRightEnd() then
		return const.kFightLeft
	end
	return const.kFightRight;
end

function CFight:getRound()
	return self.round
end

--当前回合战斗结束判断
function CFight:checkRoundEnd()
	local leftEnd = true
	local rightEnd = true
	
	for _,soldier in pairs(self.soldierList) do
		if not soldier:checkEnd() then
			if soldier:getCamp() == const.kFightLeft then
				leftEnd = false
			else
				rightEnd = false
			end
		end
	end
	return leftEnd or rightEnd
end

--BUFF效果处理
function CFight:oddEffect()
	local fightLog = FightLog:new(self.round)
	--删除过期的BUFF
	for _,soldier in pairs(self.soldierList) do
		--LogMgr.log('fight', soldier.name )
		--LogMgr.log('fight', debug.dump(soldier.odd_list))
		--LogMgr.log('fight', "size" .. #soldier.odd_list)
		for i = #soldier.odd_list, 1, -1 do
			local fightOrderTarget = FightOrderTarget:new(soldier)
			local fightOdd = soldier.odd_list[i]
			if nil == fightOdd then
				table.remove(soldier.odd_list,i)
			else
				local odd = fightOdd:findOdd()
				if nil == odd then
					table.remove(soldier.odd_list,i)
				else
					if soldier:checkDelOdd( self.round, fightOdd ) then
						soldier:delFightOdd(fightOdd,fightLog.orderTargetList,fightOrderTarget)
						table.insert(fightLog.orderTargetList, fightOrderTarget)
					elseif soldier:checkOdd( self.round, fightOdd ) then
						local fightOddSet = FightOddSet:new()
						fightOddSet.guid = soldier.guid
						fightOddSet.set_type = const.kObjectUpdate
						fightOddSet.fightOdd = copyTab(fightOdd)
						table.insert(fightOrderTarget.odd_list,fightOddSet)
					end
				end
			end
		end
		--LogMgr.log('fight', debug.dump(soldier.odd_list))
	end
	
	--判断是否需要清除

	for _,soldier in pairs(self.soldierList) do
		local fightOdd = soldier:findFightOdd(const.kFightOddClearOdd)
		if nil ~= fightOdd then
			local odd = fightOdd:findOdd()
			if nil ~= odd then
				local fightOrderTarget = FightOrderTarget:new(soldier)
				local tar_list = {}
				for i = #soldier.odd_list, 1, -1 do
					local tarOdd = soldier.odd_list[i]			
					local o2 = tarOdd:findOdd()
					if nil ~= o2 and odd.status.val == o2.attr and self:fightRand() < odd.status.objid then
						soldier:delFightOdd(tarOdd,fightLog.orderTargetList,fightOrderTarget)
						table.insert(tar_list, soldier)
					end
				end
				local oddTriggered = FightOddTriggered:new(soldier.guid, fightOdd.id, tar_list)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
				if #fightOrderTarget.odd_list > 0 then
					table.insert(fightLog.orderTargetList, fightOrderTarget)
				end
			end
		end
	end
	
	--BUFF触发
	for _,soldier in pairs(self.soldierList) do
		local temp = {}
		for i = 1, #soldier.odd_list do
			local fightOdd = soldier.odd_list[i] 
			if nil ~= fightOdd then
				table.insert(temp, fightOdd)
			end
		end
	    for i = 1, #temp do
            local fightOddTemp = temp[i]
			for j = 1, #soldier.odd_list do
				local fightOdd = soldier.odd_list[j]
				if nil ~= fightOdd and fightOdd.id == fightOddTemp.id and fightOdd.level == fightOddTemp.level then
					if soldier:checkOdd( self.round, fightOdd ) then
						soldier:oddEffect(fightOdd, fightLog.orderTargetList)
					end
				end
			end
		end
	end
	return fightLog
end

--设置技能

function CFight:setAttackList()
	self.soldierAttackListIndex = 0
	self.disillusionIndex = 0
	self.soldierAttackList = {}
	for _, soldier in pairs(self.soldierList) do
		local fightOddDeadFighting = soldier:findFightOdd(const.kFightOddDeadFighting)
		if (not soldier:checkEnd() or nil ~= fightOddDeadFighting) and soldier.attr ~= const.kAttrTotem then
			table.insert(self.soldierAttackList, soldier)
		end
		if soldier.attr == const.kAttrTotem then
			table.insert(self.soldierAttackList, soldier)
		end
	end
end


function CFight:getTarUser(soldier, target_type)
	local tarCamp = const.kFightLeft;
	
	if (soldier:getCamp() == const.kFightLeft and target_type == const.kFightTargetOpposite) or (soldier:getCamp() == const.kFightRight and target_type == const.kFightTargetSelf) then
		tarCamp = const.kFightRight;
	end
	for v, user in pairs(self.userList) do
		if not user:checkEnd() and tarCamp == user.camp then
			return user
		end
	end
	return nil
end

function CFight:getCanUseTotem()
	local soldierList = {}
	for _, soldier in ipairs(self.soldierAttackList) do
		if soldier.attr ~= const.kAttrTotem then
			break
		end
		
		local theUser = self:findUser(soldier.selfUserGuid)
		if soldier:checkTotemSkill() and 0 ~= toMyNumber(theUser.isAutoFight) then
			table.insert(soldierList,soldier)
		end
	end
	return soldierList
end

function CFight:DisillusionNext()
	if self.soldierAttackListIndex + 1 > #self.soldierAttackList then
		return false
	end
	
	local soldier = self.soldierAttackList[self.soldierAttackListIndex + 1]
	local fightOddDisillusion = soldier:findFightOdd(const.kFightOddDisillusion)
	if nil ~= fightOddDisillusion then
		return true
	end
	
	return false
end

--获取释放技能的英雄
function CFight:getTargetSoldier( soldier, skill, fightOrderTarget )

	local target_type = skill.target_type
	local fightOddConfusion = soldier:findFightOdd(const.kFightOddConfusion)
	if nil ~= fightOddConfusion and 0 == skill.self_costrage then
		if target_type == const.kFightTargetOpposite then
			target_type = const.kFightTargetSelf
		elseif target_type == const.kFightTargetSelf then
			target_type = const.kFightTargetOpposite
		end
	end
	
	local tarUser = self:getTarUser( soldier, target_type )
	if nil == tarUser then
		LogMgr.log( 'fight', "++++++++++++++++not found tarUser, skill.target_type:"..skill.target_type)
		return
	end
	local liveSoldier = tarUser:getLiveSoldier()
	
	local targetSoldier = tarUser:getTargetSoldier( liveSoldier, soldier, toMyNumber(skill.target_range_cond), toMyNumber(skill.target_range_count), toMyNumber(skill.target_type), toMyNumber(skill.type) )
	return targetSoldier
end

function CFight:useSkill( soldier )
	soldier:delPlayFlag()
	
	if not soldier:canAttack() then
		return nil
	end
	
	local fightLog = FightLog:new(self.round)
	
	local order = copyTab(soldier.order)
	
	if nil == order then
		return
	end
	local skill = findSkill( order.order_id, order.order_level )
	if nil == skill then
		LogMgr.log( 'fight', "useSkill++++++++++++not found skill, order.order_id:"..order.order_id..", order.order_level:"..order.order_level)
		return nil
	end
	LogMgr.log( 'fight',  "soldier(" .. soldier.name .. "):" .. soldier.guid .. " useSkill(" .. skill.name .. "):" .. skill.id )
	
	fightLog.order = order
	
	--table.insert(self.orderList,order)
	local fightOrderTarget = FightOrderTarget:new(soldier)
	local tarSoldierList = self:getTargetSoldier( soldier, skill, fightOrderTarget )
	if nil == tarSoldierList or 0 == #tarSoldierList then
		LogMgr.log( 'fight', "+++++++++++not found target soldiers, guid:"..soldier.guid..", order.order_id:"..order.order_id..", order.order_level:"..order.order_level)
		return nil
	end
	
	
	--使用图腾那么图腾出手的序列就要往后移
	if soldier.attr == const.kAttrTotem then
		local cost_value = skill.self_costtotem
		--发动图腾技能消耗能量减少

		local fightOddkTotemSkillCost = soldier:findFightOdd(const.kFightOddTotemSkillCost)
		if nil ~= fightOddkTotemSkillCost then
			cost_value = math.modf(cost_value * ( 1 - fightOddkTotemSkillCost.status_value/10000 ))
		end
		if cost_value > 0 then
			soldier:delTotemValue(cost_value)
		end
	end
	
	table.insert(fightLog.orderTargetList, fightOrderTarget)
	
	--发动图腾技能时，一定几率减少敌方图腾能量

	local fightOddTotemSkillDel = soldier:findFightOdd(const.kFightOddTotemSkillDel)
	if nil ~= fightOddTotemSkillDel then
		local odd = fightOddTotemSkillDel:findOdd()
		if nil ~= odd and self:fightRand() < odd.status.objid then
			for _, tarSoldier in pairs(self.soldierList) do
				if soldier:getCamp() ~= tarSoldier:getCamp() then
					local fightOrderTarget = FightOrderTarget:new(tarSoldier)
					tarSoldier:delTotemValue(odd.status.val)
					fightOrderTarget.totem_value = tarSoldier:getTotemValue()
					table.insert(fightLog.orderTargetList, fightOrderTarget)
					break
				end
			end
		end
	end
	
	--50%几率消耗自身4%血量，提升25点怒

	local fightOddHpRage = soldier:findFightOdd(const.kFightOddHpRage)
	if nil ~= fightOddHpRage and self:fightRand() < 5000 then
		local odd = fightOddHpRage:findOdd()
		if nil ~= odd then
			local hurt = soldier.last_ext_able.hp * (odd.status.objid/10000)
			if hurt < soldier.hp then
				local fightOrderTarget = FightOrderTarget:new(soldier)
				fightOrderTarget.fight_result = const.kFightDicHP
				fightOrderTarget.fight_value = soldier:reduceHP(self, hurt, fightLog.orderTargetList, fightOrderTarget, fightOddHpRage.id )
				fightOrderTarget.hp = soldier.hp
				soldier:addRage(odd.status.objid)
				table.insert(fightLog.orderTargetList, fightOrderTarget)
			end
		end
	end
	
	--攻击有100%的几率提升5-20点怒气，并且释放大招之后，保留15点怒气
	local fightOddRageAddSave = soldier:findFightOdd(const.kFightOddRageAddSave)
	if nil ~= fightOddRageAddSave and self:fightRand() < fightOddRageAddSave.status_value then
		local rage = self:fightRand(16) + 5
		soldier:addRage(rage)
	end
	
	local cost_rage = skill.self_costrage
	local fightOddCleverRoot = soldier:findFightOdd(const.kFightOddCleverRoot)
	if nil ~= fightOddCleverRoot and cost_rage > 0 then
		local odd = fightOddCleverRoot:findOdd()
		if nil ~= odd and self:fightRand() < 10000 then
			cost_rage = math.modf(cost_rage*((10000-fightOddCleverRoot.status_value)/10000))
		end
	end
	
	soldier:delRage(cost_rage)
	soldier:addRage(toMyNumber(skill.self_addrage))
	--攻击有100%的几率提升5-20点怒气，并且释放大招之后，保留15点怒气
	if nil ~= fightOddRageAddSave then
		local odd = fightOddRageAddSave:findOdd()
		if nil ~= odd then
			soldier:addRage(odd.status.val)
		end
	end

	--隐身消失
	local fightOddHide = soldier:findFightOdd(const.kFightOddHide)
	local fightOddNightDance = soldier:findFightOdd(const.kFightOddNightDance)
	if nil ~= fightOddHide and nil == fightOddNightDance then
		local fightOrderTarget = FightOrderTarget:new(soldier)
		soldier:delFightOdd(fightOddHide,fightLog.orderTargetList, fightOrderTarget )
		table.insert(fightLog.orderTargetList, fightOrderTarget)
	end
	if nil ~= fightOddHide then
		soldier.state_list[const.kFightOddHide] = const.kFightOddHide
	end	
	
	--使用大招之后会剩余25点怒气
	local fightOddRageSave = soldier:findFightOdd(const.kFightOddRageSave)
	if 0 ~= skill.self_costrage and nil ~= fightOddRageSave then
	   soldier:addRage(fightOddRageSave.status_value)
	end
	
	fightOrderTarget.rage = soldier.rage
	soldier:addTotemValue(skill.self_addtotem)
	fightOrderTarget.totem_value = soldier:getTotemValue()
	
	soldier.lastOrderRound[soldier.order.order_id] = self.round
	
	--如果被打断了那就直接返回
	local fightOdd = soldier:findFightOdd(const.kFightOddBreak)
	if nil ~= fightOdd then
		return fightLog
	end
	
	--觉醒状态特殊处理

	if soldier.state_list[const.kFightOddDisillusion] == const.kFightOddDisillusion then
		local fightOdd = soldier:findFightOdd(const.kFightOddDisillusion)
		if nil ~= fightOdd then
			soldier:addOddCount(fightOdd)
			local podd = fightOdd:findOdd()
			if nil ~= podd and podd.limit_count == fightOdd.use_count then
				local fightOddSet = FightOddSet:new()
				fightOddSet.guid = soldier.guid
				fightOddSet.set_type = const.kObjectDel
				fightOddSet.fightOdd = copyTab(fightOdd)
				table.insert(fightOrderTarget.odd_list,fightOddSet)
			end
		end
	end
	
	--在释放普通主动技能时，每一层真气会回复你血量3%
	local fightOddTrueGas = soldier:findFightOdd(const.kFightOddTrueGas)
	local fightOddTrueGasRecover = soldier:findFightOdd(const.kFightOddTrueGasRecover)
	if nil ~= fightOddTrueGas and nil ~= fightOddTrueGasRecover then
		local fightOrderTarget = FightOrderTarget:new(soldier)
		fightOrderTarget.fight_result = const.kFightAddHP
		fightOrderTarget.odd_id =  fightOddTrueGasRecover.id
        local hp = math.modf(soldier.last_ext_able.hp * (fightOddTrueGasRecover.status_value/10000) * fightOddTrueGas.now_count) 
		fightOrderTarget.fight_value = hp
		soldier:addHP( hp )
		fightOrderTarget.hp = soldier.hp
		table.insert(fightLog.orderTargetList, fightOrderTarget)
	end
	
	if skill.id == 99999 then
		LogMgr.log( 'fight', "special skill")
	else	
		--如果ODD是给自己放的那么在动手之前就添加ODD
		for _, fightOdd in pairs( skill.odds ) do
			local odd = findOdd( fightOdd.first, fightOdd.second )
			
			if nil ~= odd and const.kFightTargetSelf == toMyNumber(odd.target_type_skill) and self:fightRand() < odd.percent then
				soldier:setFightOdd( odd, self.round, soldier.guid ,fightLog.orderTargetList, fightOrderTarget)
			end
		end
		
		--在潜行状态下，攻击时额外增加N的点怒气
		local fightOddHide = soldier:findFightOdd(const.kFightOddHide)
		local fightOddHideRage = soldier:findFightOdd(const.kFightOddHideRage)
		if nil ~= fightOddHideRage then
			if soldier.state_list[const.kFightOddHide] == const.kFightOddHide or nil ~= fightOddHide then
				soldier:addRage(fightOddHideRage.status_value)
				local fightOrderTarget = FightOrderTarget:new(soldier)
				table.insert(fightLog.orderTargetList, fightOrderTarget)
			end
		end
		
		--如果是图腾那么会给某些人添加觉醒
		if soldier.attr == const.kAttrTotem then
			local create_list = soldier:findFightOddList(const.kFightOddDisillusionCreate)
			local disillusion_list = {}
			for _, tarOdd in pairs(create_list) do
				local odd = tarOdd:findOdd()
				if nil ~= odd then
					if nil == disillusion_list[odd.target_range_cond] then
						disillusion_list[odd.target_range_cond] = {}
					end
					if nil == disillusion_list[odd.target_range_cond][odd.target_range_count] then
						local temp_odd = copyTab(tarOdd)
                        FightOdd:newtable(temp_odd)
                        temp_odd.podd = tarOdd.podd
						disillusion_list[odd.target_range_cond][odd.target_range_count] = temp_odd
					else
						disillusion_list[odd.target_range_cond][odd.target_range_count].status_value = disillusion_list[odd.target_range_cond][odd.target_range_count].status_value + tarOdd.status_value
					end
				end
			end
			
			local tarSoldierList = {}
			for target_range_cond, f1 in pairs(disillusion_list) do
				for target_range_count, fightOdd in pairs(f1) do
					local odd = fightOdd:findOdd()
					local tarSoldier = self:getTargetSoldier(soldier,odd)
					if nil == tarSoldier then
						return
					end
					
					for _, tarS in pairs(tarSoldier) do
						local percent = fightOdd.status_value
						local fightOddDisillusionDouble = tarS:findFightOdd(const.kFightOddDisillusionDouble)
						if nil ~= fightOddDisillusionDouble then
							percent = percent * (fightOddDisillusionDouble.status_value/10000)
						end
						local fightOddDisillusionPer = tarS:findFightOdd(const.kFightOddDisillusionPer)
						if nil ~= fightOddDisillusionPer and target_range_cond == const.kFightSkillEquip and  target_range_count == fightOddDisillusionPer.status_value then
							tarS:addOddCount(fightOddDisillusionPer)
							local odd = fightOddDisillusionPer:findOdd()
							percent = percent + odd.status.val
						end
						if self:fightRand() < percent then
							local fightOddSilent = tarS:findFightOdd( const.kFightOddSilent )
							if tarS:canAttack() and nil == fightOddSilent then
								local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
								if nil ~= addOdd then
									tarS:setFightOdd(addOdd, self.round, soldier.guid, fightLog.orderTargetList, fightOrderTarget )
								end
								
								table.insert(tarSoldierList, tarS)
							else
								local fightOrderTarget = FightOrderTarget:new(tarS)
								fightOrderTarget.fight_attr = const.kFightAttrNoDisillusion
								table.insert(fightLog.orderTargetList, fightOrderTarget)
							end
						end
					end
				end
			end
			--按照速度重新排列tarSoldierList
			--由于table.sort的不稳定性 所以不用table.sort得自己写一个sort
			local length = #tarSoldierList
			if length >= 2 then
				for i = 1, length-1 do
					for j = i+1, length do
						if not sortFunC(tarSoldierList[i], tarSoldierList[j]) then
							local temp_soldier = tarSoldierList[i]
							tarSoldierList[i] = tarSoldierList[j]
							tarSoldierList[j] = temp_soldier
						end
					end
				end
			end
			
			--插入当前的list
			if #tarSoldierList > 0 then
				if self.disillusionIndex < self.soldierAttackListIndex then
					self.disillusionIndex = self.soldierAttackListIndex
				end
				for i = 1, #tarSoldierList do
					self.disillusionIndex = self.disillusionIndex + 1
					table.insert(self.soldierAttackList, self.disillusionIndex , tarSoldierList[i])
				end
			end
		end
		
		--蛇棒，插在自己身后，持续M回合，每回合在使用者攻击时，蛇棒会对随机一个敌人造成使用者自身攻击（物攻和法攻最大者)N%的伤害

		local fightOddSnakeStick = soldier:findFightOdd(const.kFightOddSnakeStick)
		if nil ~= fightOddSnakeStick then
			local odd = fightOddSnakeStick:findOdd()
			if nil ~= odd then
				local tarSoldierList = self:getTargetSoldier( soldier, odd )
				for _, tarS in pairs(tarSoldierList) do
					local fightOrderTarget = FightOrderTarget:new(tarS)
					table.insert(fightLog.orderTargetList, fightOrderTarget)
					local addOdd = findOdd( odd.addodd.first, odd.addodd.second)
					fightOrderTarget.fight_result = const.kFightDicHP
					local hurt = math.modf(math.max(soldier.last_ext_able.physical_ack, soldier.last_ext_able.magic_ack) * (fightOddSnakeStick.status_value/10000))
					fightOrderTarget.fight_value = tarS:reduceHP(soldier, hurt, fightLog.orderTargetList, fightOrderTarget, fightOddSnakeStick.id )
					fightOrderTarget.hp = tarS.hp
					if tarS:checkEnd() then
						tarS:oddDeadEffect(fightLog.orderTargetList)
					end
				end
			end
		end
		
		--风怒处理
        local fightOddDoubleHit = soldier:findFightOdd(const.kFightOddDoubleHit)
		if nil ~= fightOddDoubleHit 
		and soldier.state_list[const.kFightOddDoubleHit] == const.kFightOddDoubleHit 
		and nil == soldier.state_list[const.kFightOddPursuit]
		and nil == soldier.state_list[const.kFightOddSuperPursuit]
		and nil == soldier.state_list[const.kFightOddPhysicalDoubleHit]
		and nil == soldier.state_list[const.kFightOddMagicDoubleHit] then
			local fightOddDoubleHit = soldier:findFightOdd(const.kFightOddDoubleHit)
			if nil ~= fightOddDoubleHit and 0 == skill.disillusion then
				fightOddDoubleHit.DoubleHit_Count = fightOddDoubleHit.DoubleHit_Count + 1
				if fightOddDoubleHit.DoubleHit_Count >= 1 then
					local oddTriggered = FightOddTriggered:new(soldier.guid, fightOddDoubleHit.id)
					table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
				end
			end
		end
		
		--追击
		if soldier.state_list[const.kFightOddPursuit] == const.kFightOddPursuit then
			local fightOdd = soldier:findFightOdd(const.kFightOddPursuit)
			if nil ~= fightOdd then
				local oddTriggered = FightOddTriggered:new(soldier.guid, fightOdd.id)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			end
		end
		
		--追击
		if soldier.state_list[const.kFightOddSuperPursuit] == const.kFightOddSuperPursuit then
			local fightOdd = soldier:findFightOdd(const.kFightOddSuperPursuit)
			if nil ~= fightOdd then
				local oddTriggered = FightOddTriggered:new(soldier.guid, fightOdd.id)
				table.insert(fightOrderTarget.odd_list_triggered,oddTriggered)
			end
		end
						
		if const.kFightPhysical == toMyNumber(skill.type) or const.kFightMagic == toMyNumber(skill.type) then
			for _, tarSoldier in pairs(tarSoldierList) do
				self:startAttack(soldier, tarSoldier, fightLog)
			end
		elseif const.kFightHPRecoverTotem == toMyNumber(skill.type) or const.kFightAttackHp == toMyNumber(skill.type) or const.kFightHPRecover == toMyNumber(skill.type) or const.kFightBuff == toMyNumber(skill.type) then
			for _, tarSoldier in pairs(tarSoldierList) do
				self:startRecover(soldier, tarSoldier, fightLog)
			end
		end
		
		soldier.state_list[const.kFightOddHide] = nil
	end
	
	return fightLog
end

function CFight:delSoldierFlag()
	for _, user in pairs(self.userList) do
		for i = #user.soldier_list, 1, -1 do
			--重新清除状态

			user.soldier_list[i].state_list = {}
			--删除英雄
			if 0 ~= user.soldier_list[i].delFlag then
				table.remove(user.soldier_list, i )
			end
		end
	end
end

--设置当前回合的英雄

function CFight:setSoldier()
	local left = true
	local right = true
	
	self.soldierList = {}
	for _, user in pairs(self.userList) do
		if not user:checkEnd() then
			if user.camp == const.kFightLeft and left then
				left = false
				for _, soldier in pairs(user.soldier_list) do
					table.insert(self.soldierList, soldier)
				end
			elseif user.camp == const.kFightRight and right then
				right = false
				for _, soldier in pairs(user.soldier_list) do
					table.insert(self.soldierList, soldier)
				end
			end
		end
	end
end

function CFight:getFightMaxRound()
	if const.kFightTypeTrialSurvival == self.fightType or const.kFightTypeTrialStrength == self.fightType 
		or const.kFightTypeTrialAgile == self.fightType or const.kFightTypeTrialIntelligence == self.fightType then
			return 10
	else
		return 15
	end
end

function CFight:autoFight()
	LogMgr.log( 'fight', "autoFight")
	while not self:checkEnd() and self.round <= self:getFightMaxRound() do
		local fightlog = self:roundSkill()
		--LogMgr.log( 'fight', debug.dump(fightlog))
		self:roundSkillSoldier()
	end
	return false
end

function CFight:checkServer()
	LogMgr.log( 'fight', "checkServer")
    --profiler:start(".out")
	local index = 1
	local fightSkill = {order = {guid = 0}}
	while not self:checkEnd() and self.round <= self:getFightMaxRound() do
		if nil == self.checkOrderList[index] then
			return err.kErrFightCheck
		end
		
		--设置自动战斗
		if const.kFightRoundAuto == self.checkOrderList[index].guid then
			self:setAutoFight( self.checkOrderList[index].order_id, self.checkOrderList[index].order_level )
		elseif self.checkOrderList[index].guid ~= fightSkill.order.guid then
			LogMgr.log( 'fight', "client"..self.checkOrderList[index].guid .."server"..fightSkill.order.guid)
			local soldier = self:findSoldier(self.checkOrderList[index].guid)
			if nil == soldier then
				return err.kErrFightCheck
			end
			if soldier.attr ~= const.kAttrTotem then
				return err.kErrFightCheck
			end
			if not soldier:checkTotemSkill() then
				return err.kErrFightCheck
			end
			local fightlog = self:useTotemSkill(soldier)
			fightSkill = self:roundSkillSoldier()
			--LogMgr.log( 'fight', debug.dump(fightlog))
		else
			local fightlog = self:roundSkill()
			--LogMgr.log( 'fight', debug.dump(fightlog))
			fightSkill = self:roundSkillSoldier()
		end
		index = index+1
	end
	
	--检查
    --profiler:stop()

	for _, user1 in pairs(self.userList) do
		for _, s_soldier in pairs(user1.soldier_list) do
			for _, user2 in pairs(self.soldierEndList) do
				for _, c_soldier in pairs(user2.soldier_list) do
					if s_soldier.guid == c_soldier.guid and s_soldier.hp ~= c_soldier.hp then
						return err.kErrFightCheck
					end
				end
			end
		end
	end
	
	return 0
end

function CFight:roundInit()
	LogMgr.log( 'fight', "roundFight,fightguid:" .. self.fight_id )
	self.round = self.round + 1
	
	--local roundData = {}
	local roundLogList = {}
	local order = { guid = 0, order_id = const.kFightRoundInit }
	--每回合开始初始化用
	if self.round > self:getFightMaxRound() then
		table.insert(self.orderList, copyTab(order))
		return roundLogList
	end
	self:updateEndInfoRound()
	
	self:delSoldierFlag()
	self:setSoldier()
	local fightLog = self:oddEffect()
	fightLog.order = order
	table.insert(self.orderList, copyTab(order))
	table.insert(roundLogList, fightLog)
	--如果此时战斗回合结束那么直接返回
	if self:checkRoundEnd() then
		return roundLogList
	end
	
	--需要重新计算人员 因为有可能召唤怪物
	self:setSoldier()
	self:setAttackList()
	
	--由于table.sort的不稳定性 所以不用table.sort得自己写一个sort
	local length = #self.soldierAttackList
	if length >= 2 then
		for i = 1, length-1 do
			for j = i+1, length do
				if not sortFunC(self.soldierAttackList[i], self.soldierAttackList[j]) then
					local temp_soldier = self.soldierAttackList[i]
					self.soldierAttackList[i] = self.soldierAttackList[j]
					self.soldierAttackList[j] = temp_soldier
				end
			end
		end
	end
	
	return roundLogList
end

function CFight:roundSkill()
	
	if 0 == self.round then
		return self:roundInit()
	end
	
	if self:checkRoundEnd() then
		return self:roundInit()
	end
	
	self.soldierAttackListIndex = self.soldierAttackListIndex + 1
	
	if self.soldierAttackListIndex > #self.soldierAttackList then
		return self:roundInit()
	end
	
	local soldier = self.soldierAttackList[self.soldierAttackListIndex]
	--因为图腾觉醒的关系 所以需要重新设置使用的技能

	
	if not soldier:canAttack() then
		LogMgr.log( 'fight', "========something must wrong!!" )
		return {}
	end
	
	soldier:setOrder()
	local order = soldier.order
	
	if nil == order then
		return nil
	end
	local skill = findSkill( order.order_id, order.order_level )
	if nil == skill then
		return nil
	end
	
	table.insert(self.orderList,copyTab(order))
	
	local roundLogList = {}
	local fightLog = self:useSkill( soldier )
	if nil ~= fightLog then
		table.insert( roundLogList, fightLog )
	else
		return {}
	end
	
	--攻击时都会有几率额外触发另外一个主动技能(一回合只会触发一次)
	local fightOddToSkill = soldier:findFightOdd(const.kFightOddAttackToSkill)
	if nil ~= fightOddToSkill and self:fightRand() < fightOddToSkill.status_value then
		local odd = fightOddToSkill:findOdd()
		if nil ~= odd then
			local fightOrder = { order_id = odd.addodd.first,  order_level = odd.addodd.second }
			soldier:setOrder( fightOrder )
			local fightLog = self:useSkill( soldier )
			table.insert( roundLogList, fightLog )
		end
	end
	
	--物理连击 普通攻击时有N%几率触发连击效果，可多攻击目标一次。

	local fightOddDoubleHit = soldier:findFightOdd(const.kFightOddPhysicalDoubleHit)
	if nil ~= fightOddDoubleHit and const.kFightPhysical == toMyNumber(skill.type) and 0 == skill.self_costrage and 0 == skill.disillusion and self:fightRand() < fightOddDoubleHit.status_value then
		local odd = fightOddDoubleHit:findOdd()
		if nil ~= odd then
			soldier.state_list[const.kFightOddPhysicalDoubleHit] = const.kFightOddPhysicalDoubleHit
			local fightOrder = { order_id = soldier.skill_list[1].skill_id, order_level = soldier.skill_list[1].skill_level }
			soldier:setOrder( fightOrder )
			local fightLog = self:useSkill( soldier )
			table.insert( roundLogList, fightLog )
			soldier.state_list[const.kFightOddPhysicalDoubleHit] = nil
		end
	end
	
	--法术连击 普通攻击时有N%几率触发连击效果，可多攻击目标一次。

	local fightOddDoubleHit = soldier:findFightOdd(const.kFightOddMagicDoubleHit)
	if nil ~= fightOddDoubleHit and const.kFightMagic == toMyNumber(skill.type) and 0 == skill.self_costrage and 0 == skill.disillusion and self:fightRand() < fightOddDoubleHit.status_value then
		local odd = fightOddDoubleHit:findOdd()
		if nil ~= odd then
			soldier.state_list[const.kFightOddMagicDoubleHit] = const.kFightOddMagicDoubleHit
			local fightOrder = { order_id = soldier.skill_list[1].skill_id, order_level = soldier.skill_list[1].skill_level }
			soldier:setOrder( fightOrder )
			local fightLog = self:useSkill( soldier )
			table.insert( roundLogList, fightLog )
			soldier.state_list[const.kFightOddMagicDoubleHit] = nil
		end
	end
	
	--追击 杀死敌人时，随机普通攻击下一个敌人，但伤害降低

	if soldier.state_list[const.kFightOddPursuit] == const.kFightOddPursuit then
		local fightOrder = { order_id = soldier.skill_list[1].skill_id, order_level = soldier.skill_list[1].skill_level }
		soldier:setOrder( fightOrder )
		local fightLog = self:useSkill( soldier )
		table.insert( roundLogList, fightLog )
		soldier.state_list[const.kFightOddPursuit] = nil
	end
	
	--超级追击，拥有该buff时，杀死敌人时，怒气+100使用大招攻击另外一人，但是伤害降低N%

	if soldier.state_list[const.kFightOddSuperPursuit] == const.kFightOddSuperPursuit then
		local fightOrder = { order_id = soldier.skill_list[2].skill_id, order_level = soldier.skill_list[2].skill_level }
		soldier:setOrder( fightOrder )
		local fightLog = self:useSkill( soldier )
		table.insert( roundLogList, fightLog )
		soldier.state_list[const.kFightOddSuperPursuit] = nil
	end
	
	--风怒处理

	local fightOdd = soldier:findFightOdd(const.kFightOddDoubleHit)
	local fightOddDoubleHitBuff = soldier:findFightOdd(const.kFightOddDoubleHitBuff)
	local fightOddDisillusion = soldier:findFightOdd(const.kFightOddDisillusion)
	if nil ~= fightOdd and 0 == skill.disillusion and nil == soldier.state_list[const.kFightOddDoubleHit] and nil == fightOddDisillusion then
		local odd_per = fightOdd.status_value
		if nil ~= fightOddDoubleHitBuff then
			local odd = fightOddDoubleHitBuff:findOdd()
			if nil ~= odd then
				odd_per = odd_per + odd.status.val
			end
		end
		if self:fightRand() < odd_per then
			fightOdd.DoubleHit_Count = 0;
			soldier.state_list[const.kFightOddDoubleHit] = const.kFightOddDoubleHit
			local count = 2
			if nil ~= fightOddDoubleHitBuff then
				count = count + fightOddDoubleHitBuff.status_value
			end
			while count > 1 do
				table.insert(self.soldierAttackList, self.soldierAttackListIndex, soldier)
				count = count - 1
			end
		end
	end
	
	--判断是否能使用图腾插入
	local tarSoldierTotemList = self:getCanUseTotem()
	for _, tarTotemSoldier in ipairs( tarSoldierTotemList ) do
		if not self:DisillusionNext() and tarTotemSoldier:checkTotemSkill() then
            table.insert(self.soldierAttackList, self.soldierAttackListIndex+1, tarTotemSoldier)
			break
		end
	end	
	return roundLogList
end

function CFight:roundSkillSoldier()
	local skillObj = {}
	skillObj.round = self.round
	local copyTempSeed = copyTab(self.fightSeed)
	while true do
		if self:checkRoundEnd() then
			skillObj.order = { guid = 0, order_id = const.kFightRoundEnd }
			return skillObj
		end
		
		local soldierIndex = self.soldierAttackListIndex + 1
		if soldierIndex > #self.soldierAttackList then
			skillObj.order = { guid = 0, order_id = const.kFightRoundInit }
			return skillObj
		end
		
		local soldier = self.soldierAttackList[soldierIndex]
		
		if soldier:canAttack() then
			soldier:setOrder()
			
			local order = soldier.order
			if nil ~= order and 0 ~= order.order_id then
				local skill = findSkill( soldier.order.order_id, soldier.order.order_level )
				if nil ~= skill then
					skillObj.order = copyTab(order)
					skillObj.targetList = self:getTargetSoldier( soldier, skill )
					--设置soldier在运动状态

					soldier:addPlayFlag()
					LogMgr.log( 'fight', "fightseed" .. self.fightSeed.value )
					self.fightSeed = copyTempSeed
					return skillObj
				end
			end
		end
		self.soldierAttackListIndex = self.soldierAttackListIndex + 1
	end
end

--寻找user
function CFight:findUser( guid )
	for _, user in pairs(self.userList) do
		if user.guid == guid then
			return user
		end
	end
end

--阵营
function CFight:addFightUser( user )    
	--设置user的setmetatable
	local user = FightUser:new(user)
	table.insert(self.userList,user)
	--self.userList[user.guid] = user
	--设置soldier的setmetatable
	local totemValue = 0
	
	local roundLogList = {}
	local fightLog = FightLog:new(self.round)
	for _, soldier in pairs( user.soldier_list ) do
		FightSoldier:new(soldier)
		soldier.selfUserGuid = user.guid
		soldier.selfFightId = self.fight_id
		soldier.last_ext_able = copyTab(soldier.fight_ext_able)
		LogMgr.log( 'fight', "soldier_name:" .. soldier.name .. "soldier_hp:" .. soldier.hp )
		--LogMgr.log( 'fight', debug.dump(soldier.last_ext_able))
		--添加BUFF属性

		for _, fightOdd in pairs(soldier.odd_list) do
            FightOdd:newtable(fightOdd)
			fightOdd.begin_round = fightOdd.start_round
			soldier:addFightExt(fightOdd,fightLog.orderTargetList)
		end
		--如果是图腾初始化它的出手速度
		if soldier.attr == const.kAttrTotem then
			soldier.last_ext_able.rage = soldier.fight_index
		end
		
		--出场时增加初始图腾能量，如果有多个同样的buff存在，则取数值最高的那个，不叠加
		local fightOddTotemValue = soldier:findFightOdd(const.kFightOddTotemValueInit)
		if nil ~= fightOddTotemValue and totemValue < fightOddTotemValue.status_value then
			totemValue = fightOddTotemValue.status_value
		end
	end
	user.totem_value = user.totem_value + totemValue
	table.insert( roundLogList, fightLog )
	return roundLogList
end

--添加召唤怪物
function CFight:addFightMonster(user, id, index )
	local monster = findMonster(id)
	if nil == monster then
		return
	end
	local o = {
	guid = self:getMaxGuid(),
	soldier_guid = 0,
	attr = const.kAttrMonster,
	hp = 0,
	rage = 0,
	soldier_id = id,
	fame = 0,
	delFlag = 0,
	name = monster.name,
	level = toMyNumber(monster.level),
	fight_index = index,
	isPlay = 0,
	state_list = {},
	fight_ext_able = {},
	order = {},
	lastOrderRound = {},
	limitCountAll = {},
	skill_list = {},
	glyph_list = {},
	totem = {},
	totem_glyph_list = {}
	}
	for _, skill in pairs(monster.skills) do
		local s = {}
		s.skill_id = toMyNumber(skill.first)
		s.skill_level = toMyNumber(skill.second)
		table.insert(o.skill_list, s)
	end
	
	o.fight_ext_able.hp = toMyNumber(monster.hp)
	o.hp = o.fight_ext_able.hp
	
	o.fight_ext_able.hp = toMyNumber(monster.hp)
	o.fight_ext_able.physical_ack = toMyNumber(monster.physical_ack)
	o.fight_ext_able.physical_def = toMyNumber(monster.physical_def)
	o.fight_ext_able.magic_ack = toMyNumber(monster.magic_ack)
	o.fight_ext_able.magic_def = toMyNumber(monster.magic_def)
	o.fight_ext_able.speed = toMyNumber(monster.speed)
	o.fight_ext_able.critper = toMyNumber(monster.critper)
	o.fight_ext_able.critper_def = toMyNumber(monster.critper_def)
	o.fight_ext_able.crithurt = toMyNumber(monster.crithurt)
	o.fight_ext_able.crithurt_def = toMyNumber(monster.crithurt_def)
	o.fight_ext_able.hitper = toMyNumber(monster.hitper)
	o.fight_ext_able.dodgeper = toMyNumber(monster.dodgeper)
	o.fight_ext_able.parryper = toMyNumber(monster.parryper)
	o.fight_ext_able.parryper_dec = toMyNumber(monster.parryper_dec)
	o.fight_ext_able.rage = toMyNumber(monster.rage)
	o.fight_ext_able.stun_def = toMyNumber(monster.stun_def)
	o.fight_ext_able.silent_def = toMyNumber(monster.silent_def)
	o.fight_ext_able.weak_def = toMyNumber(monster.weak_def)
	o.fight_ext_able.fire_def = toMyNumber(monster.fire_def)
	
	FightSoldier:new(o)
	o.selfUserGuid = user.guid
	o.selfFightId = self.fight_id
	o.last_ext_able = copyTab(o.fight_ext_able)
	o.odd_list = {}
	--添加BUFF属性

	
	for _, odd in pairs(monster.odds) do
		local _odd = findOdd(odd.first,odd.second)
		if nil ~= _odd then
			local fightodd = FightOdd:new(_odd)
			fightodd.start_round = self.round
			table.insert(o.odd_list,fightodd)
		end
	end
	
	for _, fightOdd in pairs(o.odd_list) do
		o:addFightExt(fightOdd)
	end
	
	table.insert(user.soldier_list, o)
	return o
end

--设置战斗类型
function CFight:setFightType( _ft )
	self.fightType = _ft
end

--获得最大的SoldierGuid
function CFight:getMaxGuid()
	local max_guid = 0
	for _, user in pairs(self.userList) do
		for _, soldier in pairs(user.soldier_list) do
			if max_guid < soldier.guid then
				max_guid = soldier.guid
			end
		end
	end
	max_guid = max_guid + 1
	return max_guid
end

function CFight:findFightSoldier( guid )
	for _, user in pairs(self.userList) do
		for _, soldier in pairs(user.soldier_list) do
			if guid == soldier.guid then
				return soldier
			end
		end
	end
	return nil
end

function CFight:setAutoFight( isAuto, camp )
	local order = { guid = const.kFightRoundAuto, order_id = isAuto, order_level = camp }
	table.insert( self.orderList, order )
	
	for _, user in pairs(self.userList) do
		if user.camp == camp then
			user.isAutoFight = isAuto
		end
	end 
end

function CFight:getEndUserInfo()
	local endUserList = {}
	for _, user in pairs(self.userList) do
		table.insert(endUserList,user)
	end
	return endUserList
end

function CFight:fightRand(n)
	if nil == n then
		n = 10000
	end
	LogMgr.log('fight', "fight_seed:" .. self.fightSeed.value )
	if nil == self.fightSeed or nil == self.fightSeed.value then
		return 10000
	end
	return trans.base.rand(0,n,self.fightSeed)
end

function CFight:useTotemSkill( soldier )
	if soldier.attr ~= const.kAttrTotem then
		return
	end
	
	local roundLogList = {}
	
	--如果当前这一波战斗已经结束那么不能使用图腾
	if self:checkRoundEnd() or self.round > self:getFightMaxRound() then
		return roundLogList
	end
	
	local order = { guid = soldier.guid, order_id = soldier.skill_list[1].skill_id, order_level = soldier.skill_list[1].skill_level }
	local skill = findSkill( order.order_id, order.order_level )
	if nil ~= skill and soldier:canAttack() and soldier:checkTotemSkill() then
		table.insert(self.orderList,copyTab(order))
		soldier:setOrder(order)
		local fightlog = self:useSkill( soldier )
		table.insert(roundLogList, fightlog)
	end
	
	return roundLogList
end

--返回orderList
function CFight:getOrderList()
    --LogMgr.log( 'fight', debug.dump(self.orderList) )
    return self.orderList
end

--获取同阵营没有这个BUFF的人数

function CFight:getBuffCount( camp, id )
	local count = 0
	for _, soldier in pairs(self.soldierList) do
		if not soldier:checkEnd() and soldier.attr ~= kAttrTotem and soldier:getCamp() == camp then
			local fightOdd = soldier:findFightOdd(id)
			if nil == fightOdd then
				count = count + 1
			end
		end
	end
	return count
end

function theFightList.initFight( fight_id , seed )
	local new_fight = CFight:new()
	new_fight.fight_id = fight_id
	theFightList[fight_id] = new_fight
	new_fight:initFight(seed)
	return new_fight
end

function theFightList.delFight( fight_id )
	theFightList[fight_id] = nil
end

function theFightList.addFightUser( fight_id, user )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	fight:addFightUser(user)
end

function theFightList.autoFight( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	fight:autoFight()
end

function theFightList.roundSkillSoldier( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	
	return fight:roundSkillSoldier()
end

function theFightList.roundSkill( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	return fight:roundSkill()
end

function theFightList.checkEnd( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return true
	end
	
	return fight:checkEnd()
end

function theFightList.setFightType( fight_id, _ft )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	fight:setFightType(_ft)
end

function theFightList.getWinCamp( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return 0
	end
	
	return fight:getWinCamp()
end

function theFightList.getFightEndInfo( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return 0
	end
	
	return fight:getFightEndInfo()
end

function theFightList.getRound( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return 0
	end
	
	return fight:getRound()
end

function theFightList:getRoundOut()
	local fight = theFightList[fight_id]
	if nil == fight then
		return 0
	end
	
	if fight:getRound() >= fight:getFightMaxRound() then
		return 1
	end
	
	return 0
end

function CFight:getLeftDeadSoldierCount()
	local count = 0
	for _, user in pairs(self.userList) do
		if user.camp == const.kFightLeft then
			count = count + user:getDeadSoldierCount()
		end
	end
	
	return count
end

function theFightList.checkTotemSkill( fight_id, guid )
	local fight = theFightList[fight_id]
	if nil == fight then
		return false
	end
	local soldier = fight:findSoldier( guid )
	if nil == soldier then
		return false
	end
	return soldier:checkTotemSkill()
end

function theFightList.useTotemSkill( fight_id, guid )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	local soldier = fight:findSoldier( guid )
	return fight:useTotemSkill(soldier)
end

function theFightList.addOrder( fight_id, order_list )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	fight.checkOrderList = order_list
end

function theFightList.addEndSoldier( fight_id, end_soldier_list )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	fight.soldierEndList = end_soldier_list
end

function theFightList.checkServer( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	return fight:checkServer()
end

function theFightList.delFight( fight_id )
	theFightList[fight_id] = nil
end

function GetFightData()
	return theFightList
end

function theFightList.TestLua()
end

function theFightList.getOrderList( fight_id )
	local fight = theFightList[fight_id]
	if nil == fight then
		return
	end
	return fight:getOrderList()
end

function SetFightData( fightDataList )
	if nil == fightDataList then
		return
	end
	for _, fight in pairs( fightDataList ) do
		local new_fight = CFight:new(fight)
		for _, si in pairs( new_fight.soldierList ) do
			for _, user in pairs( new_fight.userList ) do
				for _, sj in pairs( user.soldier_list ) do
					if si.guid == sj.guid then
						si = sj
					end
				end
			end
		end
		
		for _, si in pairs( new_fight.soldierAttackList ) do
			for _, user in pairs( new_fight.userList ) do
				for _, sj in pairs( user.soldier_list ) do
					if si.guid == sj.guid then
						si = sj
					end
				end
			end
		end
		for _, user in pairs( new_fight.userList ) do
			for _, sj in pairs( user.soldier_list ) do
				FightSoldier:new(sj)
				for _, odd in pairs( soldier.odd_list ) do
					FightOdd:newtable(odd)
				end
			end
		end
		theFightList[new_fight.fight_id] = new_fight
	end
end
