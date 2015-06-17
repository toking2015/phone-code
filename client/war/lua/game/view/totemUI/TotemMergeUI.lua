--雕文合成UI
local path = "image/ui/TotemUI/MergeUI.ExportJson"
local armaturePath = "image/armature/ui/TotemUI/"
TotemMergeUI = createUILayout("TotemMergeUI", path)

function TotemMergeUI:ctor(parent)
	self.parent = parent
	local con = self.con
	self.bg.hcbg:loadTexture("image/ui/TotemUI/hcbg.png", ccui.TextureResType.localType)
	local function explainHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemMergeUI] click [btn_sm]' )
		TipsMgr.showRules(TotemData.RULE_MERGE, "image/ui/TotemUI/title_hcgz.png", true)
	end
	createScaleButton(con.btn_sm)
	con.btn_sm:addTouchEnded(explainHandler)
	local function mergeHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemMergeUI] click [btn_hc]' )
		if self.guid1 ~= 0 and self.guid2 ~= 0 then
			if self.isWaiting ~= true then
				self.hasResult = false
				SoundMgr.playUI("UI_dwcompound")
				self:effectStep1()
				Command.run("totem glyphmerge", self.guid1, self.guid2)
			end
		end
	end
	createScaleButton(con.btn_hc)
	con.btn_hc:addTouchEnded(mergeHandler)
	self.con_box = BoxContainer.new(2, 0, cc.p(190, 68), cc.p(0, 12), cc.p(11, 6))
	con.con_list:addChild(self.con_box)

	self.guid1 = 0
	self.guid2 = 0
	self.guid3 = 0

	local function touchEndedHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemMergeUI] click [con_list]' )
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
		if self.guid1 == sGlyph.guid then
			self.guid1 = 0
		elseif self.guid2 == sGlyph.guid then
			self.guid2 = 0
		elseif self.guid1 == 0 then
			if self.guid2 ~= 0 and not TotemData.getCanMerge(TotemData.getGlyph(self.guid2).id, sGlyph.id) then
				return
			end
			self.guid1 = sGlyph.guid
		elseif self.guid2 == 0 then
            if self.guid1 ~= 0 and not TotemData.getCanMerge(TotemData.getGlyph(self.guid1).id, sGlyph.id) then
				return
			end
			self.guid2 = sGlyph.guid
		else
			return
		end
		self:updateData()
	end
	UIMgr.addTouchEnded(con.con_list, touchEndedHandler)
	local function boxTouchHandler(sender, eventType)
		ActionMgr.save( 'UI', '[TotemMergeUI] click [box_]' )
		if self.con.box_1 == sender then
			if self.guid1 ~= 0 then
				self.guid1 = 0
				self:updateData()
			end
		elseif self.con.box_2 == sender then
			if self.guid2 ~= 0 then
				self.guid2 = 0
				self:updateData()
			end
		end
	end
	UIMgr.addTouchEnded(con.box_1, boxTouchHandler)
	UIMgr.addTouchEnded(con.box_2, boxTouchHandler)
end

function TotemMergeUI:onShow()
	self.enableDelayUpdate = true
	EventMgr.addListener(EventType.TotemMergeFly, self.mergeFly, self)
end

function TotemMergeUI:onClose()
	EventMgr.removeListener(EventType.TotemMergeFly, self.mergeFly)
	self:disposeUnused(1)
	self:disposeBoxes()
	self:disposeFlyIcon()
	self.scrollToIcon = nil
	self.isWaiting = false
	self:removeEffect("armature10")
	self:removeEffect("armature11")
	self:removeEffect("armature2")
	self:removeEffect("armature3")
	self:removeEffect("armature4")
end

function TotemMergeUI:mergeResult(msg)
	self.msg = msg
	self.hasResult = true
	if self.isWaiting then
		return
	end
	self:doMergeResult()
end

function TotemMergeUI:mergeFly(icon)
	if self.flyIcon or not self.scrollToIcon then
		return
	end
	local pos = self:convertToNodeSpace(cc.p(icon:getPosition()))
	icon:setPosition(pos)
	self:addChild(icon, 30)
	self.flyIcon = icon
	local tarPos = self.scrollToIcon:convertToWorldSpace(cc.p(0, 0))
	tarPos = self:convertToNodeSpace(tarPos)
	local function onMoveComplete()
		self:disposeFlyIcon()
	end
	icon:runAction(cc.Sequence:create(cc.MoveTo:create(1, tarPos), cc.CallFunc:create(onMoveComplete)))
end

function TotemMergeUI:doMergeResult()
	local msg = self.msg
    local path
	if msg.is_success == 0 then
		SoundMgr.playUI("UI_dwcompoundfail")
		path = "result_hcsb"
		local pos
		if msg.deleted_guid == self.guid1 then
			self.guid1 = 0
			pos = cc.p(120, 450)
		else
			self.guid2 = 0
			pos = cc.p(400, 450)
		end
		self.guid3 = 0
		self:effectStep2(pos)
	else
		SoundMgr.playUI("UI_dwcompoundwin")
		path = "result_hccg"
		self.guid1 = 0
		self.guid2 = 0
		if msg.result_glyph then
		   self.guid3 = msg.result_glyph.guid
		end
        local function delayShowUI()
            Command.run("ui show", "TotemMergeSucUI", PopUpType.SPECIAL)
        end
        self:runAction(cc.CallFunc:create(delayShowUI))
	end
    TipsMgr.floatingNode(UIFactory.getSprite(string.format("image/ui/TotemUI/%s.png", path)), visibleSize.width / 2 - 150, visibleSize.height / 2)
    self:updateData(self.guid3)
end

function TotemMergeUI:disposeOne(box)
	if box.icon then
		self.parent:disposeDwObject(box.icon)
		box.icon = nil
	end
end

function TotemMergeUI:addOne(jGlyph, box, x, y, sGlyph)
	local icon = self.parent:addDwObject(jGlyph, box, x, y, sGlyph)
	box.icon = icon
end

function TotemMergeUI:disposeFlyIcon()
	if self.flyIcon then
		self.parent:disposeDwObject(self.flyIcon)
		self.flyIcon = nil
	end
end

function TotemMergeUI:disposeBoxes()
	for i = 1, 3 do
		local box = self.con["box_"..i]
		self:disposeOne(box)
	end
	for i = 1, 4 do
		local box = self.con.con_may["knk_"..i]
		self:disposeOne(box)
	end
end

function TotemMergeUI:disposeUnused(startIndex)
	local parent = self.parent
	for i = startIndex, self.con_box.count do
		local glyphView = self.con_box:getNode(i)
		if glyphView then
			self:disposeOne(glyphView)
		end
	end
end

function TotemMergeUI:updateData(scrollToGuid)
	self:disposeUnused(1) -- 把所有雕文回收到内存池
	self:disposeBoxes()
	self:updateList(scrollToGuid)

	local parent = self.parent
	local con = self.con
	local quality = const.kQualityWhite

	for i = 1, 3 do
		local guid = self["guid"..i]
		if guid ~= 0 then
			local sGlyph = TotemData.getGlyph(guid)
			if sGlyph and sGlyph.totem_guid == 0 then
				local jGlyph = findTempleGlyph(sGlyph.id)
				if jGlyph then
					self:addOne(jGlyph, con["box_"..i], 52, 49, sGlyph)
					quality = jGlyph.quality
				end
			else
				self["guid"..i] = 0 --
			end
		end
	end
	if self.guid1 ~= 0 and self.guid2 ~= 0 then
		-- self.guid3 = self.guid1
		con.con_may:setVisible(true)
		con.txt_tips:setVisible(false)
		local quality = 1
		local mayList = TotemData.getMayGlyphList(TotemData.getGlyph(self.guid1), TotemData.getGlyph(self.guid2))
		for i = 1, 4 do
			if i <= #mayList then
				local jGlyph = findTempleGlyph(mayList[i].id)
				self:addOne(jGlyph, con.con_may["knk_"..i], 38, 51, mayList[i])
				con.con_may["txt_"..i]:setString(TotemData.getGlyphName(mayList[i], jGlyph))
			else
				con.con_may["txt_"..i]:setString("")
			end
		end
	else
		self.guid3 = 0
		con.con_may:setVisible(false)
		con.txt_tips:setVisible(true)
	end
	con.txt_rate:setString(string.format("成功率：%d%%", TotemData.MERGE_RATE[quality]))
	con.img_wz:setVisible(self.guid3 == 0)
end

function TotemMergeUI:updateList(scrollToGuid)
	local parent = self.parent
	local con = self.con_box
	local list = TotemData.getTotemGlyphList(0) --未镶嵌雕文列表
	self.sGlyphList = list
	con:setNodeCount(#list)
	local scrollToIcon
	local function updateOneNode(i)
		local glyphView = con:getNode(i)
		if not glyphView then
			glyphView = UIFactory.getLayout(200, 68)
			glyphView:setTouchEnabled(false)
			UIFactory.getSpriteFrame("TotemMerge/mc.png", glyphView, 85 + 34, 32)
			UIFactory.getSpriteFrame("TotemSlot/dwdk.png", glyphView, 34, 34)
			glyphView.txt = UIFactory.getLabel("", glyphView, 74, 32, 22, cc.c3b(0xfe, 0xe5, 0x90))
			glyphView.txt:setAnchorPoint(0, 0.5)
			con:addNode(glyphView, i)
		end
		local hasMark = false
		if i <= #list then
			local jGlyph = findTempleGlyph(list[i].id)
			glyphView.txt:setString(TotemData.getGlyphName(list[i], jGlyph))
			self:addOne(jGlyph, glyphView, 34, 34, list[i])
			hasMark = list[i].guid == self.guid1 or list[i].guid == self.guid2
			glyphView:setVisible(true)
			if scrollToGuid == list[i].guid then
				scrollToIcon = glyphView.icon
			end
		else
			glyphView:setVisible(false)
		end
		if hasMark then
			if not glyphView.mark then
				glyphView.mark = UIFactory.getSpriteFrame("head_mark.png", glyphView, 45, 20, 10)
			end
		else
			if glyphView.mark then
				glyphView.mark:removeFromParent()
				glyphView.mark = nil
			end
		end
	end
	con:reloadData(updateOneNode, self.enableDelayUpdate) --分帧刷新
	self.enableDelayUpdate = nil

	local scrollSize = cc.size(self.con.con_list:getSize().width, math.max(378, con:getHeight()))
	self.con.con_list:setInnerContainerSize(scrollSize)
	con:setPosition(0, scrollSize.height)
	if scrollToIcon then --滚动到目标
		local pos = cc.p(scrollToIcon:getParent():getPosition())
		local percent = 100 * -pos.y / scrollSize.height
		self.con.con_list:jumpToPercentVertical(math.min(100, percent))
		self.scrollToIcon = scrollToIcon
	end
end

function TotemMergeUI:effectStep1()
	if self.armature10 or self.armature11 then
		return
	end
	self.isWaiting = true
	local complete10 = false
	local complete11 = false
	local function onComplete10(armature)
		armature:removeNextFrame()
		complete10 = true
		self.armature10 = nil
		if complete10 and complete11 then
			self:effectStep3()
		end
	end
	local function onComplete11(armature)
		armature:removeNextFrame()
		complete11 = true
		self.armature11 = nil
		if complete10 and complete11 then
			self:effectStep3()
		end
	end
	local pos10 = cc.p(126, 449)
	local pos11 = cc.p(406, 449)
	self.armature10 = ArmatureSprite:addArmatureOnce(armaturePath, "dwhc-tx-01", self.parent.winName, self, pos10.x, pos10.y, onComplete10, 20)
	self.armature11 = ArmatureSprite:addArmatureOnce(armaturePath, "dwhc-tx-01", self.parent.winName, self, pos11.x, pos11.y, onComplete11, 20)
end

function TotemMergeUI:effectStep3()
	if self.armature30 or self.armature31 then
		return
	end
	local complete30 = false
	local complete31 = false
	local function onComplete30(armature)
		armature:removeNextFrame()
		complete30 = true
		self.armature30 = nil
		if complete30 and complete31 then
			self:effectStep4()
		end
	end
	local function onComplete31(armature)
		armature:removeNextFrame()
		complete31 = true
		self.armature31 = nil
		if complete30 and complete31 then
			self:effectStep4()
		end
	end
	local pos30 = cc.p(125, 438)
	local pos31 = cc.p(402, 438)
	self.armature30 = ArmatureSprite:addArmatureOnce(armaturePath, "dwhc-tx-03", self.parent.winName, self, pos30.x, pos30.y, onComplete30, 19)
	self.armature31 = ArmatureSprite:addArmatureOnce(armaturePath, "dwhc-tx-03", self.parent.winName, self, pos31.x, pos31.y, onComplete31, 19)
	self.armature31:setScaleX(-1)
end

function TotemMergeUI:effectStep4()
	if self.armature4 then
		return
	end
	local function onComplete4(armature)
		armature:removeNextFrame()
		self.armature4 = nil
		self.isWaiting = false
		if self.hasResult then
			 self:doMergeResult()
		end
	end
	local pos4 = cc.p(265, 310)
	self.armature4 = ArmatureSprite:addArmatureOnce(armaturePath, "dwhc-tx-04", self.parent.winName, self, pos4.x, pos4.y, onComplete4, 20)
end

function TotemMergeUI:effectStep2(pos)
	if self.armature2 then
		return
	end
	local function onComplete2(armature)
		armature:removeNextFrame()
		self.armature2 = nil
	end
	self.armature2 = ArmatureSprite:addArmatureOnce(armaturePath, "dwhc-tx-02", self.parent.winName, self, pos.x, pos.y, onComplete2, 20)
end

function TotemMergeUI:removeEffect(name)
	if self[name] then
		safeRemoveFromParent(self[name])
		self[name] = nil
	end
end