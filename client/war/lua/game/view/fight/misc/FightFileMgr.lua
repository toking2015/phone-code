local __this = 
{
    body = nil,
    effect = nil,
	sound = nil,
    
    prePath = "image/ui/FightUI/",

    timeShaft =
    {
        --施放方动作起始时间点
        TIME_ACK_ACTION = 1,
        --施放方特效起始时间点
        TIME_ACK_EFFECT = 2,
        --辅助特效起始时间点
        TIME_FIRE_EFFECT = 3,
		
        --受击方特效起始时间点
        TIME_HURT_EFFECT = 4,
        --受击方动作起始时间点
        TIME_HURT_ACTION_START = 5,
        --受击方动作结束时间点
        TIME_HURT_ACTION_END = 6,
    },
	
	sound_enum =
	{
		--施放方
		ACK = 1,
		--辅助方
		FIRE = 2,
		--受击方
		TARGET = 3,
		--喊招
		ACTION = 4,
		--死亡
		DEAD = 5,
	}
}
__this.__index = __this

function __this:copyTab(st)
    local tab = {}
    for k, v in pairs(st or {}) do
        if type(v) ~= "table" then
            tab[k] = v
        else
            tab[k] = self:copyTab(v)
        end
    end
    return tab
end


function __this.checkSame(effect)
    if not FightDataMgr.banshu then
        return false
    end

    local list = string.split(effect, '%')
    if FightDataMgr.banshu == list[1] then
        return true
    end

    return false
end

function __this:removeFromParent(view)
    if not view or not view:getParent() then
        return
    end
	
    view:getParent():removeChild(view)
end

function __this:getFiltersBlack()
    if self.filterBlack then
        return self.filterBlack
    end

    local filter = ProgramMgr.createProgramState( "paint" )
    self.filterBlack = filter
    filter:retain()
    filter:setUniformVec4( 'u_color', { x = 0.15, y = 0.15, z = 0.15, w = 1 } )
    return filter
end

function __this:getfiltersRed()
	if self.filterRed then
		return self.filterRed
	end

	local filter = ProgramMgr.createProgramState( "paint" )
	self.filterRed = filter
	filter:retain()
	filter:setUniformVec4( 'u_color', { x = 0.7, y = 0, z = 0, w = 0.55 } )
	return filter
end

function __this:getFiltersWhite()
    if self.filterWhite then
        return self.filterWhite
    end

    local filter = ProgramMgr.createProgramState( "paint" )
    self.filterWhite = filter
    filter:retain()
    filter:setUniformVec4('u_color', {x = 1, y = 1, z = 1, w = 0.55} )
    return filter
end

--音效数据============================start
local BodySound = {}
function BodySound:new( sound )
    local sound = sound or {}
    setmetatable( sound, self )
    self.__index = self
    return sound
end

function BodySound:getActionByFlag( flag, effectIndex, attr )
	for __, sound in pairs( self.dataList ) do
        if flag == sound.flag and effectIndex == sound.effectIndex then
            for __, es in pairs(sound.list) do
                if attr == es.attr then
                    return es
                end
            end
        end
    end

    return nil
end

function BodySound:getOtherSound(attr)
	for __, sound in pairs(self.soundList) do
		if attr == sound.attr then
			return sound
		end
	end
end

local SoundData = {}
function __this:soundInit()
    self.sound = seq.stream_to_object("SSoundData", seq.read_stream_file("cbm/sounddata.cbm"))
end

function __this:getSound( style )
	if not self.sound.list then
		return nil
	end
    for __, sound in pairs(self.sound.list) do
        BodySound:new( sound )
        if style == sound.style then
            return sound
        end
    end
    
    return nil
end
--音效数据============================end

--角色数据============================start
local PhoneBody = {}
function PhoneBody:new( body )
    local body = body or {}
    setmetatable( body, self )
    self.__index = self
    return body
end

function PhoneBody:getActionByFlag( flag )
	for __, action in pairs( self.list ) do
        if flag == action.flag then
            return action
        end
    end

    return nil
end

local PhoneData = {}
function __this:bodyInit()
    local fileName = "cbm/playerdata.cbm"
    local stream = seq.read_stream_file( fileName )
    self.body = seq.stream_to_object( "SPhoneData", stream )
end

function __this:getBody( style )
    for __, body in pairs( self.body.list ) do
        PhoneBody:new( body )
        if style == body.style then
            return body
        end
    end
    
    return nil
end
--角色数据============================end


--特效数据============================start
local PhoneEffect = {}
function PhoneEffect:new(effect)
	local effect = effect or {}
	setmetatable(effect, self)
	self.__index = self
	return effect
end

function PhoneEffect:getEffectByFlag(flag)
    for __, effect in pairs( self.list ) do
        if flag == effect.flag then
            return effect
        end
    end

    return nil
end

function PhoneEffect:getEffectItemLongTime(flag, time)
    local effectItem = self:getEffectByFlag(flag)
    if not effectItem then
        return time
    end
    
    return time + 25 * effectItem.count
end

function PhoneEffect:getEffectNormal()
	if 0 == #self.list then
		return nil
	end
	
	return self.list[1]
end

local EffectData = {}
function __this:effectInit()
    local fileName = "cbm/effectdata.cbm"
    local stream = seq.read_stream_file( fileName ) 
    local data = seq.stream_to_object( "SEffectData", stream )
    self.effect = data
end

function __this:getEffect( style )
    for __, effect in pairs( self.effect.DataList ) do
		PhoneEffect:new(effect)
        if style == effect.style then
            return effect
        end
    end

    return nil
end
--特效数据============================end

--获取对应受击相关[返回timeShaftDataList索引，如果数据不一致，则返回最近一段]
function __this:getMight(actionEffect, might)
	local index = might;
	if 0 == might then
		index = 1
	end

    while 2 + 4 * index > #actionEffect.timeShaftDataList do
        index = index - 1
    end

    return 3 + (index - 1) * 4
end

--获取受击相关最大段数
function __this.getMaxMight(actionEffect)
	if #actionEffect.timeShaftDataList == 0 then
		return 0
	end
	
	return (#actionEffect.timeShaftDataList - 2) / 4
end

--获取受击方动作持续时间
function __this:getHurtActionLongTime( actionEffect, index )
    if 0 == #actionEffect.timeShaftDataList then
        return 0
    end
    
    if nil == index or 0 == index then
        index = 3
    end
    
    return actionEffect.timeShaftDataList[index + 3] - actionEffect.timeShaftDataList[index + 2]
end

--获取首次受击时间点
function __this:getFirstHurtTime(actionEffect, time)
    if 0 == #actionEffect.timeShaftDataList then
        return 0
    end

    return actionEffect.timeShaftDataList[self.timeShaft.TIME_HURT_ACTION_START] + time
end

function __this:getTime( actionEffect, timeShaftEnum, time )
    if 0 == #actionEffect.timeShaftDataList then
        return time
    end
    
    return time + actionEffect.timeShaftDataList[self.timeShaft[timeShaftEnum]]
end

function __this:getActionEffect( action, index )
    for __, actionEffect in pairs( action.listEffect ) do
        if index == actionEffect.index then
            return actionEffect
        end
    end
    
    return nil
end

function __this:getActionEndTime( action, time )
    if "stand" == action.flag then
        return action.count * 33 + time
    elseif "dead" == action.flag then
        return action.count * 40 + time
    end
    return action.count * 25 + time
end

function __this.newActionEffect(actionEffect)
    local ae = 
    {
        index = actionEffect.index,
        ackEffect = actionEffect.ackEffect,
        fireEffect = actionEffect.fireEffect,
        targetEffect = actionEffect.targetEffect,
        timeShaftDataList = {}
    }
    
    for __, i in pairs(actionEffect.timeShaftDataList) do
        table.insert(ae.timeShaftDataList,i)
    end
    
    return ae
end

FightFileMgr = __this
FightFileMgr:bodyInit()
FightFileMgr:effectInit()
FightFileMgr:soundInit()