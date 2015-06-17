------------------------------伤害相关数据start
local __this = 
{
    redNumberList = {},    --普通伤害数字资源列表
    greenNumberList = {},    --普通恢复数字资源列表
    critNumberList = {},    --暴击伤害数字资源列表
    critAddNumberList = {},	--暴击增加数字资源列表
    parryNumberList = {},    --格挡伤害数字资源列表
    dodgeNumberList = {},    --闪避资源列表
    pinkNumberList = {},    --buff伤害数字资源列表
    buffNumberLayer1List = {},	--buff层数字资源列表
    buffNumberLayer2List = {},	--buff层数字资源列表

	totemNumberList = {},	--图腾数字资源列表
	totemProList = {},		--图腾进度条资源列表
    normalHpList = {},		--普通血条资源列表
    normalHpSecondList = {},--二层血条资源列表

    imageList = {},			--image资源引用列表

    fix_val = 350	--修正时间差
}
__this.__index = __this

require("lua/utils/UICommon.lua")
local function spriteCreate(url)
	FightNumberMgr.imageList[url] = FightNumberMgr.imageList[url] or 0
	FightNumberMgr.imageList[url] = FightNumberMgr.imageList[url] + 1

	LoadMgr.loadImage(url, LoadMgr.SCENE, "fight")
	local v = Sprite:create(url)
	v:retain()

	return v
end
local function removeImage(url)
	if not url or not FightNumberMgr.imageList[url] then
		return
	end

	FightNumberMgr.imageList[url] = FightNumberMgr.imageList[url] - 1
	if 0 == FightNumberMgr.imageList[url] then
		LoadMgr.removeImage(url)
		FightNumberMgr.imageList[url] = nil
	end
end

--buff层数减益数字
local FightNormalNumberLayer1 = createUILayout("FightNormalNumberLayer1", FightFileMgr.prePath .. "FightNumber/Fight_Normal_Number1.ExportJson", "FightDataMgr")
function FightNormalNumberLayer1:ctor()
	self:retain()
end
function FightNormalNumberLayer1:releaseAll()
	self:removeFromParent()
	self:release()
end
--buff层数增益数字
local FightNormalNumberLayer2 = createUILayout("FightNormalNumberLayer2", FightFileMgr.prePath .. "FightNumber/Fight_Normal_Number2.ExportJson", "FightDataMgr")
function FightNormalNumberLayer2:ctor()
	self:retain()
end
function FightNormalNumberLayer2:releaseAll()
	self:removeFromParent()
	self:release()
end


--normal血条=======================start
local FightNormalHp = createUILayout("FightNormalHp", FightFileMgr.prePath .. "FightNormal/BloodFirst.ExportJson", "FightDataMgr")
function FightNormalHp:ctor()
	self:retain()
end
function FightNormalHp:releaseAll()
	self:removeFromParent()
	self:release()
end
--血条更新
function FightNormalHp:hp_update(time)
    local hp_bar = self.BossBloodUI_hp.hp_bar
    self.lastHp = self.hp + (self.lastHp - self.hp) * 0.75
    hp_bar.hp:setPercent(100 * self.lastHp / self.maxHp)
end
--重置血条数据
function FightNormalHp:reset_hp(maxHp)
    self.maxHp = maxHp
    self.hp = maxHp
    self.lastHp = maxHp
end
--FightDataMgr:runNumber
function FightNormalHp:set_Hp(time, hp)
    self.hp = self.hp + hp
    if self.hp > self.maxHp then
    	self.hp = self.maxHp
	elseif self.hp < 0 then
		self.hp = 0
    end
end
function FightNormalHp:set_Rage(rage)
end
function FightNormalHp:setOddBg(visible)
end

local FightNormalHp_second = createUILayout("FightNormalHp_second", FightFileMgr.prePath .. "FightNormal/BloodSecond.ExportJson", "FightDataMgr")
function FightNormalHp_second:ctor()
	self:retain()
	self.rage = 0
	self.lastRage = 0
	self.maxRage = 100
end
function FightNormalHp_second:releaseAll()
	self:removeFromParent()
	self:release()
end
--血条更新
function FightNormalHp_second:hp_update(time)
    local hp_bar = self.BossBloodUI_hp.hp_bar
    self.lastHp = self.hp + (self.lastHp - self.hp) * 0.75
    hp_bar.hp:setPercent(100 * self.lastHp / self.maxHp)

    if not self.lastRage or not self.rage or not self.maxRage then
    	return
    end

    hp_bar = self.BossBloodUI_rage.hp_bar
    self.lastRage = self.rage + (self.lastRage - self.rage) * 0.75
    hp_bar.hp:setPercent(100 * self.lastRage / self.maxRage)
end
--重置血条数据
function FightNormalHp_second:reset_hp(maxHp, maxRage)
    self.maxHp = maxHp
    self.hp = maxHp
    self.lastHp = maxHp

    self.maxRage = 100
    self.rage = 0
    self.lastRage = 0
end
--FightDataMgr:runNumber
function FightNormalHp_second:set_Hp(time, hp)
    self.hp = self.hp + hp
    if self.hp > self.maxHp then
    	self.hp = self.maxHp
	elseif self.hp < 0 then
		self.hp = 0
    end
end
function FightNormalHp_second:set_Rage(rage)
    self.rage = rage
    if self.rage > self.maxRage then
    	self.rage = self.maxRage
	elseif self.rage < 0 then
		self.rage = 0
	end
end
function FightNormalHp_second:setOddBg(visible)
	self.progressBg.progressOddBg:setVisible(visible)
end
--normal血条=======================end

------------------------回复start
--普通回复数字
 FightGreenNumber = createUILayout("FightGreenNumber", FightFileMgr.prePath .. "FightNumber/Number_green.ExportJson", "FightDataMgr")
function FightGreenNumber:ctor()
    self:retain()
	-- self:setCascadeOpacityEnabled(true)
	-- self.image:setCascadeOpacityEnabled(true)
end
function FightGreenNumber:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightGreenNumber:setValue(value)
	self.image:setString(value)
	self.size = self.image:getContentSize()
end
function FightGreenNumber:idle(time, data, coord)
	local frame = FightData:getNowFrame(data, 30, time) + 1
	local fix = data.endPT.y / 24 * frame
	if frame < 15 then
		fix = 0
	else
		fix = data.endPT.y / 24 * (frame - 15)
	end

	fix = fix + 40
	local pt = cc.p(coord.x, coord.y + fix)
	self:setPosition(pt)
	if frame < 5 then
		self:setScale(1 + frame * 0.08)
	elseif frame < 10 then
		self:setScale(1.4)
	elseif frame < 15 then
		frame = frame - 10
		self:setScale(1.4 - frame * 0.08)
	else
		self:setScale(1)
	end
end
------------------------伤害end

------------------------buff伤害start
--Buff伤害数字
local FightPinkNumber = createUILayout("FightPinkNumber", FightFileMgr.prePath .. "FightNumber/Number_pink.ExportJson", "FightDataMgr")
function FightPinkNumber:ctor()
	self:retain()
	-- self:setCascadeOpacityEnabled(true)
	-- self.image:setCascadeOpacityEnabled(true)
end
function FightPinkNumber:releaseAll()
	if self.buffImage then
		self.buffImage:removeFromParent()
		self.buffImage:release()
		removeImage(self.url)
	end

	self:removeFromParent()
	self:release()
end
function FightPinkNumber:setValue(value, odd_id)
	self.image:setString(value)
	self.size = self.image:getContentSize()

	if not odd_id then
		return
	end

	local odd = findOdd(odd_id, 1)
	if not odd or '' == odd.buffname then
		return
	end

	self.url = "image/skillname/buff/" .. odd.buffname .. ".png"
	self.buffImage = UIFactory.getSprite(self.url)
	self.buffImage:retain()
	local size = self.buffImage:getContentSize()
	self.buffImage:setPosition(-size.width, size.height / 2)
	self:addChild(self.buffImage)
end
function FightPinkNumber:idle(time, data, coord)
	local alpha = 0
	local scale = 1
	local pt = cc.p(coord.x, coord.y)
	local t = time - data.startTime
	if t < 175 then
		alpha = t / 175 * 255
		pt.y = pt.y + t / 175 * 24
	elseif t < 500 then
		alpha = 255
		pt.y = pt.y + 24 + (t - 175) / 325 * 39
	else
		alpha = 255
		pt.y = pt.y + 63 + (t - 500) / 350 * 50
	end
	
	self:setScale(scale)
	self:setPosition(pt)
	setUiOpacity(self, alpha)
end
------------------------buff伤害end

------------------------图腾数字start
--图腾技能冷却数字
local FightWhiteNumber = createUILayout("FightWhiteNumber", FightFileMgr.prePath .. "FightTotem/totem_number_cool.json", "FightDataMgr")
function FightWhiteNumber:ctor()
	self:retain()
	self.attr = "white"
	-- self:setCascadeOpacityEnabled(true)
	-- self.image:setCascadeOpacityEnabled(true)
end
function FightWhiteNumber:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightWhiteNumber:setValue(value)
	self.image:setString(value)
	self.size = self.image:getContentSize()
	if 0 ~= value then
		self:setVisible(true)
	else
		self:setVisible(false)
	end
end
function FightWhiteNumber:idle(parentSize)
	local size = self:getSize()
	self:setPosition((parentSize.width - size.width) / 2, (parentSize.height - size.height) / 2 + 5)
end

--图腾值数字
local FightTotemValNumber = createUILayout("FightTotemValNumber", FightFileMgr.prePath .. "FightTotem/totem_number_val.json", "FightDataMgr")
function FightTotemValNumber:ctor()
	self:retain()
	self.attr = "val"
end
function FightTotemValNumber:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightTotemValNumber:setValue(value)
	self.image:setString(value)
	self.size = self.image:getContentSize()
	if 0 ~= value then
		self:setVisible(true)
	else
		self:setVisible(false)
	end
end
function FightTotemValNumber:idle(parentSize)
	local size = self:getSize()
	self:setPosition((parentSize.width - size.width) / 2, (parentSize.height - size.height) / 2)
end
--图腾怒气值数字[blue]
local FightTotemBlueNumber = createUILayout("FightTotemBlueNumber", FightFileMgr.prePath .. "FightTotem/totem_number_blue.json", "FightDataMgr")
function FightTotemBlueNumber:ctor()
	self:retain()
	self.attr = "blue"
end
function FightTotemBlueNumber:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightTotemBlueNumber:idle(parentSize)
	local size = self:getSize()
	self:setPosition((parentSize.width - size.width) / 2, (parentSize.height - size.height) / 2)
end
--图腾怒气值数字[blue]
local FightTotemRedNumber = createUILayout("FightTotemRedNumber", FightFileMgr.prePath .. "FightTotem/totem_number_red.json", "FightDataMgr")
function FightTotemRedNumber:ctor()
	self:retain()
	self.attr = "red"
end
function FightTotemRedNumber:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightTotemRedNumber:idle(parentSize)
	local size = self:getSize()
	self:setPosition((parentSize.width - size.width) / 2, (parentSize.height - size.height) / 2)
end
------------------------图腾数字end

------------------------伤害start
--普通伤害数字
local FightDicHP = createUILayout("FightDicHP", FightFileMgr.prePath .. "FightNumber/Number_red.ExportJson", "FightDataMgr")
function FightDicHP:ctor()
	self:retain()
	-- self:setCascadeOpacityEnabled(true)
	-- self.image:setCascadeOpacityEnabled(true)
end
function FightDicHP:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightDicHP:setValue(value)
	self.image:setString(value)
	self.size = self.image:getContentSize()
end
function FightDicHP:idle(time, data, coord)
	local alpha = 255
	local pt = cc.p(coord.x, coord.y)
	local t = time - data.startTime
	local scale = 1
	
	if t < 125 then
		local fix = t / 125
		scale = 1 + fix
		pt.y = coord.y + fix * 15
	elseif t < 250 then
		local fix = (t - 125) / 125
		scale = 2 - fix
		pt.y = coord.y + 15 + fix * 20
	elseif t < 875 then
		local fix = (t - 250) / 625
		pt.y = coord.y + 35 + fix * 84
	else
		local fix = (t - 875) / 175
		pt.y = coord.y + 119 + fix * 84
		
		alpha = 255 - (t - 875) / 175 * 255
	end
	
	self:setScale(scale)
	self:setPosition(pt)
	-- self:setOpacity(alpha)
	setUiOpacity(self, alpha)
end
------------------------伤害end

------------------------暴击start
--暴击伤害数字
local FightCrit = createUILayout("FightCrit", FightFileMgr.prePath .. "FightNumber/FightCrit.ExportJson", "FightDataMgr")
function FightCrit:ctor()
    self:retain()
	-- self:setCascadeOpacityEnabled(true)
end
function FightCrit:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightCrit:setValue(value)
	self.number:setString(value)
	self.size = self.number:getContentSize()
end
function FightCrit:idle(time, data, coord)
	local alpha = 255
	local pt = cc.p(coord.x, coord.y + 50)
	local t = time - data.startTime
	local scale = 1
	if t < 100 then
		local fix = t / 100 * (0.5)
		scale = 1 + fix
	elseif t < 200 then
		scale = 1.5
	elseif t < 300 then
		local fix = (t - 300) / 100 * (0.5)
		scale = 1.5 - fix
	elseif t < 1000 then
		scale = 1
	else
		scale = 1
		alpha = 255 - (t - 1000) / 350 * 255
	end
	
	self:setScale(scale)
	self:setPosition(pt)
	setUiOpacity(self, alpha)
end

--暴击增加数字
local FightCritAdd = createUILayout("FightCritAdd", FightFileMgr.prePath .. "FightNumber/FightCritAdd.ExportJson", "FightDataMgr")
function FightCritAdd:ctor()
    self:retain()
	-- self:setCascadeOpacityEnabled(true)
end
function FightCritAdd:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightCritAdd:setValue(value)
	self.number:setString(value)
	self.size = self.number:getContentSize()
end
function FightCritAdd:idle(time, data, coord)
	local alpha = 255
	local pt = cc.p(coord.x, coord.y + 50)
	local t = time - data.startTime
	local scale = 1
	if t < 100 then
		local fix = t / 100 * (0.5)
		scale = 1 + fix
	elseif t < 200 then
		scale = 1.5
	elseif t < 300 then
		local fix = (t - 300) / 100 * (0.5)
		scale = 1.5 - fix
	elseif t < 1000 then
		scale = 1
	else
		scale = 1
		alpha = 255 - (t - 1000) / 350 * 255
	end
	
	self:setScale(scale)
	self:setPosition(pt)
	setUiOpacity(self, alpha)
end
------------------------暴击end

------------------------格挡start
local FightParry = createUILayout("FightParry", FightFileMgr.prePath .. "FightNumber/FightParry.ExportJson", "FightDataMgr")
function FightParry:ctor()
	self:retain()
end
function FightParry:releaseAll()
	self:removeFromParent()
	self:release()
end
function FightParry:setValue(value)
	self.number:setString(value)
	self.size = self.number:getContentSize()
end
function FightParry:idle(time, data, coord)
	local frame = FightData:getNowFrame(data, 30, time) + 1
	local fix = data.endPT.y / 24 * frame
	if frame < 15 then
		fix = 0
	else
		fix = data.endPT.y / 24 * (frame - 15)
	end
	local pt = cc.p(coord.x, coord.y + fix)
	self:setPosition(pt)
	if frame < 5 then
		self:setScale(1 + frame * 0.08)
	elseif frame < 10 then
		self:setScale(1.4)
	elseif frame < 15 then
		frame = frame - 10
		self:setScale(1.4 - frame * 0.08)
	else
		self:setScale(1)
	end
end
------------------------格挡end

------------------------闪避start
FightDodge = class("FightDodge",function()
	local node = cc.Node:create()
	node:retain()
    -- node:setCascadeOpacityEnabled(true)

    node.urlBg = "image/ui/FightUI/fight_dodge.png"
	local bg = UIFactory.getSprite(node.urlBg)
	bg:retain()
	node.bg = bg
	
	node:addChild(bg)
	return node
end)
function FightDodge:create()
	return FightDodge.new()
end
function FightDodge:releaseAll()
	self.bg:removeFromParent()
	self.bg:release()
	self.bg = nil
	removeImage(self.urlBg)

	self:removeFromParent()
	self:release()
end
function FightDodge:setValue(value)
	self.size = self:getContentSize()
end
function FightDodge:idle(time, data, coord)
	local frame = FightData:getNowFrame(data, 30, time) + 1
	local fix = data.endPT.y / 24 * frame
	if frame < 15 then
		fix = 0
	else
		fix = data.endPT.y / 24 * (frame - 15)
	end
	local pt = cc.p(coord.x, coord.y + fix)
	self:setPosition(pt)
	if frame < 5 then
		self:setScale(1 + frame * 0.08)
	elseif frame < 10 then
		self:setScale(1.4)
	elseif frame < 15 then
		frame = frame - 10
		self:setScale(1.4 - frame * 0.08)
	else
		self:setScale(1)
	end
end
------------------------闪避end

function __this:checkNumber(data, layer, list)
	for __, number in pairs(list) do
		if not number.use then
			number.use = true
			number:setValue('/' .. data.orderTarget.fight_value, data.odd_id)
			data.number = number
			layer:addChild(number)
			return true
		end
	end
	
	return false
end
function __this:numberCreate(data, layer)
	--正常
	if trans.const.kFightCommon == data.fight_type then
		if trans.const.kFightDicHP == data.fight_result then
			if 0 == data.orderTarget.fight_might then
				local pink = FightPinkNumber.new()
				pink.use = true
				pink:setValue('/' .. data.orderTarget.fight_value, data.odd_id)
				data.number = pink
				table.insert(self.pinkNumberList, pink)
				layer:addChild(pink)
				data.list = self.pinkNumberList
			else
				local red = FightDicHP.new()
				red.use = true
				red:setValue('/' .. data.orderTarget.fight_value)
				data.number = red
				table.insert(self.redNumberList, red)
				layer:addChild(red)
				data.list = self.redNumberList
			end
			
		elseif trans.const.kFightAddHP == data.fight_result then
			local green = FightGreenNumber.new()
			green.use = true
			green:setValue('/' .. data.orderTarget.fight_value)
			data.number = green
			table.insert(self.greenNumberList, green)
			layer:addChild(green)
			data.list = self.greenNumberList
		end
		
	--暴击
	elseif trans.const.kFightCrit == data.fight_type then
		local yellow = nil
		if trans.const.kFightAddHP == data.fight_result then
			yellow = FightCritAdd.new()
			table.insert(self.critAddNumberList, yellow)
			data.list = self.critAddNumberList
		else
			yellow = FightCrit.new()
			table.insert(self.critNumberList, yellow)
			data.list = self.critNumberList
		end

		yellow.use = true
		yellow:setValue('/' .. data.orderTarget.fight_value)
		data.number = yellow
		layer:addChild(yellow)
		
	--格挡
	elseif trans.const.kFightParry == data.fight_type then
		local parry = FightParry.new()
		parry.use = true
		parry:setValue('/' .. data.orderTarget.fight_value)
		data.number = parry
		table.insert(self.parryNumberList, parry)
		layer:addChild(parry)
		data.list = self.parryNumberList

	--闪避
	elseif trans.const.kFightDodge == data.fight_type then
		local dodge = FightDodge:create()
		dodge.use = true
		dodge:setValue('/' .. data.orderTarget.fight_value)
		data.number = dodge
		table.insert(self.dodgeNumberList, dodge)
		layer:addChild(dodge)
		data.list = self.dodgeNumberList
	end
end

function __this:useRedNumber(data, layer)
    if data.number then
        return
    end
	
	--[[只创建新对象，对象使用完即时释放
	--正常
	if trans.const.kFightCommon == data.fight_type then
		if trans.const.kFightDicHP == data.fight_result then
			if 0 == data.orderTarget.fight_might then
				if self:checkNumber(data, layer, self.pinkNumberList) then
					return
				end
			else
				if self:checkNumber(data, layer, self.redNumberList) then
					return
				end
			end
		elseif trans.const.kFightAddHP == data.fight_result then
			if self:checkNumber(data, layer, self.greenNumberList) then
				return
			end
		end
	--暴击
	elseif trans.const.kFightCrit == data.fight_type then
		if trans.const.kFightAddHP == data.fight_result then
			if self:checkNumber(data, layer, self.critAddNumberList) then
				return
			end
		else
			if self:checkNumber(data, layer, self.critNumberList) then
				return
			end
		end
	--格挡
	elseif trans.const.kFightParry == data.fight_type then
		if self:checkNumber(data, layer, self.parryNumberList) then
			return
		end
	--闪避
	elseif trans.const.kFightDodge == data.fight_type then
		if self:checkNumber(data, layer, self.dodgeNumberList) then
			return
		end
	end]]

    self:numberCreate(data, layer)
end

function __this:unRedNumber(data)
    if not data.number then
        return
    end

    for i, number in pairs(data.list) do
    	if data.number == number then
    		table.remove(data.list, i)
    		break
    	end
    end

    -- if data.number.url then
    -- 	data.number.buffImage:removeFromParent()
    -- 	data.number.buffImage:release()
    -- 	data.number.buffImage = nil
    -- 	LoadMgr.removeImage(data.number.url)
    -- end

    -- data.number:setScale(1)
    -- data.number.use = false
    data.number:removeFromParent()
    data.number:releaseAll()
    data.number = nil
end

--创建图腾技能冷却数字[专用]=====================start
function __this:createTotemNumber(attr)
	for __, number in pairs(self.totemNumberList) do
		if not number.use and attr == number.attr then
			number.use = true
			number.image:setString('0')
			return number
		end
	end

	local number = nil
	if "white" == attr then
		number = FightWhiteNumber.new()
	elseif "blue" == attr then
		number = FightTotemBlueNumber.new()
	elseif "val" == attr then
		number = FightTotemValNumber.new()
	else
		number = FightTotemRedNumber.new()
	end
	number.use = true
	table.insert(self.totemNumberList, number)

	return number
end
--释放图腾技能冷却数字[专用]==================end
function __this:unTotemNumber(number)
	number:removeFromParent()
	number.use = false
end

--获取血条[专用]=====================start
function __this:useNormalHp()
	for __, hp in pairs(self.normalHpList) do
		if not hp.use then
			hp.use = true
			return hp
		end
	end

	local hp = FightNormalHp:new()
	table.insert(self.normalHpList, hp)
	hp.use = true

	return hp
end
function __this:unNormalHp(hp)
	hp:removeFromParent()
	hp.use = false
end
function __this:useNormalHpSecond()
	for __, hp in pairs(self.normalHpSecondList) do
		if not hp.use then
			hp.use = true
			return hp
		end
	end

	local hp = FightNormalHp_second:new()
	table.insert(self.normalHpSecondList, hp)
	hp.use = true

	return hp
end
--释放血条[专用]===================end

--获取buff层数减益数字[专用]=====================start
function __this:useBuffLayer1()
	for __, number in pairs(self.buffNumberLayer1List) do
		if not number.use then
			number.use = true
			return number
		end
	end

	local number = FightNormalNumberLayer1:new()
	table.insert(self.buffNumberLayer1List, number)
	number.use = true

	return number
end
--释放buff层数减益数字[专用]===================end
function __this:unBuffLayer(number)
	number:removeFromParent()
	number.use = false
end
--获取buff层数增益数字[专用]=====================start
function __this:useBuffLayer2()
	for __, number in pairs(self.buffNumberLayer2List) do
		if not number.use then
			number.use = true
			return number
		end
	end

	local number = FightNormalNumberLayer2:new()
	table.insert(self.buffNumberLayer2List, number)
	number.use = true

	return number
end

function __this.releaseList(list)
	for __, value in pairs(list) do
		value:releaseAll()
	end

	return {}
end

function __this:releaseAll()
	-- LogMgr.log( 'debug',"*****************FightNumberMgr:releaseAll*****************")
	-- if FightDataMgr.test or not FightDataMgr.test then
	-- 	return
	-- end

    --普通伤害数字资源列表
    self.redNumberList = self.releaseList(self.redNumberList)
	--普通恢复数字资源列表
    self.greenNumberList = self.releaseList(self.greenNumberList)
	--暴击伤害数字资源列表
    self.critNumberList = self.releaseList(self.critNumberList)
	--暴击增加数字资源列表
    self.critAddNumberList = self.releaseList(self.critAddNumberList)
    --格挡伤害数字资源列表
    self.parryNumberList = self.releaseList(self.parryNumberList)
    --闪避资源列表
    self.dodgeNumberList = self.releaseList(self.dodgeNumberList)
    --buff伤害数字资源列表
    self.pinkNumberList = self.releaseList(self.pinkNumberList)
    --buff层数字资源列表
    self.buffNumberLayer1List = self.releaseList(self.buffNumberLayer1List)
    --buff层数字资源列表
    self.buffNumberLayer2List = self.releaseList(self.buffNumberLayer2List)

	
	--图腾技能冷却数字资源列表
    self.totemNumberList = self.releaseList(self.totemNumberList)
    --图腾进度条资源列表
    self.totemProList = self.releaseList(self.totemProList)
    --普通血条资源列表
    self.normalHpList = self.releaseList(self.normalHpList)
    --二层血条资源列表
    self.normalHpSecondList = self.releaseList(self.normalHpSecondList)

    self.imageList = {}
end
------------------------------伤害数据end


FightNumberMgr = __this