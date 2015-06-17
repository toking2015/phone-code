--图腾镶嵌过程UI
local prePath = "image/ui/TotemUI/"
local armaturePath = "image/armature/ui/TotemUI/"
local path = prePath .. "SlotProUI.ExportJson"
TotemSlotProcUI = createUILayout("TotemSlotProcUI", path)

local ROTATION_DATA = {
	-- [1]={270},
	-- [2]={180, 0},
	-- [3]={180, 300, 60},
	[4]={180, 270, 0, 90},
	[1]={180, 270, 0, 90},
	[2]={180, 270, 0, 90},
	[3]={180, 270, 0, 90}
}

local speed = 70--44 --转动速度 °/f

function TotemSlotProcUI:ctor(parent)
	self.parent = parent
	self.maxBoxCount = 1
	local pos = cc.p(self.con_1:getPosition())
	self.con_2 = UIFactory.getLayout(1, 1, self, pos.x, pos.y, 3)
	self.con_2:setTouchEnabled(false)
	for i = 1, 4 do
		local clipNode = cc.ClippingNode:create()
		clipNode:setInverted(true)
		local segment = cc.DrawNode:create()
		clipNode:setStencil(segment)
		self["mask_"..i] = segment
		self["clip_"..i] = clipNode
		if i == 2 then i = 4 elseif i == 4 then i = 2 end
		UIFactory.getSprite(prePath.."dish_".. i .. ".png", clipNode)
		self.con_0:addChild(clipNode)
	end
	local function slotHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemSlotProcUI] click [btn_slot]' )
		if self.parent.currentGlyphGuid ~= 0 then
			if self.isLock == true then
				return
			end
			if not TotemData.getCanSlot(self.parent.currentTotem, self.currentGlyph) then
				return
			end
			self.isLock = true
			if self:isNeedRotation() then --只有一个不需要旋转
				SoundMgr.playUI("UI_dwinlay")
				self:startEffect()
			end
			Command.run("totem glyphembed", TotemData.currentTotemGuid, self.parent.currentGlyphGuid)
		end
	end
	createScaleButton(self.btn_slot)
	self.btn_slot:addTouchEnded(slotHandler)
	local function backHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemSlotProcUI] click [btn_back]' )
		self:stopEffect()
		self.parent:changeSubModule(1)
	end
	createScaleButton(self.btn_back)
	self.btn_back:addTouchEnded(backHandler)
end

function TotemSlotProcUI:isNeedRotation()
	return true -- #self.sGlyphList > 0
end

function TotemSlotProcUI:startEffect()
	local action = cc.RotateBy:create(0, speed)
	self.con_1:runAction(cc.RepeatForever:create(action))
end

function TotemSlotProcUI:stopEffect()
	self.con_1:stopAllActions()
	if self.con_1.img_dwc.icon then
		self.con_1.img_dwc.icon:stopAllActions()
	end
	for i = 1, 4 do
		local cell = self.con_0["dwc_"..i].icon
		if cell then
			cell:stopAllActions()
		end
	end
	self:clearChild("armature1")
	self:clearChild("armature2")
	self:clearChild("armature3")
	self:clearChild("armature4")
end

function TotemSlotProcUI:clearChild(name)
	if self[name] and self[name]:getParent() then
		self[name]:removeFromParent(true)
		self[name] = nil
	end
end

function TotemSlotProcUI:getSlotIndex(msg)
	local map = ROTATION_DATA[self.maxBoxCount]
	if msg.is_new ~= 0 then
		return #self.sGlyphList + 1
	end
	for i,v in ipairs(self.sGlyphList) do
		if v.guid == msg.deleted_guid then
			return i
		end
	end
	return #map
end

--获取要替换的角度
function TotemSlotProcUI:getSlotRotation(index)
	local map = ROTATION_DATA[self.maxBoxCount]
	return map[index]
end

function TotemSlotProcUI:getSlotPosition(index)
	local rotation = self:getSlotRotation(index)
	local radius = 120 --半径
	local y = -math.sin(math.rad(rotation)) * radius --反方向
	local x = math.cos(math.rad(rotation)) * radius
	return cc.p(x, y)
end

function TotemSlotProcUI:getTxtPosition(index)
	local p = self:getSlotPosition(index)
	p.y = p.y - 50
	return p
end

function TotemSlotProcUI:slotResult(msg)
	if msg.totem_guid ~= TotemData.currentTotemGuid then
		EventMgr.dispatch(EventType.UserTotemUpdate)
		return
	end
	local function callback()
		self.con_1:stopAllActions()
		self:doSlotResult(msg)
	end
	if not self:isNeedRotation() then
		callback()
	else
		performWithDelay(self, callback, 1)
	end
end

function TotemSlotProcUI:doSlotResult(msg)
	local index = self:getSlotIndex(msg)
	local sGlyph = TotemData.getGlyph(msg.glyph_guid)
	if not sGlyph then
		return
	end
	sGlyph.index = index --设置位置
	local function roationEnd()
		self:armatureEffect(index)
	end
	if not self:isNeedRotation() then
		roationEnd()
	else
		local tarRotation = (math.round(self.con_1:getRotation() / 360) + 3) * 360 + self:getSlotRotation(index) - 90
		local time = (tarRotation - self.con_1:getRotation()) / (speed * 1000)
		local action = cc.RotateTo:create(time, tarRotation)
		self.con_1:runAction(cc.Sequence:create(action, cc.CallFunc:create(roationEnd)))
	end
end

function TotemSlotProcUI:armatureEffect(index)
	local function completeHandler1()
		self:hideAndFlyJump(index)
		self.armature1:runAction(cc.RemoveSelf:create())
		self.armature2:runAction(cc.RemoveSelf:create())
		self.armature3:runAction(cc.RemoveSelf:create())
		self.armature1 = nil
		self.armature2 = nil
		self.armature3 = nil
	end
	local lp = self:getSlotPosition(index)
	self.armature1 = ArmatureSprite:addArmatureEx(armaturePath, "xiangq-tx-01", self.parent.winName, self.con_2)
	self.armature2 = ArmatureSprite:addArmatureEx(armaturePath, "xiangq-tx-02", self.parent.winName, self.con_2)
	self.armature2:setRotation(self:getSlotRotation(index))
	self.armature3 = ArmatureSprite:addArmatureOnce(armaturePath, "xiangq-tx-03", self.parent.winName, self.con_2, lp.x, lp.y, completeHandler1)
	local cell = self.con_0["dwc_"..index].icon
	if cell then
		cell:runAction(cc.FadeOut:create(0.5))
	end
end

function TotemSlotProcUI:hideAndFlyJump(index)
	local icon = self.con_1.img_dwc.icon
	if not icon then
		return
	end
	local lp = self:getSlotPosition(index)
	local gp = self.con_0:convertToWorldSpace(lp)
	local p = self.con_1.img_dwc:convertToNodeSpace(gp)
	local function completeHandler3()
		self.armature4:runAction(cc.RemoveSelf:create())
		self.armature4 = nil
		TipsMgr.floatingNode(UIFactory.getSprite("image/ui/TotemUI/result_xqwc.png"), visibleSize.width / 2 + 338, visibleSize.height / 2 - 50)
		EventMgr.dispatch(EventType.UserTotemUpdate)
	end
	local function completeHandler2()
		self.armature4 = ArmatureSprite:addArmatureOnce(armaturePath, "xiangq-tx-04", self.parent.winName, self.con_2, lp.x, lp.y, completeHandler3)
	end
	local action1 = cc.FadeOut:create(0.2)
	local action2 = cc.Place:create(p)
	local action3 = cc.ScaleTo:create(0, 3)
	local action41 = cc.FadeIn:create(0)
	local action42 = cc.ScaleTo:create(0.5, 1)
	local action4 = cc.Spawn:create(action41, action42)
	local action5 = cc.CallFunc:create(completeHandler2)
	local action = cc.Sequence:create(action1, action2, action3, action4, action5)
	self.con_1.img_dwc.icon:runAction(action)
end

function TotemSlotProcUI:onShow()
	--需要重设个数
	self.shouldChangeCount = true
end

function TotemSlotProcUI:updateData()
	self.isLock = false
	self:stopEffect()
	local parent = self.parent
	local cell = self.con_1.img_dwc
	if cell.icon then
		parent:disposeDwObject(cell.icon)
		cell.icon = nil
	end
	local currentGlyph = TotemData.getGlyph(parent.currentGlyphGuid)
	self.currentGlyph = currentGlyph
	if not currentGlyph or currentGlyph.totem_guid ~= 0 then
		parent.currentGlyphGuid = 0
		currentGlyph = nil
	end
	if currentGlyph then
		local jGlyph = findTempleGlyph(currentGlyph.id)
		cell.icon = parent:addDwObject(jGlyph, cell, 44, 44, currentGlyph)
	end
	local list = TotemData.getTotemGlyphList(TotemData.currentTotemGuid)
	self.sGlyphList = list
	if self.shouldChangeCount then
		self.shouldChangeCount = false
		self.maxBoxCount = 4--math.min(4, #list + 1)
		self.con_1:setRotation(self:getSlotRotation(self.maxBoxCount) - 90) --默认指向空格
	end
	for i = 1, 4 do
		local cell = self.con_0["dwc_"..i]
		local txt = self.con_0["txt_"..i]
		local mask = self["mask_"..i]
		local clip = self["clip_"..i]
		if cell.icon then
			parent:disposeDwObject(cell.icon)
			cell.icon = nil
		end
		if i <= self.maxBoxCount then
			cell:setVisible(true)
			clip:setVisible(true)
			cell:setPosition(self:getSlotPosition(i))
			txt:setPosition(self:getTxtPosition(i))
			if i <= #list then
				local jGlyph = findTempleGlyph(list[i].id)
				cell.icon = parent:addDwObject(jGlyph, cell, 37.5, 37.5, list[i])
				txt:setString(TotemData.getGlyphName(list[i], jGlyph))
				txt:setVisible(true)
			else
				txt:setVisible(false)
			end
			local degreeData = ROTATION_DATA[self.maxBoxCount]
			local deltaDegree = 180 / #degreeData + 1
			local startDegree = degreeData[i] + deltaDegree
			local endDegree = degreeData[i] - deltaDegree
			DrawUtils.drawSector(mask, startDegree, endDegree, 200, cc.c4f(1, 0, 0, 1))
		else
			txt:setVisible(false)
			cell:setVisible(false)
			clip:setVisible(false)			
		end
	end
end