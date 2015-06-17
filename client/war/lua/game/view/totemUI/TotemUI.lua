--author:曾宪荣
--desc: 图腾系统UI

require("lua/game/view/totemUI/TotemBaseUI.lua")
require("lua/game/view/totemUI/TotemChargeUI.lua")
require("lua/game/view/totemUI/TotemListUI.lua")
require("lua/game/view/totemUI/TotemMergeSucUI.lua")
require("lua/game/view/totemUI/TotemMergeUI.lua")
require("lua/game/view/totemUI/TotemSkillUI.lua")
require("lua/game/view/totemUI/TotemSlotUI.lua")
require("lua/game/view/totemUI/TotemSlotProcUI.lua")
require("lua/game/view/totemUI/TotemUpgradeUI.lua")

local SUB_1 = 1
local SUB_2 = 2
local SUB_3 = 3

local ModuleList = 
{
	[1]={TotemListUI,0,0},
	[2]={TotemBaseUI,0,0},
	[3]={TotemSkillUI,1,0},
	[4]={TotemUpgradeUI,0,0},
	[5]={TotemChargeUI,-1,0},
	[6]={TotemSlotUI,0,0},
	[7]={TotemSlotProcUI,0,0},
	[8]={TotemMergeUI,7,2}
}

local ModuleConfig = 
{
	[1] = 
		{
			[1]={1,4,2,3},
			[2]={1,5,2,3}
		},
	[2] = 
		{
			[1]={1,2,6},
			[2]={1,2,7}
		},
	[3] = 
		{
			[1]={8}
		}
}

local prePath = "image/ui/TotemUI/"

--创建图腾UI
TotemUI = createUIClass('TotemUI', prePath .. "TotemUI.ExportJson", PopWayMgr.SMALLTOBIG)
TotemUI.sceneName = "common"

function TotemUI:ctor()
	self.isUpRoleTopView = true
	self.pool = Pool.new()
	self.con_bg:setTouchEnabled(true)
	local size = self.con_bg:getSize()
	local x,y = self.con_bg:getPosition()
	-- local bg = UIFactory.getWindowBg(self, size, x - 1, y, self.txt_title)
	-- bg:setLocalZOrder(1)
	size = self:getSize()
	size.height = size.height + 40
	self:setSize(size)
	self:initSub()

	self.redPos = cc.p(6, 70)
	
	self.moduleMap = {}
	self.subIndex = 0
	self.subModule = 0
	self.currentGlyphGuid = 0

	function self.changeTabHandler(index, delay)
		self.btnList.touchEndedHandler(self.btnList[index])
		self:changeTab(index, true, delay)
	end
end

function TotemUI:showError()
    TipsMgr.showError("已有同系别图腾正在充能")
end

function TotemUI:onShow()
	EventMgr.addListener("kErrTotemDuringEnergy", self.showError, self)
	EventMgr.addListener(EventType.UserTotemUpdate, self.updateData, self)
	EventMgr.addListener(EventType.TotemSlotResult, self.slotResult, self)
	EventMgr.addListener(EventType.TotemMergeResult, self.mergeResult, self)
	EventMgr.addListener(EventType.UserTotemLevelUp, self.checkPlayUpEffect, self)
	Command.bind("totem changetab", self.changeTabHandler)
	if TotemData.currentTabIndex ~= 0 and TotemData.currentTabIndex ~= nil then
		self.changeTabHandler(TotemData.currentTabIndex, true)
	else
		self.changeTabHandler(1, true)
	end
	local function timerHandler()
		--计时器
		local chargeUI = self.moduleMap[5]
		if chargeUI and chargeUI:getParent() then
			chargeUI:updateTime()
		end
		self:updateRed()
	end
	if not self.timer_id then
		self.timer_id = TimerMgr.startTimer(timerHandler, 1)
	end
	timerHandler()
end

function TotemUI:updateRed()
	--刷新红点
	setButtonPoint(self.btn_1, TotemData.checkBottomRedPoint(), self.redPos, 200)	
end

function TotemUI:onClose()
	self:removeAllModule()
	self.timer_id = TimerMgr.killTimer(self.timer_id)
	EventMgr.removeListener(EventType.UserTotemUpdate, self.updateData)
	EventMgr.removeListener(EventType.TotemSlotResult, self.slotResult)
	EventMgr.removeListener(EventType.TotemMergeResult, self.mergeResult)
	EventMgr.removeListener("kErrTotemDuringEnergy", self.showError)
	EventMgr.removeListener(EventType.UserTotemLevelUp, self.checkPlayUpEffect)
	Command.unbind("totem changetab")
	--移除所有雕文
	for _,arr in pairs(self.pool.pool) do
		for _,v in ipairs(arr) do
			v:release() --释放内存池
		end
	end
	self.pool:clear()
end

function TotemUI:dispose()
	for i,v in pairs(self.moduleMap) do
		if v then
			if v.dispose ~= nil then
				v:dispose()
			end
			if v:getParent() then
				v:removeFromParent()
			end
			TimerMgr.releaseLater(v)
		end
		self.moduleMap[i] = nil
	end
end

function TotemUI:createModule(id)
	local model = self.moduleMap[id]
	if not model then
		model = ModuleList[id][1].new(self)
		model:setPosition(ModuleList[id][2], ModuleList[id][3])
		model:retain()
		self.moduleMap[id] = model
	end
	return model
end

function TotemUI:removeAllModule(except)
	--移除所有模块
	for i,v in pairs(self.moduleMap) do
		if not except or gameData.indexOfArray(except, i) == 0 then
			if v and v:getParent() then
				if v.onClose then
					v:onClose()
				end
				v:removeFromParent()
			end
		end
	end
end

function TotemUI:initSub()
	con_sub = self
	self.btnList = {con_sub.btn_1, con_sub.btn_2, con_sub.btn_3}
	local subMenuNames = {"TotemCommon/ttsj", "TotemCommon/dwxq", "TotemCommon/dwhc"}
	local function btnHandler(index)
		ActionMgr.save( 'UI', string.format('[TotemUI] click [con_sub.btn_%s]', index) )
		if index == SUB_3 and not OpenFuncData.checkIsOpenFunc(TotemData.GLYPH_OPEN_ID, true) then
			return true
		end
		self:changeTab(index)
	end
	UIFactory.initSubMenu(self.btnList, subMenuNames, btnHandler, 1)
end

function TotemUI:changeTab(subIndex, isForce, delay)
	if not isForce and self.subIndex == subIndex then
		return
	end
	TotemData.currentTabIndex = subIndex
	self.subIndex = subIndex
	self:changeSubModule(1, delay)
	self:updateRed()
end

function TotemUI:changeSubModule(subModule, delay)
	self.subModule = subModule
	self:updateData(delay)
end

function TotemUI:changeTotem(sTotem)
	if sTotem and sTotem.guid ~= TotemData.currentTotemGuid then
		TotemData.currentTotemGuid = sTotem.guid
		self:changeSubModule(1) --总是切换到子模块第一个
	end
end

function TotemUI:slotResult(msg)
	if self.moduleMap[7] then
		self.moduleMap[7]:slotResult(msg)
	end
end

function TotemUI:mergeResult(msg)
	if self.moduleMap[8] then
		self.moduleMap[8]:mergeResult(msg)
	end
end

function TotemUI:updateData(delay)
	if self.isLock and self.currentTotem and self.currentTotem.guid == TotemData.currentTotemGuid then
		return
	end
	self.isLock = false
	local list = TotemData.getData()
	if #list == 0 then
		self:removeAllModule()
		return
	end
	--更新数据
	self.sTotemList = list
	if TotemData.currentTotemGuid == 0 then
		TotemData.currentTotemGuid = list[1].guid
	end
	self.currentTotem = TotemData.getTotem(TotemData.currentTotemGuid)

	self.jTotem = findTotem(self.currentTotem.id)
	self.jTotemAttr = findTotemAttr(self.currentTotem.id, self.currentTotem.level)
	self.jSkillAttr = findTotemAttr(self.currentTotem.id, self.currentTotem.level)
	self.jSkill = self.jSkillAttr and findSkill(self.jSkillAttr.skill.first, self.jSkillAttr.skill.second)
	self.jSpeedAttr = findTotemAttr(self.currentTotem.id, self.currentTotem.speed_lv)
	self.jSpeedOdd = self.jSpeedAttr and findOdd(self.jSpeedAttr.speed.first, self.jSpeedAttr.speed.second)
	self.jFormationAttr = findTotemAttr(self.currentTotem.id, self.currentTotem.formation_add_lv)
	self.jFormationOdd = self.jFormationAttr and findOdd(self.jFormationAttr.formation_add_attr.first, self.jFormationAttr.formation_add_attr.second)
	self.jWakeAttr = findTotemAttr(self.currentTotem.id, self.currentTotem.wake_lv)
	self.jWakeOdd = self.jWakeAttr and findOdd(self.jWakeAttr.wake.first, self.jWakeAttr.wake.second)
	self.sGlyphList = TotemData.getTotemGlyphList(self.currentTotem.guid)

	if self.subIndex == SUB_1 then
		if TotemData.isAddEnergying(self.currentTotem) or TotemData.checkCanAddEnergy(self.currentTotem) then
			self.subModule = 2
		else
			self.subModule = 1
		end
	elseif self.subIndex == SUB_2 then
		--do nothing
	else
		self.subModule = 1
	end
	--更新显示
	if delay then
		performNextFrame(self, function() self:updateView() end)
	else
		self:updateView()
	end
end

function TotemUI:updateView()
	if ModuleConfig[self.subIndex] then
		local config = ModuleConfig[self.subIndex][self.subModule]
		if config then
			self:removeAllModule(config)
			for i,v in ipairs(config) do
				local model = self:createModule(v)
				if not model:getParent() then
					self:addChild(model)
					if model.onShow then
						model:onShow()
					end
				end
				model:setLocalZOrder(i + 5)
				model:updateData()
			end
		end
	end
end

function TotemUI:addDwObject(jGlyph, parent, x, y, sGlyph)
	local name = jGlyph.icon
	local dw = self.pool:getObject(name)
	if not dw then
		dw = TotemData.getGlyphObject(jGlyph.id, self.winName, parent, x, y, sGlyph)
	else
		dw.jGlyph = jGlyph
		dw.sGlyph = sGlyph
		dw:play()
		dw:setPosition(x, y)
		parent:addChild(dw)
		dw:release()
	end
	dw:setOpacity(255)
	dw:setScale(1) -- 默认缩放倍数
	return dw
end

function TotemUI:disposeDwObject(dw)
	ProgramMgr.setNormal(dw.icon)
	dw:retain()
	dw:stop()
	dw:removeFromParent()
	self.pool:disposeObject(dw._dwname, dw)
end

function TotemUI:getNextStarPos(level)
	local base = self.moduleMap[2]
	if base then
		local p = base:getNextStarPos(level)
		p = base:convertToWorldSpace(p)
		return self:convertToNodeSpace(p)
	end
	return cc.p(0, 0)
end

function TotemUI:lockUpdate(value)
	self.isLock = value
	self.playUpEffect = nil
	if not value then
		self:updateData()
	end
end

function TotemUI:checkPlayUpEffect(sTotem)
    if not self.isLock then
        return
    end
	if sTotem and sTotem.guid ~= TotemData.currentTotemGuid then
		return
	end
	if not self.playUpEffect then
		self.playUpEffect = 1
	else
		self.playUpEffect = nil
		self:playLevelUpEffect()
	end
end

function TotemUI:playLevelUpEffect()
	local base = self.moduleMap[2]
	if base then
		base:playLevelUpEffect()
	end
end

function TotemUI:getTotemUpgradeUI()
	if self.moduleMap and #self.moduleMap >= 4 then
		return self.moduleMap[4]
	end
	return nil
end

local function openTotemUI(index)
	TotemData.currentTabIndex = index
	Command.run("ui show", "TotemUI", PopUpType.SPECIAL)
end
Command.bind("totem open", openTotemUI)