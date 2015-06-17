--图腾镶嵌
local path = "image/ui/TotemUI/SlotUI.ExportJson"
TotemSlotUI = createUILayout("TotemSlotUI", path)

function TotemSlotUI:ctor(parent)
	self.parent = parent
	local con = self.con
	con.whcdk:loadTexture("image/ui/TotemUI/whcdk.png", ccui.TextureResType.localType)
	local pos = cc.p(con.whcdk:getPosition())
	UIFactory.getSprite("image/ui/TotemUI/slot_mask.png", con, pos.x + 2, pos.y + 28, 5):setAnchorPoint(0, 0)
	local function explainHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemSlotUI] click [btn_explain]' )
		TipsMgr.showRules(TotemData.RULE_SLOT, "image/ui/TotemUI/title_xqgz.png", true)
	end
	createScaleButton(con.btn_explain)
	con.btn_explain:addTouchEnded(explainHandler)
	local function slotHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemSlotProcUI] click [btn_slot]' )
		if not OpenFuncData.checkIsOpenFunc(TotemData.GLYPH_OPEN_ID, true) then
			return
		end
		if self.parent.currentGlyphGuid ~= 0 then
			self.parent:changeSubModule(2)
		end
	end
	createScaleButton(con.btn_slot)
	con.btn_slot:addTouchEnded(slotHandler)
	self.con_box = BoxContainer.new(4, 3, cc.p(69, 71), cc.p(30, 10), cc.p(10, 10))
	con.con_dw:addChild(self.con_box)

	local function touchEndedHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemSlotProcUI] click [con_dw]' )
		local startPos = sender:getTouchStartPos()
		local endPos = sender:getTouchEndPos()
		if not cc.pFuzzyEqual(startPos, endPos, Config.FUZZY_VAR) then
			return
		end
		local index = self.con_box:hitTest(endPos)
		local sGlyph = self.sGlyphList[index]
		if not sGlyph then
			return
		end
		if not TotemData.getCanSlot(self.parent.currentTotem, sGlyph) then
			return
		end
		self.parent.currentGlyphGuid = sGlyph.guid
		self:updateWDW()
	end
	UIMgr.addTouchEnded(con.con_dw, touchEndedHandler)
end

function TotemSlotUI:onShow()
	self.enableDelayUpdate = true
end

function TotemSlotUI:updateData()
	self:updateYDW()
	self:updateWDW()
end

function TotemSlotUI:updateYDW()
	local parent = self.parent
	local con = self.con.con_ydw
	local list = TotemData.getTotemGlyphList(parent.currentTotem.guid)
	for i = 1, 4 do
		local cell = con["ydw_"..i]
		if cell.icon then
			parent:disposeDwObject(cell.icon)
			cell.icon = nil
		end
	end
	if #list == 0 then
		self.con.txt_tips:setVisible(true)
		con:setVisible(false)
		return
	else
		self.con.txt_tips:setVisible(false)
		con:setVisible(true)
	end
	for i = 1, 4 do
		local cell = con["ydw_"..i]
		if i <= #list then
			local jGlyph = findTempleGlyph(list[i].id)
			cell.icon = parent:addDwObject(jGlyph, cell, 46, 69.5, list[i])
			con["txt_name_"..i]:setString(TotemData.getGlyphName(list[i], jGlyph))
		else
			con["txt_name_"..i]:setString("")
		end
	end
end

function TotemSlotUI:updateWDW()
	local parent = self.parent
	local con = self.con_box
	local list = TotemData.getTotemGlyphList(0)
	TotemData.sortGlyphByType(list, parent.jTotem.type)
	self.sGlyphList = list
    local currentGlyph = nil
	if parent.currentGlyphGuid ~= 0 then
		currentGlyph = TotemData.getGlyph(parent.currentGlyphGuid)
	end
	if not TotemData.getCanSlot(parent.currentTotem, currentGlyph, true) then
		parent.currentGlyphGuid = 0
		currentGlyph = nil
	end
	if #list > 0 and parent.currentGlyphGuid == 0 then
		if TotemData.getCanSlot(parent.currentTotem, list[1], true) then
			parent.currentGlyphGuid = list[1].guid
			currentGlyph = list[1]
		end
	end
	for i = 1, con.count do
		local cell = con:getNode(i)
		if cell and cell.icon then
			parent:disposeDwObject(cell.icon)
			cell.icon = nil
		end
	end
	con:setNodeCount(#list)
	local function updateOneNode(i)
		local cell = con:getNode(i)
		if not cell then
			cell = UIFactory.getLayout(74, 74)
			cell:setTouchEnabled(false)
			cell.bg = UIFactory.getSpriteFrame("TotemSlot/wxqk.png", cell, 30, 30)
			con:addNode(cell, i)
		end
		local hasMark = false
		if i <= #list then
			local jGlyph = findTempleGlyph(list[i].id)
			cell.icon = parent:addDwObject(jGlyph, cell, 30, 30, list[i])
			hasMark = currentGlyph and list[i].guid == currentGlyph.guid
			if jGlyph.type ~= parent.jTotem.type then
				ProgramMgr.setGray(cell.icon.icon)
			end
		end
		if hasMark then
			if not cell.mark then
				cell.mark = UIFactory.getSpriteFrame("head_mark.png", cell, 45, 20, 10)
			end
		else
			if cell.mark then
				cell.mark:removeFromParent()
				cell.mark = nil
			end
		end
	end
	con:reloadData(updateOneNode, self.enableDelayUpdate)
	self.enableDelayUpdate = nil

	local scrollSize = cc.size(375, math.max(260, con:getHeight() + 35))
	self.con.con_dw:setInnerContainerSize(scrollSize)
	con:setPosition(0, scrollSize.height)
end