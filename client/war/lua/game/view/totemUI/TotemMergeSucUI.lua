--雕文合成结果窗口
local path = "image/ui/TotemUI/MergeSucUI.ExportJson"
TotemMergeSucUI = createUIClass("TotemMergeSucUI", path, PopWayMgr.SMALLTOBIG)

function TotemMergeSucUI:ctor()
	self:setTouchEnabled(false)
	self.keyColor = cc.c3b(0xff, 0xdd, 0xb3)
	self.valueColor = cc.c3b(0xff, 0xff, 0xff)
	self.lineHeight = 25
	self.richStrs = {}
	self.con_attr:setPositionY(self.con_attr:getPositionY() + 16)
end

function TotemMergeSucUI:onShow()
	self:updateData()
end

function TotemMergeSucUI:onClose()
	local icon = self.img_dwc.icon
	self.img_dwc.icon = nil
	if icon then
		icon:retain()
		local globalPos = icon:convertToWorldSpace(cc.p(0, 0))
		icon:removeFromParent()
		icon:setPosition(globalPos)
		EventMgr.dispatch(EventType.TotemMergeFly, icon)
		icon:release()
	end
end

function TotemMergeSucUI:updateRichText()
	self.con_attr:removeAllChildren()
	RichTextUtil:DisposeRichText(table.concat(self.richStrs), self.con_attr, nil, 0, self:getSize().width - 170, 8)
end

function TotemMergeSucUI:setAttrText(index, s2uint, isHide)
	local keyString = isHide and "隐藏属性：" or "效果"..index.."："
	local valueString = TotemData.getGlyphAttrDesc(s2uint, isHide)
	keyString = FontStyle.getRichText(keyString, self.keyColor, 18)
	valueString = FontStyle.getRichText(valueString, self.valueColor, 18)
	table.insert(self.richStrs, keyString .. valueString .. "[br]")
end

function TotemMergeSucUI:updateData()
	if self.img_dwc.icon then
		self.img_dwc:removeFromParent()
		self.img_dwc.icon = nil
	end
	local sGlyph = TotemData.mergeData
	if not sGlyph then
		return
	end
	self.effectName = ""
	if #sGlyph.hide_attr_list > 0 then
		self.img_title:loadTexture("TotemMergeSuc/jhyc.png", ccui.TextureResType.plistType)
		self.effectName = "hccg-tx-02"
	else
		self.img_title:loadTexture("TotemMergeSuc/hccg.png", ccui.TextureResType.plistType)
		self.effectName = "hccg-tx-01"
	end
	performNextFrame(self, self.showArmature, self)
	--图标
	self.img_dwc.icon = TotemData.getGlyphObject(sGlyph.id, self.winName, self.img_dwc, 44, 44, sGlyph)
	local jGlyph = findTempleGlyph(sGlyph.id)
	self.txt_name:setString(TotemData.getGlyphName(sGlyph, jGlyph))
	self.txt_1:setString(TotemData.QUALITY_DATA[jGlyph.quality])
	self.txt_2:setString(TotemData.getTypeName(jGlyph.type))
	self.richStrs = {}
	local index = 1
	for i,v in ipairs(sGlyph.attr_list) do
		if v.first ~= 0 then
			self:setAttrText(index, v, false)
			index = index + 1
		end
	end
	for i,v in ipairs(sGlyph.hide_attr_list) do
		if v.first ~= 0 then
			self:setAttrText(index, v, true)
			index = index + 1
		end
	end
	self:updateRichText()
	local delta = self.con_attr:getContentSize().height - 90
	self.bg.lbl_close:setPositionY(42 - delta)
	self.bg.grid:setSize(cc.size(501, 382 + delta))
	self.bg.grid:setPositionY(-delta)
	self:setSize(cc.size(502, 400 - delta))
end

function TotemMergeSucUI:showArmature()
	local function onComplete(armature)
		armature:removeNextFrame()
	end
	ArmatureSprite:addArmatureOnce("image/armature/ui/TotemUI/", self.effectName, self.winName, self, 260, 368, onComplete, 20)
end
