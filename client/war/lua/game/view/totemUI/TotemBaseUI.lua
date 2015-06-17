--图腾形象显示
local path = "image/ui/TotemUI/BaseUI.ExportJson"
TotemBaseUI = createUILayout("TotemBaseUI", path)

function TotemBaseUI:ctor(parent)
	self.parent = parent
	local function onTouchTotem(target)
		ActionMgr.save( 'UI', '[TotemBaseUI] click [con_totem]' )
		if self._totemRole then
			SoundMgr.playEffect("sound/ui/totem_updown.mp3")
			self._totemRole:playOnce("sf")
		end
	end
	UIMgr.addTouchEnded(self.con.con_totem, onTouchTotem)
	local pos = cc.p(self.con.con_totem:getPosition())
	self.txt_type = UIFactory.getText("", self.con, pos.x + 205, pos.y + 272, 18, cc.c3b(0xff, 0x30, 0x00), nil, nil, 4)
end

function TotemBaseUI:updateData()
	local parent = self.parent
	local con = self.con
	self:setStar(con, parent.currentTotem)
	self.txt_type:setString(TotemData.getTypeName(parent.jTotem.type))
	self.txt_type:setColor(TotemData.getTypeColor(parent.jTotem.type))
	--更新雕文显示
	local showGlyph = OpenFuncData.checkIsOpenFunc(TotemData.GLYPH_OPEN_ID, false)
	for i = 1, 4 do
		local cell = con["dw_"..i]
		cell:setVisible(showGlyph)
		local old = cell.glyph
		if old then
			parent:disposeDwObject(old)
			cell.glyph = nil
		end
		if i <= #parent.sGlyphList then
			local jGlyph = findTempleGlyph(parent.sGlyphList[i].id)
			local glyph = parent:addDwObject(jGlyph, cell, 28, 32.5, parent.sGlyphList[i])
			glyph:setScale(0.8) --缩放
			cell.glyph = glyph
		end
	end
	--更新形象显示
	self:removeView()
	local style = parent.jTotem.animation_name
	if style ~= nil or style ~= "" then
		--接口里已做大于4的处理
		local level = TotemData.getLevelForStyle(parent.jTotem)
		local _totemRole = ModelMgr:useModel(style .. level, const.kAttrTotem, style, level)
		_totemRole:setPosition(cc.p(115, 110))
		con.con_totem:addChild(_totemRole)
		_totemRole:playOne(false, "stand")
		self._totemRole = _totemRole
	end
end

function TotemBaseUI:removeView()
	if self._totemRole then
		ModelMgr:recoverModel(self._totemRole)
		self._totemRole = nil
	end
end

function TotemBaseUI:dispose()
	self:removeView()
end

function TotemBaseUI:doSetStar(level)
	local con = self.con
	for i = 1, 5 do
		local frameName = i > level and "star_1.png" or "star_2.png"
		con["star_"..i]:loadTexture(frameName, ccui.TextureResType.plistType)
	end
end

function TotemBaseUI:doSetQuality()
	local con = self.con
	local parent = self.parent
	con.totem_bg:loadTexture(string.format("image/ui/TotemUI/qu_%d.png", parent.currentTotem.level), ccui.TextureResType.localType)
	con.txt_name:setColor(QualityData.getColor(parent.currentTotem.level))
	con.txt_name:setString(parent.jTotem.name)
end

function TotemBaseUI:setStar(con, sTotem)
	self.currentLevel = sTotem.level
	self.currentGuid = sTotem.guid
	self:doSetStar(sTotem.level)
	self:doSetQuality()
end

function TotemBaseUI:playLevelUpEffect()
	local sTotem = self.parent.currentTotem
	if self.currentGuid == sTotem.guid then
		local armature
		local function onComplete()
			armature:removeNextFrame()
			self:doSetStar(sTotem.level + 1)
			self:playQualityEffect()
		end
		local pos = self:getNextStarPos(sTotem.level)
		armature = ArmatureSprite:addArmatureOnce("image/armature/ui/TotemUI/", "sxbg-tx-01", self.parent.winName, self.con, pos.x, pos.y, onComplete, 20)
	end
end

function TotemBaseUI:playQualityEffect()
	SoundMgr.playEffect("sound/totem_use.mp3")
	local armature
	local function onComplete()
		armature:removeNextFrame()
		-- self:doSetQuality()
		self.parent:lockUpdate(false)
	end
	local pos = cc.p(self.con.totem_bg:getPosition())
	armature = ArmatureSprite:addArmatureOnce("image/armature/ui/TotemUI/", "ttgd-tx-01", self.parent.winName, self.con, pos.x, pos.y, onComplete, 20)
end

--获得星星的位置
function TotemBaseUI:getNextStarPos(level)
	level = level >= 5 and 5 or level + 1
	return cc.p(self.con["star_"..level]:getPosition())
end
